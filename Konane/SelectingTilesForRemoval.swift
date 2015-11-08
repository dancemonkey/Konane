//
//  SelectingTilesForRemoval.swift
//  Konane
//
//  Created by Drew Lanning on 10/27/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

import UIKit
import GameplayKit
import SceneKit

class SelectingTilesForRemoval: GKState {
  weak var gameScene: GameScene?
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == JumpingTiles.self
  }
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    if let scene = gameScene {
      for row in scene.stones {
        for stone in row {
          stone?.removingStones = true
        }
      }
    }
  }
  
  override func willExitWithNextState(nextState: GKState) {
    if let scene = gameScene {
      for row in scene.stones {
        for stone in row {
          stone?.removingStones = false
        }
      }
    }
  }
}
