//
//  Card.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

struct Card {
    let suit: Suit
    let value: Value

    static func deck() -> [Card] {
        var cards: [Card] = []
        for suit in Suit.values {
            for value in Value.values {
                cards.append(Card(suit: suit, value: value))
            }
        }
        return cards
    }
}


extension Card: Equatable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.value == rhs.value
    }
}


extension Card: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(value)\(suit)"
    }
}
