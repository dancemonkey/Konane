//
//  GameOver.swift
//  Konane
//
//  Created by Drew Lanning on 10/27/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

import UIKit
import GameplayKit
import SceneKit

class GameOver: GKState {
  weak var gameScene: GameScene?
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass == SelectingTilesForRemoval.self
  }
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    if let scene = gameScene {
      print("game over")
      print("\(scene.gameModel.playerTurn) loses.")
    }
  }
  
  override func willExitWithNextState(nextState: GKState) {
    if let scene = gameScene {
      // Perform here the actions that you want to do with your UI when it exits this state.
    }
  }
}


