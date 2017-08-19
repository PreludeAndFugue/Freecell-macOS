//
//  Foundation.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Foundation: CanAddCard {

    var state: State = .empty

    var isEmpty: Bool {
        switch state {
        case .empty: return true
        default: return false
        }
    }


    func contains(card: Card) -> Bool {
        switch state {
        case .empty: return false
        case .card(let currentCard): return card == currentCard
        }
    }

    func canAdd(card: Card) -> Bool {
        switch state {
        case .empty:
            return card.value == .ace
        case .card(let currentCard):
            return card.suit == currentCard.suit && card.value.rawValue - currentCard.value.rawValue == 1
        }
    }


    func add(card: Card) throws {
        if canAdd(card: card) {
            state = .card(card)
        } else {
            throw GameError.invalidMove
        }
    }


    var isDone: Bool {
        switch state {
        case .card(let card):
            return card.value == .king
        case .empty:
            return false
        }
    }


    func reset() {
        state = .empty
    }
}


extension Foundation: CustomDebugStringConvertible {
    var debugDescription: String {
        switch state {
        case .empty:
            return ".."
        case .card(let card):
            return card.debugDescription
        }
    }
}
