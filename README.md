<picture>
    <source srcset="../../../Ex.Media/blob/develop/Spotlight/SpotlightDemo-Dark.gif" media="(prefers-color-scheme: dark)">
    <source srcset="../../../Ex.Media/blob/develop/Spotlight/SpotlightDemo-Light.gif" media="(prefers-color-scheme: light)">
    <img src="../../../Ex.Media/blob/develop/Spotlight/SpotlightDemo-Light.gif" align="left" width="345" height="460">
</picture>

<img src="../../../Ex.Media/blob/develop/Misc/Spacer.png" width="140" height="0">

<picture>
    <source srcset="../../../Ex.Media/blob/develop/Logo/Logo-Dark.png" media="(prefers-color-scheme: dark)">
    <source srcset="../../../Ex.Media/blob/develop/Logo/Logo-Light.png" media="(prefers-color-scheme: light)">
    <img src="../../../Ex.Media/blob/develop/Logo/Logo-Light.png" width="140" height="59">
</picture>

# Spotlight - SwiftUI

#### Explore an example spotlight onboarding system.
###### In the Example Series, we engineer solutions to custom UI/UX systems and components, focusing on production quality code.
###### Stay tuned for updates to the series:
[![Follow](https://img.shields.io/github/followers/Tre-Ellis-Cooper?style=social)](https://github.com/Tre-Ellis-Cooper)

[![LinkedIn](https://img.shields.io/static/v1?style=social&logo=linkedin&label=LinkedIn&message=Tre%27Ellis%20Cooper)](https://www.linkedin.com/in/tre-ellis-cooper-629306106/)&nbsp;
[![Twitter](https://img.shields.io/static/v1?style=social&logo=twitter&label=Twitter&message=@_cooperlative)](https://www.twitter.com/_cooperlative/)&nbsp;
[![Instagram](https://img.shields.io/static/v1?style=social&logo=instagram&label=Instagram&message=@_cooperlative)](https://www.instagram.com/_cooperlative/)

![Repo Size](https://img.shields.io/github/repo-size/Tre-Ellis-Cooper/Ex.Spotlight?color=green)
![Lines of Code](https://img.shields.io/tokei/lines/github/Tre-Ellis-Cooper/Ex.Spotlight?color=green&label=lines)
![Last Commit](https://img.shields.io/github/last-commit/Tre-Ellis-Cooper/Ex.Spotlight?color=C23644)
<br>

## Usage

#### Setting up a spotlight sequence is pretty simple:
* Implement the `FocusOverlay` protocol.
```swift
struct ExampleOverlay : FocusOverlay { ... }
```

<br>

* Establish any spotlight elements using the `spotlightElement(_:,_:)` modifier.
```swift
Text("Example Text")
    .spotlightElement(key: "element.key", shape: .circle)
```

<br> 

* Establish a spotlight presenter using the `.presentSpotlight(_:,_:)` modifier.
* Send a `Spotlight` sequence to the `.presentSpotlight(_:,_:)` modifier publisher.
```swift
struct ExampleApp: App {
    let publisher: CurrentValueSubject<Spotlight?, Never>
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // In this example, the presenter is the 
                // application's base view. 
                //
                // The receiver should contain any spotlight
                // elements it expects to focus on.
                .presentSpotlight(publisher, using: ExampleOverlay.self)
                .onAppear(start)
        }
    }
    
    private func start() {
        let element = Spotlight
            .Element(key: "element.key", message: "Message!")
        let spotlight = Spotlight(elements: [element], cancellable: true)
        
        publisher.send(spotlight);
    }
}
```

<br>

Try adding the `Source` directory to your project and see what spotlight sequences you can create!

## Exploration

<details>
    
<summary>Code Design</summary>

### Code Design
    
The code design prioritizes ease of use by ensuring spotlight sequences can be tweaked, repurposed, and even visually changed without heavy refactoring. Let's walk through how the code is constructed and see why.

At its core, the system is comprised of two view modifiers: 
* `.spotlightElement(_:,_:)`
* `.presentSpotlight(_:,_:)`

<br>

The `.spotlightElement(_:,_:)` modifier pairs the caller's frame (and desired focus shape) with a key and makes that information available to the view hierarchy using SwiftUI's view preferences.
```swift
func spotlightElement(
    key: Spotlight.Element.Key,
    shape: Spotlight.Element.Shape = .circle
) -> some View {
    self.transformAnchorPreference(
        key: SpotlightPreference.self,
        value: .bounds,
        transform: {
            $0[key] = SpotlightPreference
                .Target(anchor: $1, shape: shape)
        }
    )
}
```

<br>

The `.presentSpotlight(_:,_:)` modifier adds a `SpotlightViewModifier` to the receiver that processes and renders spotlight sequences.
```swift
func presentSpotlight<P: Publisher, F: FocusOverlay>(
    _ publisher: P,
    using type: F.Type = DefaultOverlay.self
) -> some View where P.Output == Spotlight?, P.Failure == Never {
    self.modifier(
        SpotlightViewModifier<F>(viewModel: .init(publisher: publisher))
    )
}
```

<br>

The `SpotlightViewModifier` body accesses any element preferences (propagated by `.spotlightElement(_:,_:)`), overlays the receiver with a `FocusOverlay` implementation, and provides that overlay with information about the current spotlight sequence (the focused element frame, the associated message, etc.).
```swift
struct SpotlightViewModifier<Overlay: FocusOverlay>: ViewModifier {
    @ObservedObject var viewModel: SpotlightViewModel
    
    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(SpotlightPreference.self) { targets in
                GeometryReader { geometry in
                    ...
                    
                    Overlay(focus: focus, container: container)
                    ...
                }
            }
    }
}
```

<br>

In summary, the `.spotlightElement(_:,_:)` modifier establishes focusable elements and the `.presentSpotlight(_:,_:)` modifier creates a focus overlay that receives spotlight sequences and has access to the focusable elements.

Before going further, let's acknowledge the `SpotlightViewModifier` generic constraint: `FocusOverlay`. Abstraction is a great way to make code components interchangeable and a protocol helps do just that. Introducing the `FocusOverlay` protocol makes the `SpotlightViewModifier` unaware of the explicit overlay implementation. This gives the spotlight UI tons of flexibility by allowing us to switch between conforming types. If we ever need to change the look and feel of the onboarding sequence, we can inject a different `FocusOverlay` implementation (or even support multiple) without disrupting any other logic.

Now that we've established how simple it is to create spotlight elements and presenters: let's look at how “spotlight sequences” are presented and how interaction is handled. 

The `SpotlightViewModifier` uses a view model (`SpotlightViewModel`) to govern interactions and manage the current spotlight sequence. The view model receives spotlights via the provided publisher, broadcasts the currently targeted element (if there is one), and handles the logic of stepping through the sequence elements.
```swift
class SpotlightViewModel: ObservableObject {
    @Published private(set) var target: Spotlight.Element?

    ...

    private var sink: AnyCancellable?
    private var spotlight: Spotlight?
    
    init<T: Publisher>(
        publisher: T
    ) where T.Output == Spotlight?, T.Failure == Never { ... }
    
    func targetNone() { ... }
    func targetNext() { ... }
    
    ...
}
```

<br>

Returning to the `SpotlightViewModifier` implementation, we can now understand the full picture: the view model receives spotlight sequences and broadcasts the current target in a sequence. The view gets the target frame by querying the element preferences for the view model's target. The overlay implementation is then given the target frame and any necessary behavior callbacks/flags.
```swift
struct SpotlightViewModifier<Overlay: FocusOverlay>: ViewModifier {
    @ObservedObject var viewModel: SpotlightViewModel
    
    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(SpotlightPreference.self) { targets in
                GeometryReader { geometry in
                    ...

                    let target = viewModel.target
                        .flatMap { targets[$0.key] }
                    let focus = target
                        .flatMap { geometry[$0.anchor] }
                    
                    Overlay(focus: focus, container: container)
                        ...
                        .focusNext(viewModel.targetNext)
                        .focusNone(viewModel.targetNone)
                        ...
                }
            }
    }
}
```

<br>

Finally, sending a `Spotlight` model to the publisher we passed to `.presentSpotlight(_:,_:)` will initiate a sequence. The order of element keys controls the order of the focused elements.
```swift
struct ExampleApp: App {
    let publisher: CurrentValueSubject<Spotlight?, Never>
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .presentSpotlight(publisher)
                .onAppear(start)
        }
    }
    
    private func start() {
        // Changing the order or adding/removing elements
        // is trivial. New sequences are easy to generate.
        let elements = [
            Spotlight.Element(key: "element.key.1", message: "Message 1!"),
            Spotlight.Element(key: "element.key.2", message: "Message 2!"),
            Spotlight.Element(key: "element.key.3", message: "Message 3!")
        ]
        let spotlight = Spotlight(elements: elements, cancellable: true)
        
        publisher.send(spotlight);
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Example Element 1")
                .spotlightElement(key: "element.key.1")
            Text("Example Element 2")
                .spotlightElement(key: "element.key.2")
        }
        .spotlightElement(key: "element.key.3")
    }
}
```

<br>

After walking through how the system works, observe how simple it is to define spotlight elements, arrange and rearrange sequences, control when the sequence is played, and specify what your overlay looks like!

</details>

<details>
    
<summary>Code Testing</summary>
    
### Code Testing

Code design is partially justified by its testability. After all, how can you endorse the advantages of the design if you haven't validated it with tests?

The challenge of architecting UI-focused code tends to come down to deciding where to draw the line between the UI frameworks and our "operational" logic. This is especially tricky when working with SwiftUI. UI logic is often encapsulated in `View` declarations, so unit testing can be difficult.

Let's look at the spotlight system again, this time focusing on how it separates concerns for testability.

The bulk of the computational logic ideal for unit testing revolves around the spotlight interaction behavior and any computation we might use to render a `FocusOverlay` implementation (like computing where an element message should be rendered based on the focus frame).
To make sure such view-agnostic logic could be tested, we opted for two patterns:
* MVVM: to abstract the interaction behavior away from the view into models.
* Strategy Pattern: to abstract rendering computation away from the view into an object.

The MMVM pattern was implemented much as you would expect. The `SpotlightViewModifier` (our view) utilizes a `SpotlightViewModel` that contains the data model (`Spotlight`) and attributes to control view behavior.
```swift
class SpotlightViewModel: ObservableObject {
    @Published private(set) var target: Spotlight.Element?
    
    var cancellable: Bool { ... }
    var isActive: Bool { ... }

    private var pointer = Int.zero
    private var sink: AnyCancellable?
    private var spotlight: Spotlight?

    func targetNone() { ... }
    func targetNext() { ... }
}
```

<br>

This affords us the ability to test the spotlight view behavior in a vacuum. For example, `SpotlightViewModelTests` can test that the spotlight is interactable after receiving a spotlight sequence.
```swift
func test_is_active_after_receiving_sequence() {
    let testPublisher = CurrentValueSubject<Spotlight?, Never>(nil)
    let testViewModel = SpotlightViewModel(publisher: testPublisher)
    let element = Spotlight.Element(
        key: "test.element",
        message: "Test Message"
    )
    let spotlight = Spotlight(
        elements: [element],
        cancellable: true
    )
    
    testPublisher.send(spotlight)
    XCTAssertTrue(
        testViewModel.isActive,
        "Incorrect `isActive` value at start of sequence."
    )
}
```

<br>

In our `FocusOverlay` implementation, we implemented a form of the Strategy pattern by abstracting view-related algorithms into a layout object.
```swift
extension DefaultOverlay {
    // Object is inspired by UIKit's `UICollectionViewLayout`. 
    struct Layout {
        func traits(for shape: Spotlight.Element.Shape) -> Traits { ... }

        // Our overlay implementation computes the cutout shape
        // using a rounded rectangle.
        struct Traits {
            let cornerRadius: CGFloat
            let focus: CGRect
            let messageAlignment: Alignment
            
            init(
                focus: CGRect,
                cornerRadius: CGFloat,
                messageAlignment: Alignment
            ) {
                self.focus = focus
                self.cornerRadius = cornerRadius
                self.messageAlignment = messageAlignment
            }
        }
    }
}
```

<br>

Similarly to the MVVM pattern abstraction, this abstraction allows us to verify that the correct visual attributes are computed for our overlay. In `DefaultOverlayLayoutTests`, we can validate the correct message alignment given a focus frame and container.
```swift
func test_message_alignment_for_focus_above_horizon() {
    let testContainer = CGRect(
        origin: .zero, 
        size: CGSize(width: 100, height: 100)
    )
    let size = CGSize(width: 10, height: 10)
    let focus = CGRect(origin: .zero, size: size)
    let traits = DefaultOverlay.Layout(
        focus: focus,
        container: testContainer
    )
    .traits(for: .circle)
    
    XCTAssertEqual(
        traits.messageAlignment, .bottom,
        "Incorrect Message alignment for focus trait above horizon."
    )
}
```

<br>

Hopefully, we were able to shed some insight into how our UI-focused logic can still be testable. 
    
</details>

###### Do you agree that the design is adaptative and easy to use? Have any questions, comments, or just want to give feedback? Share your ideas with me on social media:
[![LinkedIn](https://img.shields.io/static/v1?style=social&logo=linkedin&label=LinkedIn&message=Tre%27Ellis%20Cooper)](https://www.linkedin.com/in/tre-ellis-cooper-629306106/)&nbsp;
[![Twitter](https://img.shields.io/static/v1?style=social&logo=twitter&label=Twitter&message=@_cooperlative)](https://www.twitter.com/_cooperlative/)&nbsp;
[![Instagram](https://img.shields.io/static/v1?style=social&logo=instagram&label=Instagram&message=@_cooperlative)](https://www.instagram.com/_cooperlative/)
