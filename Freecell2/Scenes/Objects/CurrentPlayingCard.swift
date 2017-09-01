//
//  CurrentPlayingCard.swift
//  Freecell2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation
import SpriteKit

struct CurrentPlayingCard {
    let playingCard: PlayingCard
    let startPosition: CGPoint
    let touchPoint: CGPoint
    let location: Location

    
    func move(to position: CGPoint) {
        playingCard.position = CGPoint(x: position.x - touchPoint.x, y: position.y - touchPoint.y)
    }


    func returnToOriginalLocation() {
        let action = SKAction.move(to: startPosition, duration: 0.2)
        playingCard.run(action)
    }
}
