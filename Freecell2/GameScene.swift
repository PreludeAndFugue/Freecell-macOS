//
//  GameScene.swift
//  Freecell2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private let topLeft = CGPoint(x: 0, y: 1)
    private let cardSize = CGSize(width: 103, height: 150)
    private let spacing: CGFloat = 20
    private let margin: CGFloat = -40
    private var zIndex: CGFloat = 10
    private let zIndexIncrement: CGFloat = 5

    private let cellCount = 4
    private let foundationCount = 4
    private let cascadeCount = 8

    private let game = Game()
    private var cells: [SKSpriteNode] = []
    private var foundations: [SKSpriteNode] = []
    private var cascades: [SKSpriteNode] = []
    private var cardNodes: [PlayingCard] = []

    private var currentPlayingCard: CurrentPlayingCard?


    override func sceneDidLoad() {
        super.sceneDidLoad()
        anchorPoint = CGPoint(x: 0, y: 1)
    }

    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // https://stackoverflow.com/questions/39590602/scenedidload-being-called-twice
        setupGameParts()
        setupCards()
    }
    
    
    func touchDown(atPoint point: CGPoint) {
        guard
            let playingCard = cardFrom(position: point),
            let parent = playingCard.parent,
            let location = game.location(from: playingCard.card),
            game.canMove(card: playingCard.card)
        else {
            return
        }
        let touchPoint = playingCard.convert(point, from: parent)
        playingCard.zPosition = zIndex
        currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: touchPoint, location: location)

        zIndex += zIndexIncrement
    }


    func doubleClick(at point: CGPoint) {
        guard
            let playingCard = cardFrom(position: point),
            let location = game.location(from: playingCard.card),
            game.canMove(card: playingCard.card)
        else {
            return
        }

        let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: point, touchPoint: point, location: location)

        switch location {
        case .foundation: break
        case .cell:
            do {
                let newLocation = try game.moveToFoundation(from: location)
                moveToNewLocation(currentPlayingCard: currentPlayingCard, location: newLocation)
            } catch {}
        case .cascade:
            do {
                let newFoundation = try game.moveToFoundation(from: location)
                moveToNewLocation(currentPlayingCard: currentPlayingCard, location: newFoundation)
                return
            } catch {}
            do {
                let newCell = try game.moveToCell(from: location)
                moveToNewLocation(currentPlayingCard: currentPlayingCard, location: newCell)
                return
            } catch {}
        }
    }


    func touchMoved(toPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        currentPlayingCard.playingCard.position = CGPoint(x: pos.x - currentPlayingCard.touchPoint.x, y: pos.y - currentPlayingCard.touchPoint.y)
    }


    func touchUp(atPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        if let dropLocation = dropLocation(from: pos) {
            do {
                let startLocation = currentPlayingCard.location
                try game.move(from: startLocation, to: dropLocation)
                moveToNewLocation(currentPlayingCard: currentPlayingCard, location: dropLocation)
            } catch GameError.invalidMove {
                returnToOriginalLocation(currentPlayingCard: currentPlayingCard)
            } catch {
                // Something went wrong - don't know what
                returnToOriginalLocation(currentPlayingCard: currentPlayingCard)
            }
        } else {
            returnToOriginalLocation(currentPlayingCard: currentPlayingCard)
        }
        self.currentPlayingCard = nil

        print(game)


        // check if game is over
        if game.isGameOver {
            print("game over")
        }
    }


    override func mouseDown(with event: NSEvent) {
        if (event.clickCount == 2) {
            doubleClick(at: event.location(in: self))
        } else {
            touchDown(atPoint: event.location(in: self))
        }
    }


    override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }


    override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }


    // MARK: - Private

    private func cardFrom(position: CGPoint) -> PlayingCard? {
        var candidateCards: [PlayingCard] = []
        for card in cardNodes {
            if card.contains(position) {
                candidateCards.append(card)
            }
        }
        candidateCards.sort(by: { $0.zPosition < $1.zPosition })
        return candidateCards.last
    }


    private func dropLocation(from position: CGPoint) -> Location? {
        for (i, cell) in cells.enumerated() {
            if cell.contains(position) {
                return .cell(i)
            }
        }
        for (i, foundation) in foundations.enumerated() {
            if foundation.contains(position) {
                return .foundation(i)
            }
        }
        for playingCard in cardNodes {
            if playingCard.card == currentPlayingCard?.playingCard.card { continue }
            if playingCard.contains(position) {
                if let location = game.location(from: playingCard.card) {
                    switch location {
                    case .cascade(let value):
                        let cascade = game.cascades[value]
                        if cascade.isBottom(card: playingCard.card) {
                            return location
                        }
                    default:
                        break
                    }
                }
            }
        }
        for (i, cascade) in cascades.enumerated() {
            if cascade.contains(position) {
                let gameCascade = game.cascades[i]
                if gameCascade.isEmpty {
                    return .cascade(i)
                }
            }
        }
        return nil
    }


    private func returnToOriginalLocation(currentPlayingCard: CurrentPlayingCard) {
        let action = SKAction.move(to: currentPlayingCard.startPosition, duration: 0.5)
        currentPlayingCard.playingCard.run(action)
    }


    private func moveToNewLocation(currentPlayingCard: CurrentPlayingCard, location: Location) {
        let newPosition: CGPoint
        switch location {
        case .cell(let value):
            let cell = cells[value]
            newPosition = cell.position
        case .foundation(let value):
            let foundation = foundations[value]
            newPosition = foundation.position
        case .cascade(let value):
            let cascade = cascades[value]
            let gameCascade = game.cascades[value]
            let cardCount = gameCascade.cards.count - 1
            let cascadePosition = cascade.position
            newPosition = CGPoint(x: cascadePosition.x, y: cascadePosition.y + CGFloat(cardCount) * margin)
        }
        let action = SKAction.move(to: newPosition, duration: 0.5)
        currentPlayingCard.playingCard.run(action)
    }


    private func setupGameParts() {
        let backgroundColour = NSColor.init(white: 1.0, alpha: 0.2)
        let baseZPosition: CGFloat = zIndexIncrement

        // Cells
        for i in 0 ..< cellCount {
            let cell = SKSpriteNode(color: backgroundColour, size: cardSize)
            cell.anchorPoint = topLeft
            cell.position = CGPoint(x: -margin + CGFloat(i) * (cardSize.width + spacing), y: margin)
            cell.zPosition = baseZPosition
            cells.append(cell)
            addChild(cell)
        }

        // Foundations
        for i in 0 ..< foundationCount {
            let foundation = SKSpriteNode(color: backgroundColour, size: cardSize)
            foundation.anchorPoint = topLeft
            foundation.position = CGPoint(x: self.size.width + margin - cardSize.width - CGFloat(i) * (cardSize.width + spacing), y: margin)
            foundation.zPosition = baseZPosition
            foundations.append(foundation)
            addChild(foundation)
        }

        let cascadeWidth = CGFloat(cascadeCount) * cardSize.width + CGFloat(cascadeCount - 1) * spacing
        let cascadeMargin = (self.size.width - cascadeWidth) / 2

        // Cascades
        for i in 0 ..< cascadeCount {
            let cascade = SKSpriteNode(color: backgroundColour, size: cardSize)
            cascade.anchorPoint = topLeft
            cascade.position = CGPoint(x: cascadeMargin + CGFloat(i) * (cardSize.width + spacing), y: 2 * margin - cardSize.height)
            cascade.zPosition = baseZPosition
            cascades.append(cascade)
            addChild(cascade)
        }
    }


    private func setupCards() {
        for (cascadeCards, cascade) in zip(game.cascades, cascades) {
            let cascadePosition = cascade.position
            for (i, gameCard) in cascadeCards.cards.enumerated() {
                let card = PlayingCard(card: gameCard, size: cardSize)
                card.anchorPoint = topLeft
                card.size = cardSize
                card.position = CGPoint(x: cascadePosition.x, y: cascadePosition.y + margin * CGFloat(i))
                card.zPosition = zIndex
                zIndex += zIndexIncrement
                cardNodes.append(card)
                addChild(card)
            }
        }
    }
}
