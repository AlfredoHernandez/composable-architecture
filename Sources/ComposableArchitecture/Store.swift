//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import SwiftUI

public typealias Reducer<Value, Action, Environment> = (inout Value, Action, Environment) -> [Effect<Action>]

public final class Store<Value, Action>: ObservableObject {
    private let reducer: Reducer<Value, Action, Any>
    private let environment: Any
    @Published public private(set) var value: Value
    private var viewCancellable: Cancellable?
    private var effectCancellables = Set<AnyCancellable>()

    public init<Environment>(initialValue: Value, reducer: @escaping Reducer<Value, Action, Environment>, environment: Environment) {
        self.reducer = { value, action, environment in
            reducer(&value, action, environment as! Environment)
        }
        self.value = initialValue
        self.environment = environment
    }

    public func send(_ action: Action ) {
        let effects = reducer(&value, action, environment)
        effects.forEach { effect in
            effect.sink(receiveValue: self.send)
            .store(in: &effectCancellables)
        }
    }

    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(value),
            reducer: { localValue, localAction, _ in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            },
            environment: environment
        )
        localStore.viewCancellable = $value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
}
