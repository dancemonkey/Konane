//
//  ValidMoveIndicator.swift
//  Konane
//
//  Created by Drew Lanning on 11/8/15.
//  Copyright © 2015 Drew Lanning. All rights reserved.
//

import SpriteKit

class ValidMoveIndicator: SKShapeNode {
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
    super.init()
    let rect = CGRect(origin: CGPointZero, size: size)
    strokeColor = UIColor.whiteColor()
    fillColor = UIColor.redColor()
    alpha = 0.75
    lineWidth = 2.0
    name = "move indicator"
    zPosition = 15
    self.path = CGPathCreateWithRect(rect, nil)
    self.userInteractionEnabled = true
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let scene = (self.scene as! GameScene)
    for touch in touches {
      scene.handleJumps(forTouch: touch, onStone: self.stone!)
    }
  }
}
