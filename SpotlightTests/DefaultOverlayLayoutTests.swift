//
//  DefaultOverlayLayoutTests.swift
//  SpotlightTests
//
//  Created by Tre Cooper on 3/29/23.
//

import XCTest

@testable import Spotlight

class DefaultOverlayLayoutTests: XCTestCase {
    var testContainer: CGRect!
    var testSize: CGSize!
    
    override func setUp() {
        super.setUp()
        
        testSize = .init(width: 100, height: 100)
        testContainer = .init(origin: .zero, size: testSize)
    }
    
    func test_focus_trait_for_focus_frame_and_circle_shape() {
        let size = CGSize(width: 10, height: 10)
        let focus = CGRect(origin: .zero, size: size)
        let traits = DefaultOverlay.Layout(
            focus: focus,
            container: testContainer
        )
        .traits(for: .circle)
        
        XCTAssertEqual(
            traits.focus, focus.boundingCircleFrame(),
            "Incorrect focus trait with circle shape."
        )
    }
    
    func test_focus_trait_for_nil_focus_frame_and_circle_shape() {
        let traits = DefaultOverlay.Layout(
            focus: nil,
            container: testContainer
        )
        .traits(for: .circle)
        
        XCTAssertEqual(
            traits.focus, testContainer.boundingCircleFrame(),
            "Incorrect focus trait with nil focus and circle shape."
        )
    }
    
    func test_focus_trait_for_focus_frame_and_rectangle_shape() {
        let size = CGSize(width: 10, height: 10)
        let focus = CGRect(origin: .zero, size: size)
        let traits = DefaultOverlay.Layout(
            focus: focus,
            container: testContainer
        )
        .traits(for: .rectangle(cornerRadius: 8))
        
        XCTAssertEqual(
            traits.focus, focus.insetBy(dx: -4, dy: -4),
            "Incorrect focus trait with circle shape."
        )
    }
    
    func test_focus_trait_for_nil_focus_frame_and_rectangle_shape() {
        let traits = DefaultOverlay.Layout(
            focus: nil,
            container: testContainer
        )
        .traits(for: .rectangle(cornerRadius: 8))
        
        XCTAssertEqual(
            traits.focus, testContainer.insetBy(dx: -4, dy: -4),
            "Incorrect focus trait with nil focus and rectangle shape."
        )
    }
    
    func test_corner_radius_for_focus_frame_and_circle_shape() {
        let size = CGSize(width: 10, height: 10)
        let focus = CGRect(origin: .zero, size: size)
        let traits = DefaultOverlay.Layout(
            focus: focus,
            container: testContainer
        )
        .traits(for: .circle)

        XCTAssertEqual(
            traits.cornerRadius, focus.boundingCircleFrame().height / 2,
            "Incorrect corner radius with nil focus and circle shape."
        )
    }
    
    func test_corner_radius_for_nil_focus_frame_and_circle_shape() {
        let traits = DefaultOverlay.Layout(
            focus: nil,
            container: testContainer
        )
        .traits(for: .circle)

        XCTAssertEqual(
            traits.cornerRadius, testContainer.boundingCircleFrame().height / 2,
            "Incorrect corner radius with nil focus and circle shape."
        )
    }
    
    func test_corner_radius_for_focus_frame_and_rectangle_shape() {
        let size = CGSize(width: 10, height: 10)
        let focus = CGRect(origin: .zero, size: size)
        let traits = DefaultOverlay.Layout(
            focus: focus,
            container: testContainer
        )
        .traits(for: .rectangle(cornerRadius: 8))

        XCTAssertEqual(
            traits.cornerRadius, 8,
            "Incorrect corner radius with rectangle shape."
        )
    }
    
    func test_corner_radius_for_nil_focus_frame_and_rectangle_shape() {
        let containerSize = CGSize(width: 100, height: 100)
        let container = CGRect(origin: .zero, size: containerSize)
        let traits = DefaultOverlay.Layout(
            focus: nil,
            container: container
        )
        .traits(for: .rectangle(cornerRadius: 8))

        XCTAssertEqual(
            traits.cornerRadius, 8,
            "Incorrect corner radius with nil focus and rectangle shape."
        )
    }
    
    func test_message_alignment_for_focus_above_horizon() {
        let size = CGSize(width: 10, height: 10)
        let focus = CGRect(origin: .zero, size: size)
        let traits = DefaultOverlay.Layout(
            focus: focus,
            container: testContainer
        )
        .traits(for: .circle)
        
        XCTAssertEqual(
            traits.messageAlignment, .bottom,
            "Incorrect Message alignment for focus trait above horizon."
        )
    }
    
    func test_message_alignment_for_focus_below_horizon() {
        let size = CGSize(width: 10, height: 10)
        let origin = CGPoint(x: .zero, y: testContainer.maxY - 10)
        let focus = CGRect(origin: origin, size: size)
        let traits = DefaultOverlay.Layout(
            focus: focus,
            container: testContainer
        )
        .traits(for: .circle)
        
        XCTAssertEqual(
            traits.messageAlignment, .top,
            "Incorrect Message alignment for focus trait above horizon."
        )
    }
}
