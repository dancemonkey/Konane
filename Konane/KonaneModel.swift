//
//  KonaneModel.swift
//  Konane
//
//  Created by Drew Lanning on 10/29/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

// SEQUENTIAL MOVES WORK! JUST NEED TO LET PLAYER CANCEL THEIR SUBSEQUENT MOVES IF THEY WISH
// VALIDFIRST MOVE AND VALIDSECOND MOVE SHOULD NOT USE MAGIC NUMBERS, SHOULD CALC BASED ON SIZE OF BOARD

import Foundation
import GameplayKit

enum JumpDirections {
  case North, South, East, West
}

enum PlayerTurn: String {
  case Black, White
}

class KonaneModel {
  weak var scene: GameScene!
  
  let tileSelectState = SelectingTilesForRemoval()
  let jumpTilesState = JumpingTiles()
  let gameOverState = GameOver()
  var stateMachine: GKStateMachine!
  var vulnerableStones = [Stone]()
  
  var playerTurn: StoneColor = .Black {
    didSet {
      scene.turnLabel?.text = "\(playerTurn)'s turn."
    }
  }

  init(withScene scene: GameScene) {
    self.scene = scene
    
    tileSelectState.gameScene = self.scene
    jumpTilesState.gameScene = self.scene
    gameOverState.gameScene = self.scene
    stateMachine = GKStateMachine(states: [tileSelectState, jumpTilesState, gameOverState])
  }
  
  func startPlaying() {
    stateMachine.enterState(SelectingTilesForRemoval)
  }
  
  func jumpIsPossible(withStone stone: Stone, inBoard stones: [[Stone?]], forDirection: JumpDirections?) -> Bool {
    let origin = stones[stone.column][stone.row]
    
    var adjacentSquares = [(column: Int,row: Int)]()
    if forDirection == nil {
      adjacentSquares.append((stone.column, stone.row+1)) // North
      adjacentSquares.append((stone.column, stone.row-1)) // South
      adjacentSquares.append((stone.column+1, stone.row)) // East
      adjacentSquares.append((stone.column-1, stone.row)) // West
    } else {
      switch forDirection! {
      case .North:
        adjacentSquares.append((stone.column, stone.row+1)) // North
      case .South:
        adjacentSquares.append((stone.column, stone.row-1)) // South
      case .East:
        adjacentSquares.append((stone.column+1, stone.row)) // East
      case .West:
        adjacentSquares.append((stone.column-1, stone.row)) // West
      }
    }
    
    scene.removeIndicators()
    
    var occupiedSquares = [Stone]()
    for square in adjacentSquares {
      let (c,r) = (square.column, square.row)
      if withinBoundary(ofBoard: scene.board, forCoord: (square.column, square.row)) && stoneExistsAt((c,r), inBoard: stones) {
        occupiedSquares.append(stones[square.column][square.row]!)
      }
    }
    if occupiedSquares.count == 0 {
      return false // all empty around origin, can't jump
    }
    
    var direction: JumpDirections
    var possibleMoves = [(c: Int, r: Int)]()
    for square in occupiedSquares {
      direction = directionJumped(from: (origin!.column, origin!.row), destination: (square.column, square.row))
      let (c,r) = jumpCoordinates((square.column, square.row), direction: direction)
      if withinBoundary(ofBoard: scene.board, forCoord: (c, r)) && !stoneExistsAt((c,r), inBoard: stones) {
        possibleMoves.append((c,r))
      }
    }
    if possibleMoves.count == 0 {
      return false
    }
    scene.placeValidMoveIndicator(possibleMoves, forStone: stone)
    stone.setPossibleMoves(possibleMoves)
    self.vulnerableStones = occupiedSquares
    
    return true
  }
  
  func secondJumpIsPossible(direction: JumpDirections, fromCoord: (c: Int, r: Int), inBoard stones: [[Stone?]]) -> Bool {
    return jumpIsPossible(withStone: scene.stones[fromCoord.c][fromCoord.r]!, inBoard: stones, forDirection: direction)
  }
  
