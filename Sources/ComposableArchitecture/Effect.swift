//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct Effect<A> {
    public let run: (@escaping (A) -> Void) -> Void

    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }

    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        Effect<B> { callback in
            self.run { a in callback(f(a)) }
        }
    }
}
