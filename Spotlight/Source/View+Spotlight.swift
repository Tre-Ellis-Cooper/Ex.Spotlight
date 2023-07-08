//
//  View+Spotlight.swift
//  SpotlightTest
//
//  Created by Tre Cooper on 6/18/22.
//

import SwiftUI
import Combine

/// Convenience extension to make creating spotlight
/// views and spotlight elements easier to invoke.
extension View {
    /// Convenience method that makes the calling view a spotlight presenter.
    ///
    /// The provided publisher serves as the spotlight queue. Any spotlight
    /// seqeunces pushed to the provided publisher will be rendered
    /// by this view.
    ///
    /// - note: Experiment with creating your own `FocusOverlay`
    ///         implementation and setting it as the associated type! See
    ///         `DefaultOverlay` for the current implementation.
    ///
    /// - parameter publisher: The spotlight publisher for this presenter.
    /// - parameter type: The `FocusOverlay` type for this presenter.
    func presentSpotlight<P: Publisher, F: FocusOverlay>(
        _ publisher: P,
        using type: F.Type = DefaultOverlay.self
    ) -> some View where P.Output == Spotlight?, P.Failure == Never {
        self.modifier(
            SpotlightViewModifier<F>(viewModel: .init(publisher: publisher))
        )
    }
    
    /// Convenience method that turns a view element into a spotlight element.
    ///
    /// The calling view associates its frame data with the provided key and
    /// shape, making it available via the `SpotlightPreference`.
    ///
    /// - parameter key: The element key.
    /// - parameter shape: The desired spotlight shape.
    func spotlightElement(
        key: Spotlight.Element.Key,
        shape: Spotlight.Element.Shape = .circle
    ) -> some View {
        self.transformAnchorPreference(
            key: SpotlightPreference.self,
            value: .bounds,
            transform: { $0[key] = .init(anchor: $1, shape: shape) }
        )
    }
}
