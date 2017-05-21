//
//  NotificationTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/20/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationStatusImage: UIImageView!
    
    @IBOutlet weak var notificationText: UILabel!
    
    @IBOutlet weak var notificationDateLabel: UILabel!
    
    @IBOutlet weak var deleteNotification: UIButton!
    
    let green: Color = Color.green
    
    let white: Color = Color.white
    
    let lightGreen: Color = Color.lightGreen
    
    let lightRed: Color = Color.lightRed
    
    let width: Int = 1
    
    var notificationId : String?
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
     var helperClass : HelperFunctions = HelperFunctions()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setBackground(colorValue:String){
        switch colorValue {
        case "lightGreen":
            let customization: UICostomization = UICostomization (color: lightGreen.getColor(), width:CGFloat(width))
            customization.addBackground(object: self)
        case "lightRed":
            let customization: UICostomization = UICostomization (color: lightRed.getColor(), width:CGFloat(width))
            customization.addBackground(object: self)
            
        default:
            let customization: UICostomization = UICostomization (color: white.getColor(), width:CGFloat(width))
            customization.addBackground(object: self)
            
        }
    }
    
    
   
    
   
        
    
    
    

}
