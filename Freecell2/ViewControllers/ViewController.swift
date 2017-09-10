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

    var statisticsStore: StatisticsStore!
    var statistics: Statistics!

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScene()
        configureStatistics()
    }

    
    // MARK: - Actions

    @IBAction func showStatistics(_ sender: NSMenuItem) {
        let mainStoryboard = NSStoryboard.Name("Main")
        let statisticsWindow = NSStoryboard.SceneIdentifier("StatisticsWindowController")
        let storyboard = NSStoryboard(name: mainStoryboard, bundle: nil)
        guard
            let statisticsWindowController = storyboard.instantiateController(withIdentifier: statisticsWindow) as? NSWindowController,
            let window = statisticsWindowController.window
        else {
            return
        }
        let application = NSApplication.shared
        application.runModal(for: window)
    }


    @IBAction func newGame(_ sender: NSMenuItem) {
        print("new game")
    }


    // MARK: - Private

    private func configureScene() {
        if let view = self.skView {
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                scene.viewDelegate = self
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }


    private func configureStatistics() {
        let userDefaults = UserDefaults.standard
        statisticsStore = StatisticsStore(userDefaults: userDefaults)
        statistics = statisticsStore.load()
    }
}


// MARK: - GameSceneDelegate

extension ViewController: GameSceneDelegate {
    func newGame(currentGameState: Game.State) -> Bool {
        let alert = createAlert()
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            if currentGameState == .playing { updateStatistics(with: .playing) }
            return true
        case .alertSecondButtonReturn:
            return false
        default:
            return false
        }
    }


    func gameDone() {
        updateStatistics(with: .done)
    }


    private func updateStatistics(with gameState: Game.State) {
        statistics.update(with: gameState)
        statisticsStore.save(statistics: statistics)
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
