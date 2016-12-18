//
//  Color.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import Foundation
import UIKit


enum Color {
    case green, verylightGrey, lightGrey, grey, red, white , lightGreen, lightRed, yellow
    
    func getColor() -> UIColor {
        
        switch self {
            
        case .green:
            let myColor : UIColor = UIColor( red: 0.00, green: 0.65, blue:0.47, alpha: 1.0 )
            return myColor
        case .lightGreen:
            let myColor : UIColor = UIColor( red: 0.00, green: 0.65, blue:0.47, alpha: 0.2 )
            return myColor
        case .verylightGrey:
            let myColor :UIColor = UIColor( red: 0.87, green: 0.87, blue:0.87, alpha: 0.2 )
            return myColor
        case .lightGrey:
            let myColor :UIColor = UIColor( red: 0.87, green: 0.87, blue:0.87, alpha: 1 )
            return myColor
        case .grey:
            let myColor :UIColor = UIColor(red: 0.47, green: 0.48, blue:0.52, alpha: 1)
            return myColor
        case .red:
            let myColor :UIColor = UIColor(red: 0.98, green: 0.00, blue:0.25, alpha: 1)
            return myColor
        case .lightRed:
            let myColor :UIColor = UIColor(red: 0.98, green: 0.00, blue:0.25, alpha: 0.1)
            return myColor
        case .white:
            let myColor :UIColor = UIColor(red: 1.00, green: 1.00, blue:1.00, alpha: 1)
            return myColor
        case .yellow:
            let myColor :UIColor = UIColor(red: 0.80, green: 0.94, blue:0.25, alpha: 1)
            return myColor
        }
        
        
    }
}
