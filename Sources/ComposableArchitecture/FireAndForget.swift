//
//  File.swift
//  
//
//  Created by Jesús Alfredo Hernández Alarcón on 11/05/22.
//

import Combine

extension Publisher where Output == Never, Failure == Never {
    func fireAndForget<A>() -> Effect<A> {
        map(absurd)
            .eraseToEffect()
    }
}
