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

enum JumpDirections {
  case North, South, East, West
}

class GameScene: SKScene {
  
  let stoneSize = CGSizeMake(50, 50)
  var stones = [[Stone]]()
  let board = Board()
  
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
      scene?.anchorPoint = CGPointMake(0.2, 0.5)
      addChild(board)
      placeStartingStones(board.getBoardSize())
      startPlaying()
    }
  
  func placeStartingStones(size: (Int,Int)) {
    let (width, height) = size
    var currentColor = StoneColor.Black
    for w in 0..<width {
      currentColor = getNextColor(forColor: currentColor)
      stones.append([Stone]())
      for h in 0..<height {
        currentColor = getNextColor(forColor: currentColor)
        let stone = Stone(column: w, row: h, stoneColor: currentColor)
        stone.position = CGPointMake(CGFloat(w*board.gridSize),CGFloat(h*board.gridSize))
        stone.zPosition = 15
        addChild(stone)
        stones[w].append(stone)
      }
    }
  }
  
  func startPlaying() {
    
  }
  
  func jumpIsPossible(fromSquare: (row: Int,column: Int)) -> Bool {
    
    // PASS THROUGH STONES AND REMOVE INDICATOR DOTS, PUT THIS INTO ANOTHER FUNCTION
    for row in stones {
      for stone in row {
        for child in stone.children {
          if child.name == "indicator dot" {
            child.removeFromParent()
          }
        }
      }
    }
    let originSquare = stones[fromSquare.row][fromSquare.column]
    
    // FIRST TEST TO SEE IF ADJACENT SQUARES ARE OCCUPIED
    var neighborSquares = [Stone]()
    neighborSquares.append(stones[fromSquare.row][fromSquare.column+1]) // North
    neighborSquares.append(stones[fromSquare.row][fromSquare.column-1]) // South
    neighborSquares.append(stones[fromSquare.row+1][fromSquare.column]) // East
    neighborSquares.append(stones[fromSquare.row-1][fromSquare.column]) // West
    
    for stone in neighborSquares {
      let dot = SKShapeNode(ellipseOfSize: CGSizeMake(5, 5))
      dot.fillColor = UIColor.redColor()
      dot.name = "indicator dot"
      stone.addChild(dot)
    }
    
    // NEXT IF OCCUPIED SQUARE IS FOUND, TEST SQUARE BEYOND, IF EMPTY THEN INDICATE POSSIBLE JUMP BY RETURNING TRUE
    // THEN ADD NEW FUNCTION (TO STONE?) TO ALLOW ACTUAL MOVE TO INDICATED SQUARES
    
    return true
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
