//
//  RequestSuggestionTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Alamofire

class RequestSuggestionTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var rsImageView: UIImageView!
    
    @IBOutlet weak var rsLabel: UILabel!
    
    @IBOutlet weak var sendRequestBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    let green: Color = Color.green
    
    let white: Color = Color.white
    
    let lightGreen: Color = Color.lightGreen
    
    let lightRed: Color = Color.lightRed
    
    let width: Int = 1
    
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
                
                self.rsImageView.image = UIImage(data: alamofire_image as Data)
                self.rsImageView.layer.cornerRadius  = self.rsImageView.frame.width/2
                self.rsImageView.clipsToBounds = true;
                let costomization:UICostomization =  UICostomization(color: self.green.getColor(), width:1)
                costomization.addRoundedBorder(object: self.rsImageView)
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
