//
//  Stone.swift
//  Konane
//
//  Created by Drew Lanning on 10/23/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

import SpriteKit

enum StoneColor: String {
  case Black
  case White
}

class Stone: SKSpriteNode {
  var column: Int
  var row: Int
  var spriteName: String
  let stoneSize = CGSizeMake(70, 70)
  private var possibleMoves = [(c: Int, r: Int)]?()
  var removingStones = false
  var selectable = false
  var selected = false
  var stoneColor: StoneColor
  
  init(column: Int, row: Int, stoneColor: StoneColor) {
    self.column = column
    self.row = row
    switch stoneColor {
    case .Black:
      self.spriteName = "blackStone"
      self.stoneColor = .Black
    case .White:
      self.spriteName = "whiteStone"
      self.stoneColor = .White
    }
    super.init(texture: SKTexture(imageNamed: spriteName), color: UIColor.clearColor(), size: stoneSize)
    self.name = "stone"
    self.userInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func removeStone() {
    (scene as! GameScene).stones[self.column][self.row] = nil
    self.removeFromParent()
  }
  
  func setPossibleMoves(possibleMoves: [(c:Int, r:Int)]) {
    self.possibleMoves = possibleMoves
  }
  
  func moveStone(toLocation location: (x: Int, y: Int), ofNode node: SKNode) {
    self.selected = false
    self.position = node.position
    self.column = location.x
    self.row = location.y
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    // HOW CAN I NOT DIRECTLY REFERENCE THE MODEL HERE? MOVE ALL TO MODEL OR SCENE?
    
    let game = scene as! GameScene
    
    if removingStones && self.stoneColor == game.gameModel.playerTurn {
      removeStone()
      game.increaseRemovedStones()
    } else if selectable && self.stoneColor == game.gameModel.playerTurn {
      if game.gameModel.jumpIsPossible(withStone: self, inBoard: game.stones) {
        game.clearSelectedStones()
        selected = true
        game.stoneJumping = true
      }
    } else if self.stoneColor != game.gameModel.playerTurn {
      game.clearSelectedStones()
      game.removeIndicators()
    }
  }
}
