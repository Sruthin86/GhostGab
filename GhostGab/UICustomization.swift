//
//  UICustomization.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/14/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//




import UIKit
import Foundation


struct UICostomization {
    var color:UIColor
    var width:CGFloat
    
    init(color:UIColor, width:CGFloat){
        self.color = color
        self.width = width
    }
    
    func addBorder(object:AnyObject){
        object.layer.borderWidth = self.width
        object.layer.borderColor = self.color.CGColor
    }
    
    func addBackground(object:AnyObject){
        object.layer.backgroundColor = self.color.CGColor
    }
    
    func addRoundedBorder (object:UIImageView) -> Void {
        
      object.layer.cornerRadius  = object.frame.width/2
      object.clipsToBounds = true;
      addBorder(object)
    }
}
