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
        uid = UserDefaults.standard.object(forKey: fireBaseUid) as? String
        let databaseRef = FIRDatabase.database().reference()
        profileImage.layer.cornerRadius  = self.profileImage.frame.width/2
        profileImage.clipsToBounds = true;
        databaseRef.child("Users").child(uid!).observe(FIRDataEventType.value, with: { (snapshot) in
            
          let userDetails = snapshot.value as! [String: AnyObject]
            self.fullName.text =  userDetails["displayName"] as? String;
            let fileUrl = NSURL(string: userDetails["highResPhoto"] as! String)
            let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
            self.profileImage.image = UIImage(data: profilePicUrl! as Data)
            
        })
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myFeedCell = tableView.dequeueReusableCell(withIdentifier: "MyFeedCell", for: indexPath as IndexPath) as! MyFeedTableViewCell
        myFeedCell.ReactionsContent.isHidden = true
        myFeedCell.reactButton.tag = indexPath.row
        myFeedCell.reactButton.addTarget(self, action: #selector(self.reactionsActions), for: .touchUpInside)
        guard self.selectedInxexPath != nil else {
            
            return myFeedCell
        }
        if (self.selectedInxexPath! as IndexPath == indexPath){
            myFeedCell.ReactionsContent.isHidden = false
        }
        return myFeedCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func reactionsActions(sender: AnyObject) -> Void {
        let selectedCellIndexPath = NSIndexPath(row: sender.tag, section: 0)
        selectedInxexPathsArray.removeAll()
        if (selectedInxexPath != nil) {
            let previousSelectedPath :NSIndexPath = selectedInxexPath!
            print(previousSelectedPath.row)
            selectedInxexPathsArray.append(previousSelectedPath)
        }
        
      
        
       
       guard ((selectedInxexPath) != nil)  else {
            
            selectedInxexPath = selectedCellIndexPath
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.tableView.reloadRows(at: selectedInxexPathsArray as [IndexPath], with: UITableViewRowAnimation.fade)
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! MyFeedTableViewCell
            cell.openReactionsView()
            return
            
        }
        
        if selectedInxexPath!.row != selectedCellIndexPath.row{
            selectedInxexPath = selectedCellIndexPath
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.tableView.reloadRows(at: selectedInxexPathsArray as [IndexPath], with: UITableViewRowAnimation.fade)
            self.tableView.beginUpdates()
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! MyFeedTableViewCell
            cell.openReactionsView()
            self.tableView.endUpdates()
            
        }
        else if (selectedInxexPath!.row == selectedCellIndexPath.row){
            selectedInxexPathsArray.append(selectedInxexPath!)
            self.selectedInxexPath = nil
            let cell = tableView.cellForRow(at: selectedCellIndexPath as IndexPath) as! MyFeedTableViewCell
            cell.closeReactionsView()
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: selectedInxexPathsArray as [IndexPath], with: UITableViewRowAnimation.fade)
            self.tableView.endUpdates()
            selectedInxexPathsArray.removeAll()
            
        }
        
        
        
    }
    
    
    
}
