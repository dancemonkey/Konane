//
//  ValidMoveIndicator.swift
//  Konane
//
//  Created by Drew Lanning on 11/8/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

import SpriteKit

class ValidMoveIndicator: SKSpriteNode {
  var column: Int
  var row: Int
  var stone: Stone?
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("coder no workee yet")
  }
  
  init(column: Int, row: Int, stone: Stone?) {
    self.column = column
    self.row = row
    self.stone = stone
    let size = CGSizeMake(CGFloat(Board.gridSize), CGFloat(Board.gridSize))
    super.init(texture: SKTexture(imageNamed: "tile"), color: UIColor.redColor(), size: size)
    alpha = 0.75
    name = "move indicator"
    zPosition = 15
    self.userInteractionEnabled = true
    self.color = UIColor.redColor()
    self.colorBlendFactor = 1.0
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let scene = (self.scene as! GameScene)
    for touch in touches {
      if self.stone!.selected {
        scene.handleJumps(forTouch: touch, onStone: self.stone!)
      }
    }
  }
}
