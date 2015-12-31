
/*   ___________________   ____ __   _______    __  __  __
    ╱ _____╱ _  |__  __╱  / __ `__ \/ _____/   ╱ ╱|╱ ╱|╱ ╱|
   ╱ ____╱/ __  | ╱ ╱|   / / / / / / ____/|   ╱_╱ ╱_╱ ╱_╱
  ╱______/_╱  |_|╱_╱    /_/ /_/ /_/______/   ╱_╱|╱_╱|╱_╱|
  |     | |   | | |     | | | | | |     |   | | | | | |

*/

import SpriteKit


struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Hero      : UInt32 = 0x01
  static let Bomb      : UInt32 = 0x02
  static let Food      : UInt32 = 0x03
}



class GameScene: SKScene, SKPhysicsContactDelegate {

  let hero = SKSpriteNode(imageNamed: "emoji_jiong")
  
  override func didMoveToView(view: SKView) {
    
    
    // 设定物理世界
    physicsWorld.gravity = CGVectorMake(0, 0)
    physicsWorld.contactDelegate = self
    
    
    //**--------------------------噔噔噔!英雄出场!--------------------------**//
    hero.position = CGPoint(x: size.width * 0.5, y: hero.size.height)
    
    //英雄的物理实体
    hero.physicsBody = SKPhysicsBody(rectangleOfSize: hero.size) // 创建物理实体
    hero.physicsBody?.dynamic = true // 让sprite位动态的，可以不让物理实体控制住sprite，让sprite继续之前设定的action
    hero.physicsBody?.categoryBitMask = PhysicsCategory.Hero // 设定之前声明好的物理实体类别
    hero.physicsBody?.contactTestBitMask = PhysicsCategory.Food // 设定与另一实体类别相交时会通知
    hero.physicsBody?.contactTestBitMask = PhysicsCategory.Bomb // 设定与另一实体类别相交时会通知
    hero.physicsBody?.collisionBitMask = PhysicsCategory.None // monster和飞镖相撞之后没有什么结果，所以忽略为零(要不然会被撞飞)
    
    addChild(hero)
    
    
    //**--------------------------让sprite动起来--------------------------**//
    //生成随机时间
    let random4gap = random(min: CGFloat(0.8), max: CGFloat(1.2))
    
    //take action！
    runAction(SKAction.repeatActionForever(  //循环动作
      SKAction.sequence([ //按时间顺序添加一系列动作
        SKAction.runBlock(fallingItems), //添加monster
        SKAction.waitForDuration(Double(random4gap))//等待
        ])
      ))
    
  }
  

  //**---------------------巴拉巴拉小魔仙变！天空降雨!-----------------------**//
  func fallingItems() {
    
    // Random出 掉落物品
    let fallingItemNames = ["emoji_bomb","emoji_apple"]
//    let fallingItemNames = ["emoji_bomb","emoji_apple","emoji_stawberry","emoji_lemon","emoji_grape","emoji_orange"]
    let randomName4fall = Int(arc4random_uniform(UInt32(fallingItemNames.count)))
    
    // 生成掉落物
    let fall = SKSpriteNode(imageNamed: fallingItemNames[randomName4fall])
    fall.setScale(0.5)
    
    
//    // Random出 掉落物品的x
//    let randomX4fall = random(min: fall.size.width/2, max: size.width - fall.size.width/2)
//    
    //调试x
      let randomX4fall = size.width/2
    //添加fall到屏幕
    fall.position = CGPoint(x: randomX4fall, y: size.height + fall.size.height)
    
    //fall的物理实体
    fall.physicsBody = SKPhysicsBody(circleOfRadius: fall.size.width/2) // 创建物理实体
    fall.physicsBody?.dynamic = true // 让sprite位动态的，可以不让物理实体控制住sprite，让sprite继续之前设定的action
    //如果是bomb，定义为炸弹，其他为food
    if randomName4fall == 0{
      fall.physicsBody?.categoryBitMask = PhysicsCategory.Bomb // 设定之前声明好的物理实体类别
      print("bomb")
    }else{
      fall.physicsBody?.categoryBitMask = PhysicsCategory.Food // 设定之前声明好的物理实体类别
    }

    fall.physicsBody?.contactTestBitMask = PhysicsCategory.Hero // 设定与另一实体类别相交时会通知
    fall.physicsBody?.collisionBitMask = PhysicsCategory.None // monster和飞镖相撞之后没有什么结果，所以忽略为零
    fall.physicsBody?.usesPreciseCollisionDetection = true //如果你的物理实体快速移动，那要设定这个


    addChild(fall)
    
    // 添加动作
    let fallSpeed = random(min: CGFloat(200.0), max: CGFloat(300))
    let fallMove = SKAction.moveToY(0 - fall.size.height, duration: Double((size.height+fall.size.height)/fallSpeed))
    let fallMoveDone = SKAction.removeFromParent()
    fall.runAction(SKAction.sequence([fallMove , fallMoveDone]))
  
  }
  
  
  //定义一个碰撞事件，等待调用
  func FoodEaten(fall:SKSpriteNode, hero:SKSpriteNode) {
    print("FoodEaten!")
//    fall.removeFromParent()
  }
  func BombBeaten(fall:SKSpriteNode, hero:SKSpriteNode) {
    print("BombBeaten!")

  }
  
  
  //监听碰撞发生
  func didBeginContact(contact: SKPhysicsContact) {
    
    // 1
    
    
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
  
//    if ((firstBody.categoryBitMask & PhysicsCategory.Food != 0) &&
//      (secondBody.categoryBitMask & PhysicsCategory.Hero != 0)) {
//        FoodEaten(firstBody.node as! SKSpriteNode, hero: secondBody.node as! SKSpriteNode)
//        
//    }
      if((firstBody.categoryBitMask & PhysicsCategory.Bomb != 0) &&
      (secondBody.categoryBitMask & PhysicsCategory.Hero != 0)) {
        BombBeaten(firstBody.node as! SKSpriteNode, hero: secondBody.node as! SKSpriteNode)
    }
  }
  
  
  //**---------------------生成随机数的方法----------------------**//
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
  
  
}

