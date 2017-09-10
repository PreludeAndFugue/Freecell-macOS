//
//  MoveHistory.swift
//  Freecell2
//
//  Created by gary on 30/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

struct MoveHistory {
    var moves: [Move] = []

    var noMovesMade: Bool {
        return moves.count == 0
    }

    
    mutating func add(move: Move) {
        moves.append(move)
    }


    mutating func clear() {
        moves = []
    }
}
