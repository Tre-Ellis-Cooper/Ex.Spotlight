//
//  SpotlightViewModel.swift
//  SpotlightTest
//
//  Created by Tre Cooper on 1/25/23.
//

import Combine

/// An object representing the state of a spotlight view.
class SpotlightViewModel: ObservableObject {
    @Published private(set) var target: Spotlight.Element?
    
    var cancellable: Bool { spotlight?.cancellable ?? true }
    var isActive: Bool { target != nil }
    
    private var pointer = Int.zero
    private var sink: AnyCancellable?
    private var spotlight: Spotlight?
    
    init<T: Publisher>(
        publisher: T
    ) where T.Output == Spotlight?, T.Failure == Never {
        sink = publisher.sink(receiveValue: setSpotlight)
    }
    
    /// Routine to end the current spotlight sequence by setting the
    /// intended target to `nil`.
    func targetNone() {
        target = nil
    }
    
    /// Routine to target the next element in the spotlight sequence.
    ///
    /// - note: Ends the sequence if targeting the final element.
    func targetNext() {
        let elements = spotlight?.elements
        let element = elements?[safe: pointer]
        
        if element != nil {
            pointer += 1
        }
        
        target = element
    }
}

// MARK: - Helper Functions / Routines
extension SpotlightViewModel {
    private func setSpotlight(_ spotlight: Spotlight?) {
        self.spotlight = spotlight
        self.pointer = .zero
        
        targetNext()
    }
}

/// Convenience extension for Collection helper functions and routines.
private extension Collection {
    /// A subscript to safely index the receiving collection.
    ///
    /// - parameter index: The index to query.
    /// - returns: The element at the given index or `nil`
    ///            if the index is invalid.
    subscript (safe index: Index) -> Element? {
        let inRange = index >= startIndex && index < endIndex
        return !isEmpty && inRange ? self[index] : nil
    }
}
