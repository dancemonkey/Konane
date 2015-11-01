//
//  KonaneModel.swift
//  Konane
//
//  Created by Drew Lanning on 10/29/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

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
  
  func jumpIsPossible(withStone stone: Stone, inBoard stones: [[Stone?]]) -> Bool {
    let origin = stones[stone.column][stone.row]
    
    var adjacentSquares = [(column: Int,row: Int)]()
    adjacentSquares.append((stone.column, stone.row+1)) // North
    adjacentSquares.append((stone.column, stone.row-1)) // South
    adjacentSquares.append((stone.column+1, stone.row)) // East
    adjacentSquares.append((stone.column-1, stone.row)) // West
    
    scene.removeIndicators()
    
    var occupiedSquares = [Stone]()
    for square in adjacentSquares {
      if stoneExistsAt(square, inBoard: stones) {
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
      if !stoneExistsAt((c,r), inBoard: stones) {
        possibleMoves.append((c,r))
      }
    }
    if possibleMoves.count == 0 {
      return false
    }
    scene.placeValidMoveIndicator(possibleMoves)
    stone.setPossibleMoves(possibleMoves)
    self.vulnerableStones = occupiedSquares
    
    return true
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
  
  func stoneExistsAt(square: (column: Int, row: Int), inBoard stones: [[Stone?]]) -> Bool {
    return stones[square.column][square.row] != nil
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
  
  func jumpCoordinates(startingCoordinates: (column: Int, row: Int), direction: JumpDirections) -> (c: Int, r: Int) {
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
  
  func switchPlayerTurn(from currentTurn: StoneColor) {
    if currentTurn == .Black {
      playerTurn = .White
    } else {
      playerTurn = .Black
    }
  }
  
  // STONE REMOVAL PSEUDOCODE
  // atRiskStones = occupiedSquares (from jumpIsPossible above)
  // reverseJumpDirection = take jump direction and subtract 1 in the opposite direction
  // removeStoneAtCoord = function that removes atRiskStone that matches (x,y) in reverseJumpDirection

}