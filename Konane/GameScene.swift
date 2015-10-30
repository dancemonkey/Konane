//
//  GameScene.swift
//  Konane
//
//  Created by Drew Lanning on 10/23/15.
//  Copyright (c) 2015 Drew Lanning. All rights reserved.
//

// !! CREATE GAME MODEL TO EMBODY THE RULES, PLACE LOGIC TESTING IN THERE AND PUT ONLY VIEW DISPLAY HERE

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  let stoneSize = CGSizeMake(70, 70)
  var stones = [[Stone?]]()
  let board = Board()
  var indicators = [[SKShapeNode]]()
  
  let tileSelectState = SelectingTilesForRemoval()
  let jumpTilesState = JumpingTiles()
  let gameOverState = GameOver()
  var stateMachine: GKStateMachine!
  
  var stoneJumping = false
  var stateLabel: SKLabelNode!
  var turnLabel: SKLabelNode!
  var playerTurn: StoneColor = .Black {
    didSet {
      turnLabel?.text = "\(playerTurn)'s turn."
    }
  }
  
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
      indicators.append([SKShapeNode]())
      for h in 0..<height {
        currentColor = getNextColor(forColor: currentColor)
        let stone = Stone(column: w, row: h, stoneColor: currentColor)
        let position = CGPointMake(CGFloat(w*board.gridSize),CGFloat(h*board.gridSize))
        stone.position = position
        stone.zPosition = 15
        addChild(stone)
        stones[w].append(stone)
        indicators[w].append(createIndicator(position))
      }
    }
  }
  
  func increaseRemovedStones() {
    self.removedStones++
    switchPlayerTurn(from: playerTurn)
  }
  
  func startPlaying() {
    stateMachine.enterState(SelectingTilesForRemoval)
    
    turnLabel = SKLabelNode(text: "\(playerTurn)'s turn.")
    turnLabel.fontName = "AmericanTypewriter"
    turnLabel.horizontalAlignmentMode = .Left
    turnLabel.position = CGPointMake(10, -100)
    turnLabel.fontSize = CGFloat(50)
    turnLabel.fontColor = UIColor.blackColor()
    addChild(turnLabel)
    
    stateLabel = SKLabelNode(text: "Select a tile for removal.")
    stateLabel.fontName = "AmericanTypewriter"
    stateLabel.horizontalAlignmentMode = .Left
    let pos = CGPointMake(turnLabel.position.x, turnLabel.position.y-75)
    stateLabel.position = pos
    stateLabel.fontSize = CGFloat(50)
    stateLabel.fontColor = UIColor.blackColor()
    addChild(stateLabel)
  }
  
  func createIndicator(position: CGPoint) -> SKShapeNode {
    let rect = SKShapeNode(rectOfSize: CGSizeMake(75, 75))
    rect.strokeColor = UIColor.whiteColor()
    rect.fillColor = UIColor.redColor()
    rect.alpha = 0.75
    rect.lineWidth = 2.0
    rect.name = "move indicator"
    rect.position = position
    rect.zPosition = 15
    return rect
  }
  
  func removeIndicators() {
    for row in indicators {
      for dot in row {
        dot.removeFromParent()
      }
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
  }
  
  func placeValidMoveIndicator(atSquares: [(c: Int,r: Int)]) {
    for move in atSquares {
      let (c,r) = (move.c, move.r)
      addChild(indicators[c][r])
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
  
  func clearSelectedStones() {
    for row in stones {
      for stone in row {
        if stone != nil {
          stone?.selected = false
        }
      }
    }
    stoneJumping = false
  }
  
  func switchPlayerTurn(from currentTurn: StoneColor) {
    if currentTurn == .Black {
      playerTurn = .White
    } else {
      playerTurn = .Black
    }
  }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
      var selectedStone: Stone? = nil
      if stoneJumping {
        for row in stones {
          for stone in row {
            if stone != nil && stone!.selected {
              selectedStone = stone!
              stone!.selected = false
            }
          }
        }
        for touch in touches {
          let (oC, oR) = (selectedStone?.column, selectedStone?.row)
          let location = touch.locationInNode(self)
          let destinationNode = nodeAtPoint(location)
          if destinationNode.name == "move indicator" {
            let (dC,dR) = (destinationNode.position.x, destinationNode.position.y)
            stones[oC!][oR!] = nil
            let (column, row) = (Int(dC)/board.gridSize,Int(dR)/board.gridSize)
            stones[column][row] = selectedStone
            selectedStone?.moveStone(toLocation: (column, row), ofNode: destinationNode)
            removeIndicators()
            clearSelectedStones()
            switchPlayerTurn(from: playerTurn)
          }
        }
      }
      clearSelectedStones()
      removeIndicators()
    }
   
    override func update(currentTime: CFTimeInterval) {
      if removedStones >= 2 {
        stateMachine.enterState(JumpingTiles)
      }
    }
}
