//
//  SpotlightViewModelTests.swift
//  SpotlightTests
//
//  Created by Tre Cooper on 2/26/21.
//

import Combine
import XCTest

@testable import Spotlight

class SpotlightViewModelTests: XCTestCase {
    var testPublisher: CurrentValueSubject<Spotlight?, Never>!
    var testViewModel: SpotlightViewModel!

    override func setUp() {
        super.setUp()

        testPublisher = .init(nil)
        testViewModel = .init(publisher: testPublisher)
    }
    
    func test_default_cancellable() {
        XCTAssertTrue(
            testViewModel.cancellable,
            "Incorrect `cancellable` value."
        )
    }

    func test_is_cancellable() {
        let spotlight = Spotlight(elements: [], cancellable: true)
        
        testPublisher.send(spotlight)
        
        XCTAssertTrue(
            testViewModel.cancellable,
            "Incorrect `cancellable` value."
        )
    }
    
    func test_is_not_cancellable() {
        let spotlight = Spotlight(elements: [], cancellable: false)
        
        testPublisher.send(spotlight)
        
        XCTAssertFalse(
            testViewModel.cancellable,
            "Incorrect default `cancellable` value."
        )
    }
    
    func test_is_active_initial() {
        XCTAssertFalse(
            testViewModel.isActive,
            "Incorrect initial `isActive` value."
        )
    }
    
    func test_is_active_after_receiving_sequence() {
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
    
    func test_is_active_after_receiving_empty_sequence() {
        let spotlight = Spotlight(
            elements: [],
            cancellable: true
        )
        
        testPublisher.send(spotlight)
        XCTAssertFalse(
            testViewModel.isActive,
            "Incorrect `isActive` value with empty sequence."
        )
    }
    
    func test_is_active_during_sequence() {
        let count = Int.random(in: 1 ..< 5)
        let element = Spotlight.Element(
            key: "test.element",
            message: "Test Message"
        )
        let spotlight = Spotlight(
            elements: Array(repeating: element, count: count),
            cancellable: true
        )
        
        // View model is inactive to start.
        XCTAssertFalse(
            testViewModel.isActive,
            "Incorrect `isActive` value to start."
        )
        
        // View model should be active after receiving a sequence.
        testPublisher.send(spotlight)
        XCTAssertTrue(
            testViewModel.isActive,
            "Incorrect `isActive` value at start of sequence."
        )
        
        for _ in 0 ..< spotlight.elements.count - 1 {
            // View model should be active while targeting
            // elements in a sequence.
            testViewModel.targetNext()
            XCTAssertTrue(
                testViewModel.isActive,
                "Incorrect `isActive` value during sequence."
            )
        }
        
        // View model should not be active after finishing a sequence.
        testViewModel.targetNext()
        XCTAssertFalse(
            testViewModel.isActive,
            "Incorrect `isActive` value after sequence."
        )
    }
    
    func test_target_none_during_sequence() {
        let element = Spotlight.Element(
            key: "test.element",
            message: "Test Message"
        )
        let spotlight = Spotlight(
            elements: Array(repeating: element, count: 5),
            cancellable: true
        )
        
        // Simulate targeting none within a sequence at random.
        testPublisher.send(spotlight)
        for _ in 0 ..< spotlight.elements.count {
            guard Bool.random() else {
                testViewModel.targetNone()
                break
            }
            testViewModel.targetNext()
        }
        
        XCTAssertNil(
            testViewModel.target,
            "Incorrect `target` value after calling `targetNone`."
        )
    }
    
    func test_target_next_during_sequence() {
        let count = Int.random(in: 1 ..< 5)
        let element = Spotlight.Element(
            key: "test.element",
            message: "Test Message"
        )
        let spotlight = Spotlight(
            elements: Array(repeating: element, count: count),
            cancellable: true
        )
        
        // View model has no target to start.
        XCTAssertNil(
            testViewModel.target,
            "Incorrect `target` value to start."
        )
        
        // View model should target first element
        // after receiving a sequence.
        testPublisher.send(spotlight)
        XCTAssertEqual(
            testViewModel.target,
            spotlight.elements.first,
            "Incorrect `isActive` value at start of sequence."
        )
        
        for targetElement in spotlight.elements.dropFirst() {
            // View model should target the next element in
            // the sequence if possible.
            testViewModel.targetNext()
            XCTAssertEqual(
                targetElement,
                testViewModel.target,
                "Incorrect `target` value during sequence."
            )
        }
        
        // View model should not be targeting an element
        // after finishing a sequence.
        testViewModel.targetNext()
        XCTAssertNil(
            testViewModel.target,
            "Incorrect `target` value after sequence."
        )
    }
}
