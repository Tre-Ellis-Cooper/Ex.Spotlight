//
//  SpotlightApp.swift
//  SpotlightTest
//
//  Created by Tre Cooper on 2/26/21.
//

import SwiftUI
import Combine

@main
struct SpotlightApp: App {
    @ObservedObject var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .presentSpotlight(appModel.spotlight)
                .environmentObject(appModel)
        }
    }
}

// MARK: - AppModel

/// An example app model.
///
/// - note: `AppModel` is intended to be injected as an environment
///         variable so that any view may access the spotlight publisher and
///         start spotlight sequences.
final class AppModel: ObservableObject {
    let spotlight: CurrentValueSubject<Spotlight?, Never>
    
    init(spotlight: CurrentValueSubject<Spotlight?, Never> = .init(nil)) {
        self.spotlight = spotlight
    }
}
