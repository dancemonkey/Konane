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
    
    var occupiedSquares = [Stone]()
    for square in adjacentSquares {
      if stoneExistsAt(square, inBoard: stones) {                        // WRITE ME
        occupiedSquares.append(stones[square.column][square.row]!)
      }
    }
    if occupiedSquares.count == 0 {
      return false // all empty around origin, can't jump
    }
    
    var direction: JumpDirections
    var possibleMoves = [(c: Int, r: Int)]()
    for square in occupiedSquares {
      if square.column > origin?.column {
        direction = .East
      } else if square.column < origin?.column {
        direction = .West
      } else if square.row > origin?.row {
        direction = .North
      } else {
        direction = .South
      }
      let (c,r) = jumpCoordinates((square.column, square.row), direction: direction)
      if !stoneExistsAt((c,r), inBoard: stones) {
        possibleMoves.append((c,r))
      }
    }
    if possibleMoves.count == 0 {
      return false
    }
    
    return true
  }
  
  func stoneExistsAt(square: (column: Int, row: Int), inBoard stones: [[Stone?]]) -> Bool {
    return stones[square.column][square.row] != nil
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

}