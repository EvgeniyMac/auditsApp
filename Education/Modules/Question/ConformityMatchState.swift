//
//  ConformityMatchState.swift
//  Education
//
//  Created by Andrey Medvedev on 27/04/2019.
//  Copyright © 2019 ООО Офис 365. All rights reserved.
//

import Foundation

class ConformityMatchState {

    private var items = [ConformityMatchState.Item]()
    class Item {
        var key: String
        var value: String?
        var separator: String
        var isCorrect: Bool?

        init(key: String,
             value: String?,
             separator: String = " ",
             isCorrect: Bool? = nil) {
            self.key = key
            self.value = value
            self.separator = separator
            self.isCorrect = isCorrect
        }
    }

    func itemWithKey(_ key: String) -> ConformityMatchState.Item? {
        return items.first(where: { (item) -> Bool in
            item.key == key
        })
    }

    func firstItemWithoutValue() -> ConformityMatchState.Item? {
        return items.first(where: { (item) -> Bool in
            item.value == nil
        })
    }

    func itemAt(index: Int) -> ConformityMatchState.Item? {
        guard index < self.items.count else {
            return nil
        }
        return self.items[index]
    }

    func hasItemWithValue(_ value: String) -> Bool {
        return items.contains(where: { (item) -> Bool in
            return item.value == value
        })
    }

    func toDictionary() -> [String : String]? {
        guard !items.contains(where: { $0.value == nil }) else {
            return nil
        }

        var result = [String : String]()
        for item in items {
            result[item.key] = item.value
        }
        return result
    }

    func toArray() -> [String]? {
        guard !items.contains(where: { $0.value == nil }) else {
            return nil
        }

        return items.compactMap({ $0.value })
    }

    func markEmptyValuesAsIncorrect() {
        for item in items {
            if item.value == nil {
                item.isCorrect = false
            }
        }
    }

    func isConformityCompleted() -> Bool {
        return !self.items.contains(where: { (item) -> Bool in
            return item.value == nil
        })
    }

    // MARK: - Static
    static func from(keys: [String],
                     dictionary: [String : String]?,
                     answers: [Answer]?) -> ConformityMatchState {
        let state = ConformityMatchState()
        for keyItem in keys.enumerated() {
            let value = dictionary?[keyItem.element]
            var isCorrect: Bool?
            if let value = value,
                let answer = answers?.first(where: { $0.key == keyItem.element }) {
                isCorrect = (value == answer.value)
            }
            state.items.append(Item(key: keyItem.element, value: value, isCorrect: isCorrect))
        }
        return state
    }

    static func from(keys: [String],
                     array: [String]?,
                     answers: [Answer]?) -> ConformityMatchState {
        let state = ConformityMatchState()
        for keyItem in keys.enumerated() {
            var value: String?
            var isCorrect: Bool?
            if keyItem.offset < (array?.count ?? 0),
                let arrayItemValue = array?[keyItem.offset] {
                value = arrayItemValue
                isCorrect = (value == answers?[keyItem.offset].value)
            }
            state.items.append(Item(key: keyItem.element, value: value, isCorrect: isCorrect))
        }
        return state
    }
}

