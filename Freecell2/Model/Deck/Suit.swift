//
//  Suit.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

enum Suit {
    case clubs
    case diamonds
    case hearts
    case spades

    static var values: [Suit] {
        return [.clubs, .diamonds, .hearts, .spades]
    }

    var colour: Colour {
        switch self {
        case .clubs, .spades:
            return .black
        case .diamonds, .hearts:
            return .red
        }
    }
}


extension Suit: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .clubs:
            return "C"
        case .diamonds:
            return "D"
        case .hearts:
            return "H"
        case .spades:
            return "S"
        }
    }
}
