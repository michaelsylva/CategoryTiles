//
//  CategoryMenu.swift
//  CategoryTiles
//
//  Created by Michael Sylva on 9/10/16.
//  Copyright © 2016 Michael Sylva. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class CategoryMenu: SKScene{
    
    var titles = [TitleNode]()
    var lastScroll: CGFloat = 0
    var topLimit: CGFloat = 0
    var bottomLimit: CGFloat = 0
    var listTop: CGFloat = 0
    var listBottom: CGFloat = 0
    var topSpring: CGFloat = 0
    var bottomSpring: CGFloat = 0
    
    override func didMoveToView(view: SKView) {
        let data = GameData()
        self.size = view.bounds.size
        
        self.backgroundColor = UIColor.whiteColor()
        let tap = UITapGestureRecognizer(target: self, action:#selector(CategoryMenu.handleTap(_:)))
        view.addGestureRecognizer(tap)
 
        let pan = UIPanGestureRecognizer(target: self, action:#selector(CategoryMenu.handlePan(_:)))
        view.addGestureRecognizer(pan)
        
        let categories : [TitleNode] = data.getCategoryList()
        titles = categories
        
        var count : CGFloat = self.size.height-50
    
        for title in categories {
            var spriteNode : SKSpriteNode? = nil
            if(title.title=="Sports"){
                spriteNode = SKSpriteNode(imageNamed: "sportsbanner.png")
            }else{
                spriteNode = SKSpriteNode(imageNamed: "blankbanner.png")
            }
            
            spriteNode!.position = CGPointMake(CGFloat(self.size.width/2), count)
            spriteNode!.name = title.title
            if (topLimit  == 0) {
                topLimit = count
                listTop = count
            }
            count-=90
            title.setNode(spriteNode!)
            self.addChild(spriteNode!)
        }
        bottomLimit = count
        listBottom = count
        if (bottomLimit < 0) {
            bottomLimit = 0
        }
        topSpring = topLimit - 50
        bottomSpring = bottomLimit + 50
    }
    
    func handleTap(recognizer: UITapGestureRecognizer){
        print("recognizer",recognizer.state)
        if recognizer.state == .Ended {
            clearTouchHighlight()
            var touchLocation: CGPoint = recognizer.locationInView(recognizer.view)
            touchLocation = self.convertPointFromView(touchLocation)
            //let touch = recognizer.locationOfTouch(0, inView: self.view)
            let touchedNode = self.nodeAtPoint(touchLocation)
            print ("touch: \(touchLocation.x) - \(touchLocation.y)")
            print ("tap \(touchedNode.name)")
            if(touchedNode.name != nil) {
                let scene = MenuScene(fileNamed: "MenuScene")
                scene?.initialize(touchedNode.name!)
                self.view?.presentScene(scene)
             }
        }
    }
    
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        clearTouchHighlight()
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            //let translation = gestureRecognizer.translationInView(self.view)
            //print ("start:\(translation.y)")
            lastScroll = 0.0
        }
        if gestureRecognizer.state == UIGestureRecognizerState.Changed {
            let translation = gestureRecognizer.translationInView(self.view)
            //print ("pan:  \(translation.y)")
            // note: 'view' is optional and need to be unwrapped
            
            scrollTitles(translation.y - lastScroll)
            lastScroll = translation.y
        }
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            scrollSpring()
        }
    }
    
    func scrollTitles(y: CGFloat) {
        let lastTop = listTop
        let lastBottom = listBottom
        
        var moveY = -y
        var newTop = lastTop + moveY
        var newBottom = lastBottom + moveY
        
        if (moveY < 0) {
            if (newTop < topSpring) {
                //print ("too far down")
                newTop = topSpring
                moveY = lastTop - topSpring
            }
        }
        if (moveY > 0) {
            if (newBottom > bottomSpring) {
                //print ("too far up")
                newBottom = bottomSpring
                moveY = newBottom - lastBottom
            }
        }
        listTop += moveY
        listBottom += moveY
        //print ("move = \(moveY)")
        for title in titles {
            let spriteNode = title.getNode()
            spriteNode?.position.y += moveY
        }
    }
    func scrollSpring() {
        var moveY: CGFloat = 0
        if (listTop < topLimit) {
            moveY = topLimit - listTop
        }
        if (listBottom > bottomLimit) {
            moveY = bottomLimit - listBottom
        }
        if (moveY != 0) {
            listTop += moveY
            listBottom += moveY
            //print ("spring move = \(moveY)")
            for title in titles {
                let spriteNode = title.getNode()
                spriteNode?.position.y += moveY
            }
        }
    }
    
    func clearTouchHighlight() {
        for title in titles {
            let spriteNode = title.getNode() as! SKSpriteNode
            spriteNode.color = UIColor.blackColor()
            spriteNode.colorBlendFactor = 0.0
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let first = touches.first!
        let pos = first.locationInNode(self)
        print ("touch began: \(pos.x) - \(pos.y)")
        let node = self.nodeAtPoint(pos)
        let sprite = node as? SKSpriteNode
        if (sprite != nil) {
            sprite!.color = UIColor.blackColor()
            sprite!.colorBlendFactor = 0.25
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        clearTouchHighlight()
        let first = touches.first!
        let pos = first.locationInNode(self)
        print ("touch moved: \(pos.x) - \(pos.y)")
        let node = self.nodeAtPoint(pos)
        let sprite = node as? SKSpriteNode
        if (sprite != nil) {
            sprite!.color = UIColor.blackColor()
            sprite!.colorBlendFactor = 0.25
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print ("touches ended")
        clearTouchHighlight()
    }
}