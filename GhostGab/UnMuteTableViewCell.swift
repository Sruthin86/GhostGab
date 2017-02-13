//
//  UnMuteTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/12/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire

class UnMuteTableViewCell: UITableViewCell {

    @IBOutlet weak var mutedUserProfileImage: UIImageView!
    
    @IBOutlet weak var mutedUserName: UILabel!
    
    @IBOutlet weak var unmuteBtn: UIButton!
    
    var mutedUserUid: String?
    
    let green: Color = Color.green
    
    let white: Color = Color.white
    
    let lightGreen: Color = Color.lightGreen
    
    let lightRed: Color = Color.lightRed
    
    let width: Int = 1
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    
    let ref = FIRDatabase.database().reference()
    
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
    
    func setImageData (photoUrl: String) -> Void {
        
        let fileUrl = NSURL(string: photoUrl)
        Alamofire.request(photoUrl).responseData { response in
            if let alamofire_image = response.result.value {
                
                self.mutedUserProfileImage.image = UIImage(data: alamofire_image as Data)
                self.mutedUserProfileImage.layer.cornerRadius  = self.mutedUserProfileImage.frame.width/2
                self.mutedUserProfileImage.clipsToBounds = true;
                let costomization:UICostomization =  UICostomization(color: self.green.getColor(), width:1)
                costomization.addRoundedBorder(object: self.mutedUserProfileImage)
            }
        }
        
        
    }

   
}
