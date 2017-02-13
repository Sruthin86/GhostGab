//
//  UnBlockViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/12/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SCLAlertView

class UnBlockViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var unBlockArray = [String: AnyObject]()
    
    var unBlockArrayKey = [String]()
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 65
        self.getBlockedUsers()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var imageName = "Reaction1_lg.png"
        var labelText = "you have no blocked users!!! "
        
        if let unBlockArrayKeyLength : Int = unBlockArrayKey.count{
            if (unBlockArrayKeyLength > 0){
                self.tableView.backgroundView = .none
                self.tableView.separatorStyle = .singleLine
                return unBlockArrayKeyLength
            }
            else {
                displyNoDataLabel(imageName:imageName, labelText:labelText)
                return 0
                
            }
        }
            
        else {
            
            displyNoDataLabel(imageName:imageName, labelText:labelText)
            return 0
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func displyNoDataLabel(imageName: String, labelText: String) -> Void {
        
        let image : UIImage = UIImage(named: imageName)!
        let imageView :UIImageView = UIImageView(image: image)
        imageView.frame = CGRect(x:self.tableView.frame.width/2 - 37.5, y:self.tableView.frame.height/3, width:75, height:99)
        let textColor: Color = Color.grey
        let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:self.tableView.frame.height/8, width:self.tableView.frame.width, height:self.tableView.frame.height) )
        
        noDataAvailableLabel.text =  labelText
        noDataAvailableLabel.textAlignment = .center
        noDataAvailableLabel.textColor =  textColor.getColor()
        noDataAvailableLabel.font = UIFont(name: "Avenir-Next", size:14.0)
        self.tableView.separatorStyle = .none
        var noFriendsView : UIView = UIView( frame: CGRect(x:0, y:300, width:self.tableView.frame.width, height:self.tableView.frame.height))
        noFriendsView.addSubview(imageView)
        noFriendsView.addSubview(noDataAvailableLabel)
        self.tableView.backgroundView = noFriendsView
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let unblockCell = tableView.dequeueReusableCell(withIdentifier: "unblock_cell", for: indexPath) as! UnBlockTableViewCell
        unblockCell.setImageData(photoUrl: self.unBlockArray[self.unBlockArrayKey[indexPath.row]]!.value(forKey :"highResPhoto")! as! String)
        unblockCell.BlockedUserName.text = self.unBlockArray[self.unBlockArrayKey[indexPath.row]]!.value(forKey :"displayName")! as? String
        unblockCell.unBlockButton.tag = indexPath.row
        unblockCell.unBlockButton.addTarget(self, action: #selector(self.unBlockUser), for: .touchUpInside)
        
        return unblockCell
    }
    
    
    func unBlockUser(sender: AnyObject){
        let unblockIndexPath = NSIndexPath(row: sender.tag, section: 0)
        var unblockUid = self.unBlockArrayKey[unblockIndexPath.row]
        
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("yes") {
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                self.ref.child("Users").child(self.currentUserId).child("blockedUsers").child(unblockUid).removeValue()
                self.ref.child("Users").child(unblockUid).child("blockedByUsers").child(self.currentUserId).removeValue()
                self.getBlockedUsers()
            }
        }
        alertView.addButton("No") {
            
            
        }
        alertView.showSuccess("Are you sure", subTitle: "Do you want to un block this user" , circleIconImage:checkAletViewImage)
        
    }
    
    func getBlockedUsers() {
        
        ref.child("Users").child(currentUserId).child("blockedUsers").observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            
            if (!snapshot.exists()){
                self.unBlockArray.removeAll()
                self.unBlockArrayKey.removeAll()
                self.tableView.reloadData()
            }
            else {
                self.unBlockArray.removeAll()
                self.unBlockArrayKey.removeAll()
                let unmuteData = snapshot.value as! [String:String]
                for (key,value) in unmuteData {
                    
                    self.ref.child("Users").child(key).observeSingleEvent(of: .value, with: { snapshot in
                        if(snapshot.childrenCount > 0 ){
                            let data:NSDictionary  = snapshot.value as! NSDictionary
                            self.unBlockArrayKey.append(key as! String)
                            self.unBlockArray[key as! String] = data as AnyObject?
                            self.tableView.reloadData()
                        }
                            
                        else {
                            
                            
                        }
                    })
                    
                }
                
            }
            
        })
    }
    
    
    @IBAction func back_button(_ sender: Any) {
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 4
        //trasition from left
        let transition = CATransition()
        transition.duration = 0.28
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
        self.present(mainTabBarView, animated: false, completion: nil)
    }
    
   
    
}

