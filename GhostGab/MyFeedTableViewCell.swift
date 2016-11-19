//
//  MyFeedTableViewCell.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation

class MyFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var FeedView: UIView!
    @IBOutlet weak var reactButton: UIButton!
    @IBOutlet weak var reactionsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ReactionsContent: UIView!
    @IBOutlet weak var ReactionsView: UIView!
    var cellSelected: Bool = false
    var width:CGFloat = 0.4
    override func awakeFromNib() {
        let verylightGrey : Color = Color.verylightGrey
        let customization: UICostomization = UICostomization (color: verylightGrey.getColor(), width:width)
        customization.addBackground(object: self)
        customization.addBorder(object: ReactionsView)
        //customization.addBorder(object: FeedView)
        super.awakeFromNib()
        reactionsViewHeight.constant = 0
        self.ReactionsContent.isHidden = true
        self.ReactionsView.isHidden = true
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func openReactionsView(){
        
        reactionsViewHeight.constant = 76
        self.ReactionsContent.isHidden = false
        self.ReactionsView.isHidden = false
        
    }
    func closeReactionsView(){
        reactionsViewHeight.constant = 0
        self.ReactionsContent.isHidden = true
        self.ReactionsView.isHidden = true
        
    }
    
    
}
