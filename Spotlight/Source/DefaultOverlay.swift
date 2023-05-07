//
//  DefaultOverlay.swift
//  Spotlight
//
//  Created by Tre Cooper on 4/2/23.
//

import SwiftUI

private typealias Colors = SpotlightConstants.Assets.Colors
private typealias Strings = SpotlightConstants.Strings

/// The default overlay demonstrating how one might focus elements
/// and present messages during a spotlight sequence.
///
/// - note: See the `FocusOverlay` protocol for an explanation
///         of the contract and how it is used.
struct DefaultOverlay: FocusOverlay {
    let focus: CGRect?
    let container: CGRect
    
    var cancellable = true
    var focusNext: () -> Void = {}
    var focusNone: () -> Void = {}
    var focusShape = Spotlight.Element.Shape.circle
    var message: String?
    
    init(focus: CGRect?, container: CGRect) {
        self.focus = focus
        self.container = container
    }
    
    var body: some View {
        let traits = Layout(focus: focus, container: container)
            .traits(for: focusShape)
        
        ZStack(alignment: traits.messageAlignment) {
            Mask(focus: traits.focus, cornerRadius: traits.cornerRadius)
            if let message = message {
                DialogueBox(message: message)
            }
        }
        .animation(.spring(), value: traits.focus)
    }
    
    /// Sets the cancellable property for the overlay element.
    ///
    /// - parameter cancellable: The desired cancellable value.
    func cancellable(_ cancellable: Bool) -> Self {
        set(\.cancellable, to: cancellable)
    }
    
    /// Sets the confirm closure for the overlay element.
    ///
    /// - parameter onConfirm: The desired confirm closure.
    func focusNext(_ focusNext: @escaping () -> Void) -> Self {
        set(\.focusNext, to: focusNext)
    }
    
    /// Sets the dismiss closure for this element.
    ///
    /// - parameter onDismiss: The desired dismiss closure.
    func focusNone(_ focusNone: @escaping () -> Void) -> Self {
        set(\.focusNone, to: focusNone)
    }
    
    /// Sets the focus shape for this element.
    ///
    /// - parameter shape: The desired focus shape.
    func focusShape(_ shape: Spotlight.Element.Shape) -> Self {
        set(\.focusShape, to: shape)
    }
    
    /// Sets the message property for the overlay element.
    ///
    /// - parameter message: The desired message value.
    func message(_ message: String?) -> Self {
        set(\.message, to: message)
    }
}

// MARK: - Helper Functions / Sub-Components
extension DefaultOverlay {
    private func set<Value>(
        _ keyPath: WritableKeyPath<Self, Value>,
        to value: Value
    ) -> Self {
        var newSelf = self
        newSelf[keyPath: keyPath] = value
        return newSelf
    }
    
    @ViewBuilder private func Mask(
        focus: CGRect,
        cornerRadius: CGFloat
    ) -> some View {
        ZStack {
            Colors.dimColor
                .edgesIgnoringSafeArea(.all)
            RoundedRectangle(cornerRadius: cornerRadius)
                .blendMode(.destinationOut)
                .frame(width: focus.width, height: focus.height)
                .position(x: focus.midX, y: focus.midY)
        }
        .compositingGroup()
    }
    
    @ViewBuilder private func DialogueBox(
        message: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(message)
                .animation(nil)
            HStack(spacing: 4) {
                Spacer()
                if cancellable {
                    Button(action: focusNone) {
                        Text(Strings.dismiss)
                            .padding(12)
                    }
                }
                Button(action: focusNext) {
                    Text(Strings.next)
                        .padding(12)
                        .foregroundColor(Colors.highlight)
                        .background(Colors.primaryBackground)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                }
            }
        }
        .padding(12)
        .font(.footnote.bold())
        .foregroundColor(Colors.primaryBackground)
        .background(Colors.highlight)
        .padding(.trailing, 30)
        .drawingGroup()
    }
}

// MARK: - DefaultOverlay.Layout
extension DefaultOverlay {
    /// A helper object to compute the visual traits of this overlay.
    ///
    /// - note: This object was inspired by the UICollectionViewLayout object.
    ///         It's purpose is to isolate any view cacluations and be
    ///         testable in a vacuum.
    ///         See `DefaultOverlayLayoutTests.swift`.
    struct Layout {
        let focus: CGRect?
        let container: CGRect
        
        /// Computes and returns the layout traits for the
        /// provided spotlight element.
        ///
        /// - parameter element: Intended spotlight element.
        /// - returns: A trait object housing the focus frame, focus shape,
        ///            and message alignment for the intended element.
        func traits(for shape: Spotlight.Element.Shape) -> Traits {
            let rect = focus ?? container
            let focusShape = focusShape(for: rect, with: shape)
            let messageAlignment = messageAlignment(for: focusShape.rect)
            
            return Traits(
                focus: focusShape.rect,
                cornerRadius: focusShape.cornerRadius,
                messageAlignment: messageAlignment
            )
        }
        
        private func focusShape(
            for rect: CGRect,
            with shape: Spotlight.Element.Shape
        ) -> (rect: CGRect, cornerRadius: CGFloat) {
            switch shape {
            case .circle:
                let rect = rect.boundingCircleFrame()
                return (rect, rect.height / 2)
            case .rectangle(let cornerRadius):
                let rect = rect.insetBy(
                    dx: -cornerRadius / 2,
                    dy: -cornerRadius / 2
                )
                return (rect, cornerRadius)
            }
        }
        
        private func messageAlignment(for frame: CGRect) -> Alignment {
            return frame.midY < container.midY ?
            Alignment.bottom :
            Alignment.top
        }
        
        // MARK: - Layout.Traits
        /// A struct modeling the layout traits for this overlay.
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

/// Convenience extension for CGRect helper functions and routines.
extension CGRect {
    /// Routine to calculate the rectangle for the bounding circle of
    /// the current rectangle.
    ///
    /// - returns: A rectangle who's width and height were set to the
    ///            original rectangle's diagonal length (which is the
    ///            diameter of the bounding circle).
    func boundingCircleFrame() -> CGRect {
        // Diameter of bounding cirlce == frame diagonal
        let diagonal = sqrt(pow(width, 2) + pow(height, 2))
        let dx = -(diagonal - width) / 2
        let dy = -(diagonal - height) / 2
        
        return insetBy(dx: dx, dy: dy)
    }
}
