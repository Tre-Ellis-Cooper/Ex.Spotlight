//
//  SpotlightPreference.swift
//  SpotlightTest
//
//  Created by Tre Cooper on 1/25/23.
//

import SwiftUI

/// Preference key that propogates the frame and focus shape
/// for a spotlight element.
struct SpotlightPreference: PreferenceKey {
    typealias Value = [Spotlight.Element.Key: Target]
    
    static var defaultValue: Value = [:]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - SpotlightPreference.Target
extension SpotlightPreference {
    /// A struct representing the `SpotlightPreference` payload
    /// for a particular spotlight element.
    struct Target {
        let anchor: Anchor<CGRect>
        let shape: Spotlight.Element.Shape
    }
}
