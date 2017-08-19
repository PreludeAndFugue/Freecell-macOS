//
//  Cell.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Cell: CanAddCard {

    var state: State = .empty


    func contains(card: Card) -> Bool {
        switch state {
        case .empty: return false
        case .card(let currentCard): return card == currentCard
        }
    }

    
    func canAdd(card: Card) -> Bool {
        switch state {
        case .empty:
            return true
        default:
            return false
        }
    }


    func add(card: Card) throws {
        if canAdd(card: card) {
            state = .card(card)
        } else {
            throw GameError.invalidMove
        }
    }


    func removeCard() {
        state = .empty
    }


    func reset() {
        state = .empty
    }
}


extension Cell: CustomDebugStringConvertible {
    var debugDescription: String {
        switch state {
        case .empty:
            return ".."
        case .card(let card):
            return card.debugDescription
        }
    }
}
