//
//  StandardEndAnimation.swift
//  Freecell2
//
//  Created by gary on 02/09/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit

struct StandardEndAnimation: EndAnimationProtocol {

    // cards only collide with ground
    let groundBitMask: UInt32 = 0b0001
    let cardBitMask: UInt32 = 0b0010


    func run(with cards: [PlayingCard], and scene: SKScene) {
        var t = 0.0
        let dt = 0.2
        addEdge(to: scene)
        for card in sortKingsTop(cards: cards) {
            let delayAction = SKAction.wait(forDuration: t)
            let blockAction = SKAction.run({ self.addPhysicsBody(to: card) })
            card.run(SKAction.sequence([delayAction, blockAction]))
            t += dt
        }
    }


    private func addPhysicsBody(to card: PlayingCard) {
        let physics = SKPhysicsBody(rectangleOf: card.size)
        physics.affectedByGravity = true
        physics.allowsRotation = false
        physics.mass = 1
        physics.restitution = 0.66
        physics.velocity = randomInitialVelocity()
        physics.collisionBitMask = groundBitMask
        physics.categoryBitMask = cardBitMask
        card.physicsBody = physics
    }


    private func randomInitialVelocity() -> CGVector {
        let dx = -400
        let dy = 400 + Int(arc4random_uniform(300))
        return CGVector(dx: dx, dy: dy)
    }


    private func addEdge(to scene: SKScene) {
        let cardHeight: CGFloat = 150
        let start = CGPoint(x: 0, y: -scene.frame.height + cardHeight/2)
        let end = CGPoint(x: scene.frame.width, y: -scene.frame.height + cardHeight/2)
        scene.physicsBody = SKPhysicsBody(edgeFrom: start, to: end)
        scene.physicsBody?.categoryBitMask = groundBitMask
        scene.physicsBody?.friction = 0
    }


    private func sortKingsTop(cards: [PlayingCard]) -> [PlayingCard] {
        return cards.sorted(by: { $0.card.value.rawValue > $1.card.value.rawValue })
    }
}
