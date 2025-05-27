//
//  GameViewController.swift
//  JigsawDrop
//
//  Created by Richard Carman on 5/23/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    // Properties to hold the selected grid size, with defaults
    var selectedRows: Int = 6
    var selectedColumns: Int = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🎯 DEBUG: GameViewController.viewDidLoad() called with selectedGrid: \(selectedRows)x\(selectedColumns)")
        print("🎯 DEBUG: View type: \(type(of: self.view))")
        
        // Get the SKView
        guard let skView = self.view as? SKView else {
            print("❌ ERROR: View is not an SKView, it's a \(type(of: self.view))")
            return
        }
        
        print("🎯 DEBUG: Successfully got SKView")
        
        // Create and configure the scene with proper size
        let scene = GameScene()
        scene.scaleMode = .aspectFit  // More predictable scaling
        scene.size = skView.bounds.size
        
        // Pass the selected grid dimensions to the scene
        scene.selectedRows = self.selectedRows
        scene.selectedColumns = self.selectedColumns
        
        print("🎯 DEBUG: Created GameScene with size: \(scene.size) and grid: \(scene.selectedRows)x\(scene.selectedColumns)")
        
        // Present the scene
        skView.presentScene(scene)
        
        // Enable user interaction
        skView.isUserInteractionEnabled = true
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        print("🎯 DEBUG: Presented scene to SKView")
        print("🎯 DEBUG: GameViewController.viewDidLoad() completed!")
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🎯 DEBUG: GameViewController.viewWillAppear() called!")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🎯 DEBUG: GameViewController.viewDidAppear() called!")
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

