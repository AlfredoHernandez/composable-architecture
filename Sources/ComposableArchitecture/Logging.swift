//
//  Copyright © 2022 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

func logging<Value, Action>(
    _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
    { value, action in
        let effects = reducer(&value, action)
        let value = value
        return [
            Effect { _ in
                print("Action: \(action)")
                print("Value:")
                dump(value)
                print("=================")
            },
        ] + effects
    }
}