  func findJumpedStone(inGroup adjacentStones: [Stone], withMove move: (c: Int,r: Int)) -> (c: Int, r: Int)? {
    for stone in adjacentStones {
      if move.r == stone.row && (move.c == (stone.column+1) || move.c == (stone.column-1)) {
        return (stone.column, stone.row)
      } else if move.c == stone.column && (move.r == (stone.row+1) || move.r == (stone.row-1)) {
        return (stone.column,stone.row)
      }
    }
    return nil
  }
  
  func findVulnerableStones(inGroup adjacentStones: [Stone], withMove: [(c: Int,r: Int)]) -> [Stone] {
    var vulnerable = [Stone]()
    for move in withMove {
      for stone in adjacentStones {
        if move.r == stone.row && (move.c == (stone.column+1) || move.c == (stone.column-1)) {
          vulnerable.append(stone)
        } else if move.c == stone.column && (move.r == (stone.row+1) || move.r == (stone.row-1)) {
          vulnerable.append(stone)
        }
      }
    }
    return vulnerable
  }
  
  func stoneExistsAt(square: (c: Int, r: Int), inBoard stones: [[Stone?]]) -> Bool {
    return stones[square.c][square.r] != nil
  }
  
  func directionJumped(from origin: (c: Int, r: Int), destination: (c: Int, r: Int)) -> JumpDirections {
    if destination.c > origin.c {
      return .East
    } else if destination.c < origin.c {
      return .West
    } else if destination.r > origin.r {
      return .North
    } else {
      return .South
    }
  }
  
  func jumpCoordinates(startingCoordinates: (c: Int, r: Int), direction: JumpDirections) -> (c: Int, r: Int) {
    var (c,r) = (startingCoordinates.c, startingCoordinates.r)
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
  
  func switchPlayerTurn(from currentTurn: StoneColor) {
    if currentTurn == .Black {
      playerTurn = .White
    } else {
      playerTurn = .Black
    }
    if scene.numberOfRemovedStones() == 2 {
      stateMachine.enterState(JumpingTiles)
    }
    if !anyMovesLeft() {
      stateMachine.enterState(GameOver)
    }
  }
  
  func withinBoundary(ofBoard board: Board, forCoord: (c: Int, r: Int)) -> Bool {
    let (w, h) = board.getBoardSize()
    if forCoord.c <= w-1 && forCoord.c >= 0 && forCoord.r <= h-1 && forCoord.r >= 0 {
      return true
    }
    return false
  }
  
  static func isValidStart(forCoord coord: (c: Int, r: Int)) -> Bool {
    // HARD-CODING CENTER AND CORNER FOR NOW
    // EVENTUALLY FIGURE IT OUT BASED ON SIZE OF BOARD
    let (column, row) = (coord.c, coord.r)
    let validMoves = [(4,4), (4,5), (5,4), (5,5), (0,0), (0,9),(9,0),(9,9)]
    return validMoves.contains() { (c,r) in
      return c == column && r == row
    }
  }
  
  static func isAdjacent(firstSpot coord1: (c: Int, r: Int), coord2: (c: Int, r: Int)) -> Bool {
    let adjacentSquares = [(coord1.c, coord1.r+1),(coord1.c, coord1.r-1),(coord1.c+1, coord1.r),(coord1.c-1, coord1.r)]
    return adjacentSquares.contains() { (c,r) in
      return c == coord2.c && r == coord2.r
    }
  }
  
  func anyMovesLeft() -> Bool {
    let currentBoard = scene.stones.flatMap({$0})
    let currentPlayerStones = currentBoard.filter { stone in
      stone != nil && stone?.stoneColor == playerTurn
    }
    
    for stone in currentPlayerStones {
      if jumpIsPossible(withStone: stone!, inBoard: scene.stones, forDirection: nil) {
        scene.removeIndicators()
        return true
      }
    }
    return false
  }
}