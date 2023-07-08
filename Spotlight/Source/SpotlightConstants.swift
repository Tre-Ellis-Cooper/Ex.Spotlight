//
//  SpotlightConstants.swift
//  Spotlight
//
//  Created by Tre Cooper on 6/3/23.
//

import SwiftUI

/// An enum housing constants for the spotlight feature.
enum SpotlightConstants {
    enum Strings {
        static let dismiss = "Dismiss"
        static let next = "Next"
    }
    
    enum Assets {
        enum Keys {
            // Colors
            static let dimColor = "DimColor"
            static let highlightColor = "HighlightColor"
            static let primaryBackgroundColor = "PrimaryBackgroundColor"
        }
        
        enum Colors {
            static let dimColor = Color(Keys.dimColor)
            static let highlight = Color(Keys.highlightColor)
            static let primaryBackground = Color(Keys.primaryBackgroundColor)
        }
    }
}
