//
//  RequestSuggestionTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 10/16/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit

class RequestSuggestionTableViewCell: UITableViewCell {

   
    @IBOutlet weak var rsImageView: UIImageView!
    
    @IBOutlet weak var rsLabel: UILabel!
    let green: Color = Color.green
    
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
        let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
        self.rsImageView.image = UIImage(data: profilePicUrl! as Data)
        self.rsImageView.layer.cornerRadius  = self.rsImageView.frame.width/2
        self.rsImageView.clipsToBounds = true;
        let costomization:UICostomization =  UICostomization(color: green.getColor(), width:1)
        costomization.addRoundedBorder(object: self.rsImageView)
    }
    
    
    
    
}
