//
//  GameScene.swift
//  project17
//
//  Created by Tamim Khan on 13/3/23.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLable: SKLabelNode!
    
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var enemyCount = 0
    
    var score = 0{
        didSet{
            scoreLable.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .black
        
        starField = SKEmitterNode(fileNamed: "starfield")!
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        
        scoreLable = SKLabelNode(fontNamed: "Chalkuster")
        scoreLable.position = CGPoint(x: 16, y: 16)
        scoreLable.horizontalAlignmentMode = .left
        addChild(scoreLable)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(creatEnemy), userInfo: nil, repeats: true)
        
    }
    
    @objc func creatEnemy(){
        guard let enemy = possibleEnemies.randomElement() else {return}
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        enemyCount += 1

            
            if enemyCount % 20 == 0 {
                gameTimer?.invalidate() // Stop the current timer
                let newTimeInterval = max(0.9, gameTimer?.timeInterval ?? 1.0 - 0.1) // Calculate the new interval, with a minimum of 0.9 seconds
                gameTimer = Timer.scheduledTimer(timeInterval: newTimeInterval, target: self, selector: #selector(creatEnemy), userInfo: nil, repeats: true) // Start the new timer
            }
    }
    
    
   
    
    override func update(_ currentTime: TimeInterval) {
        for node in children{
            if node.position.x < -300{
                node.removeFromParent()
            }
        }
        if !isGameOver{
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        var location = touch.location(in: self)
       
        
        if location.y < 100 {
            location.y = 100
        }else if location.y > 668 {
            location.y = 668
        }
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
        gameTimer?.invalidate()

    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Remove the player's ability to move
        player.physicsBody?.isDynamic = false
        
        // Wait for the player to tap the screen again before allowing movement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.player.physicsBody?.isDynamic = true
        }
    }

    
}
