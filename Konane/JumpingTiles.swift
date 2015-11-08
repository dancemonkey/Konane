//
//  JumpingTiles.swift
//  Konane
//
//  Created by Drew Lanning on 10/27/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

import UIKit
import GameplayKit
import SceneKit

class JumpingTiles: GKState {
  weak var gameScene: GameScene?
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == GameOver.self
  }
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    if let scene = gameScene {
      for row in scene.stones {
        for stone in row {
          stone?.selectable = true
          scene.stateLabel.text = "Jump your opponent's tiles."
        }
      }
    }
  }
  
  override func willExitWithNextState(nextState: GKState) {
    if let scene = gameScene {
      for row in scene.stones {
        for stone in row {
          stone?.selectable = false
        }
      }
      // Perform here the actions that you want to do with your UI when it exits this state.
    }
  }
}

