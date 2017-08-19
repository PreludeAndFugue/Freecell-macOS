//
//  Game.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

struct Game {

    // MARK: - Properties

    fileprivate let cells: [Cell]
    fileprivate let foundations: [Foundation]
    let cascades: [Cascade]

    private let cascadeConfig: [(Int, Int)] = [(0, 6), (7, 13), (14, 20), (21, 27), (28, 33), (34, 39), (40, 45), (46, 51)]


    // MARK: - Computed properties

    var isGameOver: Bool {
        return foundations.map({ $0.isDone }).reduce(true, { $0 && $1 })
    }


    // MARK: - Initialisers

    init() {
        let cards = Card.deck().shuffled()
        cells = [Cell(), Cell(), Cell(), Cell()]
        foundations = [Foundation(), Foundation(), Foundation(), Foundation()]
        cascades = cascadeConfig.map({ cards[$0.0 ... $0.1] }).map({ Array($0) }).map({ Cascade(cards: $0) })
    }


    // MARK: - Methods

    func canMove(card: Card) -> Bool {
        guard let location = location(from: card) else {
            return false
        }
        switch location {
        case .cell:
            return true
        case .foundation:
            return false
        case .cascade(let value):
            let cascade = cascades[value]
            return cascade.isBottom(card: card)
        }
    }


    func move(from fromLocation: Location, to toLocation: Location) throws {
        guard let card = card(at: fromLocation) else {
            throw GameError.invalidMove
        }
        try move(card: card, to: toLocation)
        switch fromLocation {
        case .cascade(let value):
            let cascade = cascades[value]
            cascade.removeBottom()
        case .cell(let value):
            let cell = cells[value]
            cell.removeCard()
        case .foundation:
            // can't remove card from here
            break
        }
    }


    func location(from card: Card) -> Location? {
        for (i, cell) in cells.enumerated() {
            if cell.contains(card: card) {
                return Location.cell(i)
            }
        }
        for (i, foundation) in foundations.enumerated() {
            if foundation.contains(card: card) {
                return Location.foundation(i)
            }
        }
        for (i, cascade) in cascades.enumerated() {
            if cascade.contains(card: card) {
                return Location.cascade(i)
            }
        }
        return nil
    }


    // MARK: - Private

    private func card(at location: Location) -> Card? {
        switch location {
        case .cell(let value):
            switch cells[value].state {
            case .empty: return nil
            case .card(let card): return card
            }
        case .foundation(let value):
            switch foundations[value].state {
            case .empty: return nil
            case .card(let card): return card
            }
        case .cascade(let value):
            return cascades[value].bottomCard
        }
    }


    private func move(card: Card, to location: Location) throws {
        switch location {
        case .cell(let value):
            let cell = cells[value]
            try cell.add(card: card)
        case .foundation(let value):
            let foundation = foundations[value]
            try foundation.add(card: card)
        case .cascade(let value):
            let cascade = cascades[value]
            try cascade.add(card: card)
        }
    }
}


extension Game: CustomDebugStringConvertible {
    var debugDescription: String {
        let parts = [
            "Cells: \(cells)",
            "Foundations: \(foundations)",
            cascades.map({ "\($0)" }).joined(separator: "\n")
        ]

        return parts.joined(separator: "\n")
    }
}
