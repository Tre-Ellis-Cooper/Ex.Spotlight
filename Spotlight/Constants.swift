//
//  Constants.swift
//  SpotlightTest
//
//  Created by Tre Cooper on 3/15/23.
//

import SwiftUI

typealias Strings = Constants.Strings
typealias Colors = Constants.Assets.Colors
typealias Icons = Constants.Assets.Icons
typealias Keys = Constants.Onboarding.Keys

/// An enum housing general constants for the example app.
enum Constants {
    enum Assets {
        enum Keys {
            // Colors
            static let highlightColor = "HighlightColor"
            static let primaryBackgroundColor = "PrimaryBackgroundColor"
            static let primaryTextColor = "PrimaryTextColor"
            static let secondaryBackgroundColor = "SecondaryBackgroundColor"
            static let secondaryTextColor = "SecondaryTextColor"
            
            // Icons
            static let playIcon = "play.circle"
            static let photoIcon = "photo"
        }
        
        enum Colors {
            static let highlight = Color(Keys.highlightColor)
            static let primaryText = Color(Keys.primaryTextColor)
            static let secondaryText = Color(Keys.secondaryTextColor)
            static let primaryBackground = Color(Keys.primaryBackgroundColor)
            static let secondaryBackground =
                Color(Keys.secondaryBackgroundColor)
        }
        
        enum Icons {
            static let play = Image(systemName: Keys.playIcon)
            static let photo = Image(systemName: Keys.photoIcon)
        }
    }
    
    enum Strings {
        static let ex = "Ex."
        static let deploymentTarget = "Target: iOS \(Utility.minimumOS)"
        static let infoCategory = "Info Category"
        static let spotlight = "Spotlight"
        static let thatCardHeadingFormat = "That Section Card Heading %d"
        static let thatCardInfo = "A description exerpt that may intice "
            + "one to view the complete information."
        static let thatSection = "That Section"
        static let thisCardHeadingFormat = "This Section Card Heading %d"
        static let thisSection = "This Section"
        static let seeMore = "See more   →"
    }
    
    enum Utility {
        static let notAvailable = "N/A"
        static let minimumOSKey = "MinimumOSVersion"
        static let minimumOS = Bundle.main.infoDictionary?[minimumOSKey]
            as? String ?? notAvailable
    }
    
    enum Onboarding {
        static let homeSequence = Spotlight(
            elements: [
                Spotlight.Element(
                    key: Keys.heading,
                    message: Messages.heading
                ),
                Spotlight.Element(
                    key: String(format: Keys.thisCardFormat, 1),
                    message: Messages.thisCard
                ),
                Spotlight.Element(
                    key: String(format: Keys.thisCardFormat, 2),
                    message: Messages.thisCard
                ),
                Spotlight.Element(
                    key: String(format: Keys.thisCardInfoFormat, 1),
                    message: Messages.thisCardInfo
                ),
                Spotlight.Element(
                    key: Keys.thatSection,
                    message: Messages.thatSection
                ),
                Spotlight.Element(
                    key: String(format: Keys.thatCardFormat, 1),
                    message: Messages.thatCard
                ),
                Spotlight.Element(
                    key: String(format: Keys.thatCardImageFormat, 1),
                    message: Messages.thatCardImage
                ),
                Spotlight.Element(
                    key: Keys.start,
                    message: Messages.start
                )
            ],
            cancellable: true
        )
        
        enum Keys {
            static let heading = "spotlight.heading"
            static let start = "spotlight.start"
            static let targetOS = "spotlight.targetOS"
            static let thatCardFormat = "spotlight.that.card.%d"
            static let thatCardImageFormat = "spotlight.that.card.image.%d"
            static let thatSection = "spotlight.that.section"
            static let thisCardFormat = "spotlight.this.card.%d"
            static let thisCardHeadingFormat = "spotlight.this.card.heading.%d"
            static let thisCardInfoFormat = "spotlight.this.card.info.%d"
            static let thisSection = "spotlight.this.section"
        }
        
        enum Messages {
            static let heading = "Welcome to Ex. Spotlight! This example"
                + " system was designed to demonstrate a cool, yet modular"
                + " and easily-extendable approach to generating onboarding"
                + " sequences."
            static let start = "You can replay this sequence at any time"
                + " using this play button. Feel free to experiment with"
                + " changing this sequence by modifying the target elements."
            static let thisCard = "This card represents an instance of this"
                + " section's information."
            static let thisCardInfo = "This card text describe's the full"
                + " information."
            static let thisSection = "This section contains information cards"
                + " arranged horizontally for your viewing pleasure."
            static let thatCard = "That card represents an instance of that"
                + " section's information."
            static let thatCardImage = "That card image provide's a visual"
                + " representation of the full information"
            static let thatSection = "That section contains information cards"
                + " arranged vertically, also for your viewing pleasure."
        }
    }
}
