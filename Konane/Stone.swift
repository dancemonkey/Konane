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

class Stone: SKNode {
  var column: Int
  var row: Int
  var sprite: SKSpriteNode
  let stoneSize = CGSizeMake(70, 70)
  private var possibleMoves = [(c: Int, r: Int)]?()
  var removingStones = false
  var selectable = false
  var selected = false
  var color: StoneColor
  
  init(column: Int, row: Int, stoneColor: StoneColor) {
    self.column = column
    self.row = row
    switch stoneColor {
    case .Black:
      self.sprite = SKSpriteNode(imageNamed: "blackStone")
      color = .Black
    case .White:
      self.sprite = SKSpriteNode(imageNamed: "whiteStone")
      color = .White
    }
    super.init()
    self.name = "stone"
    addChild(sprite)
    self.userInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.column = aDecoder.valueForKey("column") as! Int
    self.row = aDecoder.valueForKey("row") as! Int
    self.sprite = aDecoder.valueForKey("sprite") as! SKSpriteNode
    self.color = aDecoder.valueForKey("color") as! StoneColor
    super.init()
    self.name = "stone"
    addChild(sprite)
    self.userInteractionEnabled = true
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
    // HOW CAN I NOT DIRECTLY REFERENCE THE MODEL HERE?
    
    let game = scene as! GameScene
    
    if removingStones && self.color == game.gameModel.playerTurn {
      removeStone()
      game.increaseRemovedStones()
    } else if selectable && self.color == game.gameModel.playerTurn {
      if game.gameModel.jumpIsPossible(withStone: self, inBoard: game.stones) {
        game.clearSelectedStones()
        selected = true
        game.stoneJumping = true
      }
    }
  }
}
