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
  var stones = [[Stone?]]()
  let board = Board()
  var indicators = [SKShapeNode]()
  
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
  
  func removeIndicators() {
    for (index,dot) in indicators.enumerate() {
      dot.removeFromParent()
    }
    if indicators.count > 0 {
      indicators.removeRange(0...indicators.count-1)
    }
  }
  
  func jumpIsPossible(fromSquare: (column: Int,row: Int)) -> Bool {
    
    //let originSquare = [fromSquare.column][fromSquare.row]
    
    var adjacentSquaresToTest = [(column: Int,row: Int)]()
    adjacentSquaresToTest.append((fromSquare.column, fromSquare.row+1)) // North
    adjacentSquaresToTest.append((fromSquare.column, fromSquare.row-1)) // South
    adjacentSquaresToTest.append((fromSquare.column+1, fromSquare.row)) // East
    adjacentSquaresToTest.append((fromSquare.column-1, fromSquare.row)) // West
    
    // PASS THROUGH STONES AND REMOVE INDICATOR DOTS
    removeIndicators()
    
    // FIRST TEST TO SEE IF ADJACENT SQUARES ARE OCCUPIED
    var occupiedSquares = [Stone]()
    for square in adjacentSquaresToTest {
      if stoneExists(square) {
        occupiedSquares.append(stones[square.column][square.row]!)
      }
    }
    if occupiedSquares.count == 0 {
      return false
    }
    
    // TEMP INDICATOR DOT TO ENSURE IT'S PROPERLY TESTING ADJACENT SQUARES
    for square in occupiedSquares {
      let dot = SKShapeNode(rectOfSize: CGSizeMake(43, 43))
      dot.strokeColor = UIColor.redColor()
      dot.name = "indicator dot"
      square.addChild(dot)
      indicators.append(dot)
    }
    
    // NEXT IF OCCUPIED SQUARES ARE FOUND, TEST SQUARE BEYOND, IF EMPTY THEN INDICATE POSSIBLE JUMP BY RETURNING TRUE
    let (originX, originY) = (fromSquare.column, fromSquare.row)
    var direction: JumpDirections
    for square in occupiedSquares {
      if square.column > originX {
        direction = .East
      } else if square.column < originX {
        direction = .West
      } else if square.row > originY {
        direction = .North
      } else {
        direction = .South
      }
      if isEmpty((square.column, square.row), direction: direction) {
        // indicate you can jump here
      } else {
        // don't do shit
      }
    }
    
    // THEN ADD NEW FUNCTION (TO STONE?) TO ALLOW ACTUAL MOVE TO INDICATED SQUARES
    
    return true
  }
  
  func stoneExists(atSquare: (column: Int, row: Int)) -> Bool {
    let (c,r) = (atSquare.column, atSquare.row)
    return stones[c][r] != nil
  }
  
  // REFACTOR THIS TO FIND AND RETURN EMPTY SQUARES RATHER THAN RETURN A BOOL
  func isEmpty(atSquare: (column: Int, row: Int), direction: JumpDirections) -> Bool {
    var (c,r) = (atSquare.column, atSquare.row)
    switch direction {
    case .North:
      r++
    case .South:
      r--
    case .East:
      c++
    case .West:
      c--
    }
    return stones[c][r] == nil
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
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
