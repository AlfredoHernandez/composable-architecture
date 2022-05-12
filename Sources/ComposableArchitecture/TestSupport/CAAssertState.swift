//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

public struct Step<Value: Equatable, Action> {
    public enum StepType {
        case send(Action, (inout Value) -> Void)
        case receive(Action, (inout Value) -> Void)
        case fireAndForget
    }

    let type: StepType
    let file: StaticString
    let line: UInt

    public init(_ type: StepType, file: StaticString = #filePath, line: UInt = #line) {
        self.type = type
        self.file = file
        self.line = line
    }
}

public func CAAssertState<Value: Equatable, Action: Equatable>(
    initialValue: Value,
    reducer: Reducer<Value, Action>,
    steps: Step<Value, Action>...,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    var state = initialValue
    var effects = [Effect<Action>]()
    steps.forEach { step in
        var expected = state
        switch step.type {
        case let .send(action, update):
            if !effects.isEmpty {
                XCTFail("Action sent before handling \(effects.count) pending effect(s).", file: step.file, line: step.line)
            }
            effects.append(contentsOf: reducer(&state, action))
            update(&expected)
            XCTAssertEqual(state, expected, file: step.file, line: step.line)
        case let .receive(expectedAction, update):
            guard !effects.isEmpty else {
                XCTFail("No pending effects to receive from", file: step.file, line: step.line)
                break
            }
            let expectation = XCTestExpectation(description: "Wait for receiveCompletion")
            var action: Action!
            let effect = effects.removeFirst()
            _ = effect.sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { action = $0 })
            if XCTWaiter.wait(for: [expectation], timeout: 1.0) != .completed {
                XCTFail("Timed out waiting for the effect to complete", file: step.file, line: step.line)
            }
            XCTAssertEqual(action, expectedAction, file: step.file, line: step.line)
            effects.append(contentsOf: reducer(&state, action))
            update(&expected)
            XCTAssertEqual(state, expected, file: step.file, line: step.line)
        case .fireAndForget:
            guard !effects.isEmpty else {
                XCTFail("No pending effects to run", file: step.file, line: step.line)
                break
            }
            let effect = effects.removeFirst()
            let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
            _ = effect.sink(
                receiveCompletion: { _ in
                    receivedCompletion.fulfill()
                },
                receiveValue: { _ in XCTFail() }
            )
            if XCTWaiter.wait(for: [receivedCompletion], timeout: 1.0) != .completed {
                XCTFail("Timed out waiting for the effect to complete", file: step.file, line: step.line)
            }
        }
    }

    if !effects.isEmpty {
        XCTFail("Assertion failed to handle: There is/are \(effects.count) pending effect(s).", file: file, line: line)
    }
}
