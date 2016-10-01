//
//  loadingAnimation.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/3/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation

struct loadingAnimation {
    
    var imageName = "loading_00001.png"
    var overlayView :UIView
    var senderView:UIView
    var image : UIImage
    var imageView :UIImageView
    
    
    init (overlayView :UIView, senderView:UIView){
        
        self.overlayView = overlayView
        self.senderView = senderView
        image = UIImage(named: imageName)!
        imageView = UIImageView(image: image)
    }
    
    
    mutating func showOverlay(alphaValue:CGFloat) {
       
        
        overlayView = UIView(frame: senderView.frame)
        overlayView.backgroundColor = UIColor( red: 1, green: 1, blue:1, alpha:alphaValue )
        
        
        imageView.animationImages = [UIImage]()
        for index in 1 ..< 4 {
            let frameName = String(format: "loading_%05d", index)
            imageView.animationImages?.append(UIImage(named: frameName)!)
        }
        
        
        
        imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 48)
        imageView.center = CGPointMake(senderView.bounds.width / 2, senderView.bounds.height / 2)
        
        senderView.addSubview(overlayView)
        senderView.addSubview(imageView)
        
        imageView.animationDuration = 1
        imageView.startAnimating()
        
        
        
        //self.view.addSubview(overlayView)
        
        
    }
    
    func hideOverlayView() {
        imageView.stopAnimating()
        imageView.removeFromSuperview()
        overlayView.removeFromSuperview()
    }
}
