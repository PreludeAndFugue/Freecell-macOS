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

    // MARK: - Properties

    private let game = Game()
    private var gameGraphics = GameGraphics()
    private var currentPlayingCard: CurrentPlayingCard?
    var viewDelegate: GameSceneDelegate?


    // MARK: - Lifecycle

    override func sceneDidLoad() {
        super.sceneDidLoad()
        anchorPoint = CGPoint(x: 0, y: 1)
    }


    override func didMove(to view: SKView) {
        // https://stackoverflow.com/questions/39590602/scenedidload-being-called-twice
        super.didMove(to: view)
        print("didmove - setup game graphics")
        gameGraphics.setup(width: size.width)
        gameGraphics.setupCards(gameCascades: game.cascades)
        gameGraphics.addChildren(to: self)
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


    // MARK: - Touch handlers

    private func touchDown(atPoint point: CGPoint) {
        if gameGraphics.isNewGameTapped(point: point) {
            newGame()
            return
        }
        guard
            let playingCard = gameGraphics.cardFrom(position: point),
            let parent = playingCard.parent,
            let location = game.location(from: playingCard.card),
            game.canMove(card: playingCard.card)
        else {
            return
        }
        let touchPoint = playingCard.convert(point, from: parent)
        gameGraphics.setActive(card: playingCard)
        currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: touchPoint, location: location)
    }


    private func doubleClick(at point: CGPoint) {
        guard
            let playingCard = gameGraphics.cardFrom(position: point),
            let location = game.location(from: playingCard.card),
            game.canMove(card: playingCard.card)
        else {
            return
        }

        let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: point, touchPoint: point, location: location)

        do {
            let newLocation = try game.quickMove(from: location)
            gameGraphics.move(currentPlayingCard: currentPlayingCard, to: newLocation, gameCascades: game.cascades)
        } catch {}
    }


    private func touchMoved(toPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        currentPlayingCard.update(position: pos)
    }


    private func touchUp(atPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        if let dropLocation = gameGraphics.dropLocation(from: pos, currentPlayingCard: currentPlayingCard, game: game) {
            do {
                let startLocation = currentPlayingCard.location
                try game.move(from: startLocation, to: dropLocation)
                gameGraphics.move(currentPlayingCard: currentPlayingCard, to: dropLocation, gameCascades: game.cascades)
            } catch GameError.invalidMove {
                currentPlayingCard.returnToOriginalLocation()
            } catch {
                // Something went wrong - don't know what
                currentPlayingCard.returnToOriginalLocation()
            }
        } else {
            currentPlayingCard.returnToOriginalLocation()
        }
        self.currentPlayingCard = nil

        // check if game is over
        if game.isGameOver {
            print("game over")
        }
    }


    private func newGame() {
        guard let viewDelegate = viewDelegate, viewDelegate.newGame() else { return }
        game.new()
        gameGraphics.newGame(gameCascades: game.cascades)
        gameGraphics.addCards(to: self)
    }
}
