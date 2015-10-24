//
//  Board.swift
//  Konane
//
//  Created by Drew Lanning on 10/23/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

import SpriteKit

class Board: SKNode {
  private var width = 10
  private var height = 10
  let gridSize = 50
  
  override init() {
    super.init()
    drawBoard()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init()
    drawBoard()
  }
  
  func drawBoard() {
    for w in 0..<width {
      for h in 0..<height {
        let tile = SKSpriteNode(imageNamed: "tile")
        tile.position = CGPointMake(CGFloat(w*gridSize), CGFloat(h*gridSize))
        addChild(tile)
      }
    }
  }
  
  func getBoardSize() -> (Int,Int) {
    return (width,height)
  }
}
