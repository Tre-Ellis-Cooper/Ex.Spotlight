//
//  SpotlightViewModifier.swift
//  SpotlightTest
//
//  Created by Tre Cooper on 1/25/23.
//

import SwiftUI

private typealias Preference = SpotlightPreference

/// A view modifier that makes its receiver a spotlight presenter.
///
/// - note: The calling view is overlayed with a `FocusOverlay`
///         implementation. The specified implementation is provided the
///         relevant information to focus the current target and handle
///         interaction behavior. See `DefaultOverlay`.
struct SpotlightViewModifier<Overlay: FocusOverlay>: ViewModifier {
    @ObservedObject var viewModel: SpotlightViewModel
    
    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(Preference.self) { targets in
                GeometryReader { geometry in
                    let container = geometry.frame(in: .local)
                        .inset(by: -geometry.safeAreaInsets)
                    let target = viewModel.target
                        .flatMap { targets[$0.key] }
                    let focus = target
                        .flatMap { geometry[$0.anchor] }
                    
                    Overlay(focus: focus, container: container)
                        .message(viewModel.target?.message)
                        .focusShape(target?.shape ?? .circle)
                        .cancellable(viewModel.cancellable)
                        .focusNext(viewModel.targetNext)
                        .focusNone(viewModel.targetNone)
                        .allowsHitTesting(viewModel.isActive)
                }
            }
    }
}

/// Convenience extension for CGRect helper functions and routines.
private extension CGRect {
    /// A function to inset a rectangle using `SwiftUI.EdgeInsets`.
    ///
    /// - parameter insets: The desired insets.
    /// - returns: A rectangle inset by the desired insets.
    func inset(by insets: EdgeInsets) -> CGRect {
        let insets = UIEdgeInsets(
            top: insets.top,
            left: insets.leading,
            bottom: insets.bottom,
            right: insets.trailing
        )
        
        return inset(by: insets)
    }
}
