//
//  SCLExtensions.swift
//  SCLAlertView
//
//  Created by Christian Cabarrocas on 16/04/16.
//  Copyright © 2016 Alexey Poimtsev. All rights reserved.
//

import UIKit

extension Int {
    
    func toUIColor() -> UIColor {
        return UIColor(
            red: CGFloat((self & 0xFB003F) >> 16) / 255.0,
            green: CGFloat((self & 0x00BB9C) >> 8) / 255.0,
            blue: CGFloat(self & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func toCGColor() -> CGColor {
        return self.toUIColor().cgColor
    }
}

extension UInt {
    
    func toUIColor() -> UIColor {
        return UIColor(
            red: CGFloat((self & 0xFB003F) >> 16) / 255.0,
            green: CGFloat((self & 0x00BB9C) >> 8) / 255.0,
            blue: CGFloat(self & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func toCGColor() -> CGColor {
        return self.toUIColor().cgColor
    }
}
