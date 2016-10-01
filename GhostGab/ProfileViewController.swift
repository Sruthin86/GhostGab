//
//  ProfileViewController.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/7/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var uid :String?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    
    let KclosedHeight : CGFloat = 144
    let KopenHeight :CGFloat = 220
    
    var selectedInxexPath: NSIndexPath?
    var selectedInxexPathsArray :[NSIndexPath] = []
    
    
    override func viewDidLoad() {
        uid = NSUserDefaults.standardUserDefaults().objectForKey(fireBaseUid) as? String
        let databaseRef = FIRDatabase.database().reference()
        profileImage.layer.cornerRadius  = self.profileImage.frame.width/2
        profileImage.clipsToBounds = true;
        databaseRef.child("Users").child(uid!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
          let userDetails = snapshot.value as! [String: AnyObject]
            self.fullName.text =  userDetails["displayName"] as? String;
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
            let profilePicUrl = NSData(contentsOfURL:  fileUrl!)
            self.profileImage.image = UIImage(data: profilePicUrl!)
            
        })
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myFeedCell = tableView.dequeueReusableCellWithIdentifier("MyFeedCell", forIndexPath: indexPath) as! MyFeedTableViewCell
        myFeedCell.ReactionsContent.hidden = true
        myFeedCell.reactButton.tag = indexPath.row
        myFeedCell.reactButton.addTarget(self, action: #selector(self.reactionsActions), forControlEvents: .TouchUpInside)
        guard self.selectedInxexPath != nil else {
            
            return myFeedCell
        }
        if (self.selectedInxexPath! == indexPath){
            myFeedCell.ReactionsContent.hidden = false
        }
        return myFeedCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let selIndex = selectedInxexPath?.row {
            if(selIndex == indexPath.row){
                return KopenHeight
            }
            else {
                return KclosedHeight
            }
        }
        else {
            return KclosedHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func reactionsActions(sender: AnyObject) -> Void {
        let selectedCellIndexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        selectedInxexPathsArray.removeAll()
        if (selectedInxexPath != nil) {
            let previousSelectedPath :NSIndexPath = selectedInxexPath!
            print(previousSelectedPath.row)
            selectedInxexPathsArray.append(previousSelectedPath)
        }
        
      
        
       
       guard ((selectedInxexPath) != nil)  else {
            
            selectedInxexPath = selectedCellIndexPath
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.tableView.reloadRowsAtIndexPaths(selectedInxexPathsArray, withRowAnimation: UITableViewRowAnimation.Fade)
            let cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath) as! MyFeedTableViewCell
            cell.openReactionsView()
            return
            
        }
        
        if selectedInxexPath!.row != selectedCellIndexPath.row{
            selectedInxexPath = selectedCellIndexPath
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.tableView.reloadRowsAtIndexPaths(selectedInxexPathsArray, withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.beginUpdates()
            let cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath) as! MyFeedTableViewCell
            cell.openReactionsView()
            self.tableView.endUpdates()
            
        }
        else if (selectedInxexPath!.row == selectedCellIndexPath.row){
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.selectedInxexPath = nil
            let cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath) as! MyFeedTableViewCell
            cell.closeReactionsView()
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths(selectedInxexPathsArray, withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.endUpdates()
            selectedInxexPathsArray.removeAll()
            
        }
        
        
        
    }
    
    
    
}
