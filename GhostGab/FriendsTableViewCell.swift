//
//  FriendsTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Alamofire

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var friendsImageView: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    
    
    let green: Color = Color.green
    
    let white: Color = Color.white
    
    let lightGreen: Color = Color.lightGreen
    
    let lightRed: Color = Color.lightRed
    
    let width: Int = 1
   
    @IBOutlet weak var removeFriend: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setImageData (photoUrl: String) -> Void {
        
        let fileUrl = NSURL(string: photoUrl)
        Alamofire.request(photoUrl).responseData { response in
            if let alamofire_image = response.result.value {
                
                self.friendsImageView.image = UIImage(data: alamofire_image as Data)
                self.friendsImageView.layer.cornerRadius  = self.friendsImageView.frame.width/2
                self.friendsImageView.clipsToBounds = true;
                let costomization:UICostomization =  UICostomization(color: self.green.getColor(), width:1)
                costomization.addRoundedBorder(object: self.friendsImageView)
            }
        }

        
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
