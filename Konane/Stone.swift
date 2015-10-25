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
  let stoneColor: UIColor
  var sprite: SKShapeNode
  let stoneSize = CGSizeMake(35, 35)
  
  init(column: Int, row: Int, stoneColor: StoneColor) {
    self.column = column
    self.row = row
    switch stoneColor {
    case .Black:
      self.stoneColor = UIColor.blackColor()
    case .White:
      self.stoneColor = UIColor.whiteColor()
    }
    self.sprite = SKShapeNode(ellipseOfSize: stoneSize)
    self.sprite.fillColor = self.stoneColor
    self.sprite.strokeColor = UIColor.blackColor()
    super.init()
    addChild(sprite)
    self.userInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.column = aDecoder.valueForKey("column") as! Int
    self.row = aDecoder.valueForKey("row") as! Int
    self.stoneColor = aDecoder.valueForKey("stoneColor") as! UIColor
    self.sprite = SKShapeNode(ellipseOfSize: stoneSize)
    self.sprite.fillColor = self.stoneColor
    super.init()
    addChild(sprite)
    self.userInteractionEnabled = true
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let coord = (self.column, self.row)
    if (scene as! GameScene).jumpIsPossible(coord) {
      
    }
    
    // REMEMBER BELOW TO USE FOR REMOVING STONE FROM BOARD AND FROM SCENE, WHILE RETAINING ARRAY STRUCTURE
    (scene as! GameScene).stones[self.column][self.row] = nil
    self.removeFromParent()
  }
}
