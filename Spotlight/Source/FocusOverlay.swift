//
//  FocusOverlay.swift
//  Spotlight
//
//  Created by Tre Cooper on 4/21/23.
//

import SwiftUI

/// A protocol that defines the contract for a spotlight
/// overlay implementation.
///
/// - note: The `SpotlightViewModifier` overlays an instance of this
///         protocol on its receiver. See `SpotlightViewModifier` for
///         more details.
protocol FocusOverlay: View {
    init(focus: CGRect?, container: CGRect)
    
    func cancellable(_ cancellable: Bool) -> Self
    func focusNext(_ focusNext: @escaping () -> Void) -> Self
    func focusNone(_ focusNone: @escaping () -> Void) -> Self
    func focusShape(_ shape: Spotlight.Element.Shape) -> Self
    func message(_ message: String?) -> Self
}
