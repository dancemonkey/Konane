//
//  GameScene.swift
//  Konane
//
//  Created by Drew Lanning on 10/23/15.
//  Copyright (c) 2015 Drew Lanning. All rights reserved.
//

// - ADD STATES TO STONES? REQUIRE ADDING AN ENTITY TO THE STONE CLASS?
// - STATES:  SELECT FOR REMOVAL (START OF GAME)
//            MOVING STATE (ON PLAYER TURN)
//            IDLE STATE (WHEN NOT PLAYER TURN)
// - ADD PLAYER ENTITY (HOLD SCORE, WHICH STONES YOU OWN)
// - STATE MACHINE FOR GAMESCENE (WHICH PLAYER TURN IS ACTIVE, GAME OVER, ETC)

import SpriteKit

class GameScene: SKScene {
  
  let stoneSize = CGSizeMake(50, 50)
  var stones = [[Stone]]()
  let board = Board()
  
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
      scene?.anchorPoint = CGPointMake(0.2, 0.5)
      addChild(board)
      placeStartingStones(board.getBoardSize())
    }
  
  func placeStartingStones(size: (Int,Int)) {
    let (width, height) = size
    var currentColor = StoneColor.Black
    for w in 0..<width {
      currentColor = getNextColor(forColor: currentColor)
      for h in 0..<height {
        currentColor = getNextColor(forColor: currentColor)
        let stone = Stone(column: w, row: h, stoneColor: currentColor)
        stone.position = CGPointMake(CGFloat(w*board.gridSize),CGFloat(h*board.gridSize))
        stone.zPosition = 15
        addChild(stone)
      }
    }
  }
  
  func getNextColor(forColor currentColor: StoneColor) -> StoneColor {
    if currentColor == .Black {
      return .White
    } else {
      return .Black
    }
  }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
