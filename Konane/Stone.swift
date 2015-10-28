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
    addChild(sprite)
    self.userInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.column = aDecoder.valueForKey("column") as! Int
    self.row = aDecoder.valueForKey("row") as! Int
    self.sprite = aDecoder.valueForKey("sprite") as! SKSpriteNode
    self.color = aDecoder.valueForKey("color") as! StoneColor
    super.init()
    addChild(sprite)
    self.userInteractionEnabled = true
  }
  
  // BELOW IS TEMP FUNCTION FOR TESTING. EVENTUALLY PUT THIS INTO SCENE ONCE GAME LOGIC IS COMPLETE
  func removeStone() {
    (scene as! GameScene).stones[self.column][self.row] = nil
    self.removeFromParent()
  }
  
  // used by scene once valid moves are found, is this bad practice?
  func setPossibleMoves(possibleMoves: [(c:Int, r:Int)]) {
    self.possibleMoves = possibleMoves
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let coord = (self.column, self.row)
    let game = scene as! GameScene
    
    if removingStones {
      removeStone()
      game.increaseRemovedStones()
    } else if selectable {
      if game.jumpIsPossible(coord) {
        // GO INTO JUMPING STATE
        // NEXT TAP SELECTS JUMPS OR CLEARS JUMPING STATE ON THIS PIECE
      }
    }
  }
}
