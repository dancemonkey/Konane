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
import GameplayKit

enum JumpDirections {
  case North, South, East, West
}

class GameScene: SKScene {
  
  let stoneSize = CGSizeMake(70, 70)
  var stones = [[Stone?]]()
  let board = Board()
  var indicators = [SKShapeNode]()
  
  let tileSelectState = SelectingTilesForRemoval()
  let jumpTilesState = JumpingTiles()
  let gameOverState = GameOver()
  var stateMachine: GKStateMachine!
  
  private var removedStones = 0
  
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
      scene?.anchorPoint = CGPointMake(0.05, 0.4)
      
      tileSelectState.gameScene = self
      jumpTilesState.gameScene = self
      gameOverState.gameScene = self
      stateMachine = GKStateMachine(states: [tileSelectState, jumpTilesState, gameOverState])
      
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
  
  func increaseRemovedStones() {
    self.removedStones++
  }
  
  func startPlaying() {
    stateMachine.enterState(SelectingTilesForRemoval)
  }
  
  func removeIndicators() {
    for dot in indicators {
      dot.removeFromParent()
    }
    if indicators.count > 0 {
      indicators.removeRange(0...indicators.count-1)
    }
  }
  
  func jumpIsPossible(fromSquare: (column: Int,row: Int)) -> Bool {
    
    let origin = stones[fromSquare.column][fromSquare.row]
    
    var adjacentSquaresToTest = [(column: Int,row: Int)]()
    adjacentSquaresToTest.append((fromSquare.column, fromSquare.row+1)) // North
    adjacentSquaresToTest.append((fromSquare.column, fromSquare.row-1)) // South
    adjacentSquaresToTest.append((fromSquare.column+1, fromSquare.row)) // East
    adjacentSquaresToTest.append((fromSquare.column-1, fromSquare.row)) // West
    
    // PASS THROUGH BOARD AND REMOVE OLD MOVE INDICATOR RECTS
    removeIndicators()
    
    // FIRST TEST TO SEE IF ADJACENT SQUARES ARE OCCUPIED, IF NONE THEN FALSE OUT
    var occupiedSquares = [Stone]()
    for square in adjacentSquaresToTest {
      if stoneExists(square) {
        occupiedSquares.append(stones[square.column][square.row]!)
      }
    }
    if occupiedSquares.count == 0 {
      return false // no full squares around origin
    }
    
    // NEXT IF OCCUPIED SQUARES ARE FOUND, TEST SQUARE BEYOND, IF EMPTY THEN INDICATE POSSIBLE JUMP BY RETURNING TRUE
    // OTHERWISE FALSE OUT
    let (originX, originY) = (fromSquare.column, fromSquare.row)
    var direction: JumpDirections
    var possibleMoves = [(c: Int, r: Int)]()
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
      let (c,r) = directionModifier((square.column,square.row), direction: direction)
      if isEmpty((c,r)) {
        possibleMoves.append((c,r))
      }
    }
    if possibleMoves.count == 0 {
      return false
    }
    
    // THEN INDICATE POTENTIAL MOVES ON BOARD
    placeValidMoveIndicator(possibleMoves)
    origin?.setPossibleMoves(possibleMoves)
    return true
    
    // THEN ADD NEW FUNCTION (TO STONE?) TO ALLOW ACTUAL MOVE TO INDICATED SQUARES
  }
  
  func placeValidMoveIndicator(atSquares: [(c: Int,r: Int)]) {
    for move in atSquares {
      let (c,r) = (move.c, move.r)
      let rect = SKShapeNode(rectOfSize: CGSizeMake(75, 75))
      rect.strokeColor = UIColor.whiteColor()
      rect.fillColor = UIColor.redColor()
      rect.alpha = 0.75
      rect.lineWidth = 2.0
      rect.name = "move indicator"
      rect.position = CGPointMake(CGFloat(c*board.gridSize), CGFloat(r*board.gridSize))
      rect.zPosition = 15
      addChild(rect)
      indicators.append(rect)
    }
  }
  
  func stoneExists(atSquare: (column: Int, row: Int)) -> Bool {
    let (c,r) = (atSquare.column, atSquare.row)
    return stones[c][r] != nil
  }
  
  func directionModifier(startingCoordinates: (column: Int, row: Int), direction: JumpDirections) -> (c: Int, r: Int) {
    var (c,r) = (startingCoordinates.column, startingCoordinates.row)
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
    return (c,r)
  }
  
  func isEmpty(atSquare: (column: Int, row: Int)) -> Bool {
    let (c,r) = (atSquare.column, atSquare.row)
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
      if removedStones >= 2 {
        stateMachine.enterState(JumpingTiles)
      }
    }
}
