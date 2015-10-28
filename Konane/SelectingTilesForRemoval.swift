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
    // eventually set this up to only allow you to remove stones in center and at corners
    // then once each player has removed ONE stone, go to next state (in scene, not here, right?)
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
