//
//  GameScene.swift
//  hexagone
//
//  Created by Richard Urunuela on 05/10/2017.
//  Copyright © 2017 Richard Urunuela. All rights reserved.
//

import SpriteKit
import GameplayKit


//GRid

class Hexagone:SKSpriteNode {
    var edgeSize = 0

    convenience init?(edgeSize:CGFloat) {
    
        guard let texture = Hexagone.hexagoneTexture(edgeSize:CGFloat(edgeSize)) else {
            return nil
        }
        self.init(texture: texture, color:SKColor.clear, size: texture.size())
        self.edgeSize = Int(edgeSize)
    
        self.isUserInteractionEnabled = true
        //center
        //let Circle = SKShapeNode(circleOfRadius: 2 ) // Create circle
        //Circle.position = CGPoint(x: x, y:  y)  // Center (given scene anchor point is 0.5 for x&y)
        // Circle.strokeColor = SKColor.black
        // Circle.glowWidth = 1.0
        //Circle.fillColor = SKColor.orange
        //self.addChild(Circle)
        var scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "0,0"
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.fontSize = CGFloat(12)
        scoreLabel.position = CGPoint(x:0, y: edgeSize/4)
        addChild(scoreLabel)
        
        //
    }
    class func hexagoneTexture(edgeSize:CGFloat) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(edgeSize)  + 1.0, height: CGFloat(edgeSize) + 1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let rect = CGRect(x: edgeSize/2-3, y: edgeSize/2-3, width: 6, height: 6)

        
        SKColor.lightGray.setFill()
        context.fillEllipse(in: rect)
        
        
        
        let bezierPath = UIBezierPath()
        //let offset:CGFloat = 0.5
        let xcenter  = size.height / 2
        let ycenter  = size.width / 2
        //point top
        //let xpos = [0.5,1,1,0.5,0,0,0.5]
        //let ypos = [0,0.25,0.75,1,0.75,0.25,0]
        //flat top
        let ypos = [0.5,1,1,0.5,0,0,0.5]
        let xpos = [0,0.25,0.75,1,0.75,0.25,0]
        
        var xp = Int(xpos[0]*Double(edgeSize))
        var yp = Int(ypos[0]*Double(edgeSize))
        
        
        for i in 1...6 {
            
            bezierPath.move(to: CGPoint(x: xp, y:yp))
            
            xp = Int(xpos[i]*Double(edgeSize))
            yp = Int(ypos[i]*Double(edgeSize))
            bezierPath.addLine(to: CGPoint(x: CGFloat(xp), y: CGFloat(yp)))
            
        }
      
        bezierPath.fill()
        
        SKColor.red.setStroke()
        bezierPath.lineWidth = 2.0
        bezierPath.stroke()
     
        
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let res  = SKTexture(image: image!)
        
        
        
        
        
        
        return res
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint(" CLick hexagone")
    
    }
    
    
}
class Grid:SKSpriteNode {
    var rows:Int!
    var cols:Int!
    var blockSize:CGFloat!
    
    convenience init?(blockSize:CGFloat,rows:Int,cols:Int) {
        guard let texture = Grid.gridTexture(blockSize: blockSize,rows: rows, cols:cols) else {
            return nil
        }
        self.init(texture: texture, color:SKColor.clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
        self.isUserInteractionEnabled = true
        self.alpha = 0.3
    }
    
    class func gridTexture(blockSize:CGFloat,rows:Int,cols:Int) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        SKColor.white.setStroke()
        bezierPath.lineWidth = 1.0
        
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset = blockSize / 2.0 + 0.5
        let x = CGFloat(col) * blockSize - (blockSize * CGFloat(cols)) / 2.0 + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x:x, y:y)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let position = touch.location(in:self)
            let node = atPoint(position)
            
                let x = size.width / 2 + position.x
                let y = size.height / 2 - position.y
                let row = Int(floor(x / blockSize))
                let col = Int(floor(y / blockSize))
                print("\(row) \(col)")
            
        }
    }
}


class PlateauScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
      
       //self.label?.text = " HELLO"
        self.label?.removeFromParent()
        
        //GRID
        if let grid = Grid(blockSize: 20.0, rows:30, cols:30) {
            grid.position = CGPoint (x:frame.midX, y:frame.midY)
            //grid.position = CGPoint (x:frame.width / 8, y:-frame.height / 8)
            addChild(grid)
            
            /*let gamePiece = SKSpriteNode(imageNamed: "Spaceship")
            gamePiece.setScale(0.0625)
            gamePiece.position = grid.gridPosition(row: 1, col: 0)
            grid.addChild(gamePiece)*/
            
            
        }
        if let hex = Hexagone(edgeSize: 80.0){
            hex.position = CGPoint (x:0, y:0)
           addChild(hex)
        }
        if let hex = Hexagone(edgeSize: 80.0){
            hex.position = CGPoint (x:-60, y:40)
            addChild(hex)
        }
        if let hex = Hexagone(edgeSize: 80.0){
            hex.position = CGPoint (x:60, y:40)
            addChild(hex)
        }
        
        
       
    }
    
    // DrawGrid
    
    
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
    }
}
