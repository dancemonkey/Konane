//
//  GameScene.swift
//  Konane
//
//  Created by Drew Lanning on 10/23/15.
//  Copyright (c) 2015 Drew Lanning. All rights reserved.
//

// MOVE UI ELEMENTS (LABELS, ETC.) TO GAMEVIEWCONTROLLER

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  var gameModel: KonaneModel!
  
  let stoneSize = CGSizeMake(70, 70)
  var stones = [[Stone?]]()
  let board = Board()
  var indicators = [[SKShapeNode]]()
  
  var stoneJumping = false
  var stateLabel: SKLabelNode!
  var turnLabel: SKLabelNode!
  var firstMove: (Int,Int)!
  
  private var removedStones = 0
  
  override func didMoveToView(view: SKView) {
    gameModel = KonaneModel(withScene: self)
    
    scene?.anchorPoint = CGPointMake(0.05, 0.4)
    
    addChild(board)
    placeStartingStones(board.getBoardSize())
    startPlaying()
  }
  
  func numberOfRemovedStones() -> Int {
    return removedStones
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
    gameModel.switchPlayerTurn(from: gameModel.playerTurn)
  }
  
  func startPlaying() {
    gameModel.startPlaying()
    
    turnLabel = SKLabelNode(text: "\(gameModel.playerTurn)'s turn.")
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
          let directionJumped = gameModel.directionJumped(from: (oC!, oR!), destination: (column, row))
          selectedStone?.setJumpDirection(directionJumped)
          
          let takenStone = gameModel.findJumpedStone(inGroup: gameModel.vulnerableStones, withMove: (column, row))
          stones[takenStone!.c][takenStone!.r]?.removeStone()
          
          removeIndicators()
          clearSelectedStones()
          // if gameModel.noMoreValidMoves {
          if gameModel.secondJumpIsPossible((selectedStone?.getJumpDirection())!, fromCoord: (selectedStone?.getCoord())!, inBoard: self.stones) {
            print("another jump possible")
          }
          gameModel.switchPlayerTurn(from: gameModel.playerTurn)
          // } else {
          //   LET THEM TAKE ANOTHER TURN OR CANCEL THEIR TURN
          //   MOVE ABOVE STONE JUMPING CODE INTO ANOTHER FUNCTION, MAYBE TO MODEL, AND MAKE IT RECURSIVE UNTIL IT RETURNS
          //   FALSE
          // }
        }
      }
    }
    clearSelectedStones()
    removeIndicators()
  }
  
  override func update(currentTime: CFTimeInterval) {
    
  }
}
