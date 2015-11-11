//
//  GameScene.swift
//  Konane
//
//  Created by Drew Lanning on 10/23/15.
//  Copyright (c) 2015 Drew Lanning. All rights reserved.
//

// MOVE UI ELEMENTS (LABELS, ETC.) TO GAMEVIEWCONTROLLER?
// USE TOUCHESBEGAN TO CLEAR FIELD OF SEQUENTIAL JUMP OPTIONS

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  var gameModel: KonaneModel!
  
  let stoneSize = CGSizeMake(70, 70)
  var stones = [[Stone?]]()
  let board = Board()
  var indicators = [[ValidMoveIndicator]]()
  
  var stoneJumping = false
  var stateLabel: SKLabelNode!
  var turnLabel: SKLabelNode!
  var firstMove: (Int,Int)!
  var seqJump = false {
    didSet {
      print("sequential jump mode!!")
    }
  }
  
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
      indicators.append([ValidMoveIndicator]())
      for h in 0..<height {
        currentColor = getNextColor(forColor: currentColor)
        let stone = Stone(column: w, row: h, stoneColor: currentColor)
        let indicator = ValidMoveIndicator(column: w, row: h, stone: nil)
        let position = CGPointMake(CGFloat(w*Board.gridSize),CGFloat(h*Board.gridSize))
        stone.position = position
        indicator.position = position
        stone.zPosition = 15
        addChild(stone)
        stones[w].append(stone)
        indicators[w].append(indicator)
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
  
  func removeIndicators() {
    for row in indicators {
      for dot in row {
        dot.removeFromParent()
      }
    }
  }
  
  func placeValidMoveIndicator(atSquares: [(c: Int,r: Int)], forStone: Stone) {
    for move in atSquares {
      let (c,r) = (move.c, move.r)
      addChild(indicators[c][r])
      indicators[c][r].stone = forStone
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
  
  func handleJumps(forTouch touch: UITouch, onStone: Stone) {
    if (scene as! GameScene).seqJump {
      seqJump = false
      clearSelectedStones()
    }
    
    let (oC, oR) = (onStone.column, onStone.row)
    let location = touch.locationInNode(self)
    let destinationNode = nodeAtPoint(location)
    if destinationNode.name == "move indicator" {
      let (dC,dR) = (destinationNode.position.x, destinationNode.position.y)
      stones[oC][oR] = nil
      let (column, row) = (Int(dC)/Board.gridSize,Int(dR)/Board.gridSize)
      stones[column][row] = onStone
      onStone.moveStone(toLocation: (column, row), ofNode: destinationNode)
      let directionJumped = gameModel.directionJumped(from: (oC, oR), destination: (column, row))
      onStone.setJumpDirection(directionJumped)
      
      let takenStone = gameModel.findJumpedStone(inGroup: gameModel.vulnerableStones, withMove: (column, row))
      stones[takenStone!.c][takenStone!.r]?.removeStone()
            
      if !gameModel.secondJumpIsPossible((onStone.getJumpDirection())!, fromCoord: (onStone.getCoord()), inBoard: self.stones) {
        onStone.setJumpDirection(nil)
        gameModel.switchPlayerTurn(from: gameModel.playerTurn)
      } else if gameModel.secondJumpIsPossible((onStone.getJumpDirection())!, fromCoord: (onStone.getCoord()), inBoard: self.stones) {
        seqJump = true
      }
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    removeIndicators()
  }

  override func update(currentTime: CFTimeInterval) {
    
  }
}
