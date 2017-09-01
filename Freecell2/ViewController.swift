//
//  ViewController.swift
//  Freecell2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    var statistics: Statistics!

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScene()
        configureStatistics()
    }

    // MARK: - Private

    private func configureScene() {
        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill

                scene.viewDelegate = self

                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }


    private func configureStatistics() {
        let userDefaults = UserDefaults.standard
        let statisticsStore = StatisticsStore(userDefaults: userDefaults)
        statistics = statisticsStore.load()
    }
}


// MARK: - GameSceneDelegate

extension ViewController: GameSceneDelegate {
    func newGame() -> Bool {
        let alert = createAlert()
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            return true
        case .alertSecondButtonReturn:
            return false
        default:
            return false
        }
    }


    func gameDone() {
        
    }


    private func createAlert() -> NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "New Game?"
        alert.informativeText = "Do you want to start a new game?"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        return alert
    }
}
