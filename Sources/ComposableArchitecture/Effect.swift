//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine

public struct Effect<Output>: Publisher {
    public typealias Failure = Never
    let publisher: AnyPublisher<Output, Failure>

    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
        self.publisher.receive(subscriber: subscriber)
    }
}

extension Publisher where Failure == Never {
    public func eraseToEffect() -> Effect<Output> {
        return Effect(publisher: self.eraseToAnyPublisher())
    }
}

extension Effect {
    public static func sync(work: @escaping () -> Output) -> Effect<Output> {
        return Deferred {
            Just(work())
        }.eraseToEffect()
    }
}
