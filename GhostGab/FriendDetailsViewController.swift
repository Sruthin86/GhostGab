//
//  FriendDetailsViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/12/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import SCLAlertView
import Alamofire

class FriendDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ref = FIRDatabase.database().reference()
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    var friendUdid: String?
    
    let green : Color = Color.green
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    @IBOutlet weak var cashLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var helperClass : HelperFunctions = HelperFunctions()
    
    var friendDetailsList :[String] = ["View public Gabs","Unfriend","Mute User","Block User","Report User"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.getFriendDetails()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendDetailsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendDetailsCell = tableView.dequeueReusableCell(withIdentifier: "friend_details_cell", for: indexPath) as! FriendDetailsTableViewCell
        
        friendDetailsCell.cellLabel.text = friendDetailsList[indexPath.row]
        if(friendDetailsList[indexPath.row] != "View public Gabs" ){
            friendDetailsCell.cell_image.isHidden = true
        }
        
        return friendDetailsCell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //
    }
    
    
    func getFriendDetails() {
        self.ref.child("Users").child(self.friendUdid!).observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            if(snapshot.exists()){
                let friendData =  snapshot.value as! NSDictionary
                self.displayName.text = friendData["displayName"] as! String
                self.cashLabel.text = friendData["cash"]as! String
                
                let fileUrl = NSURL(string: friendData["highResPhoto"] as! String)
                Alamofire.request(friendData["highResPhoto"] as! String).responseData { response in
                    if let alamofire_image = response.result.value {
                        let profilePicUrl = NSData(contentsOf:  fileUrl! as URL)
                        self.profileImage.image = UIImage(data: profilePicUrl! as Data)
                        
                    }
                }
                self.profileImage.layer.cornerRadius  = self.profileImage.frame.width/2
                self.profileImage.clipsToBounds = true;
                self.profileImage.layer.cornerRadius  = self.profileImage.frame.width/2
                self.profileImage.clipsToBounds = true;
                let customization: UICostomization  = UICostomization(color:self.green.getColor(), width: 5 )
                customization.addBorder(object: self.profileImage)
            }
        })
    }
    @IBAction func back_btn(_ sender: Any) {
        
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 1
        let transition = CATransition()
        transition.duration = 0.28
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
        self.present(mainTabBarView, animated: false, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let seletedIndex = indexPath.row
        if(self.friendDetailsList[seletedIndex] == "View public Gabs"){
            let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
            let friendPublicPostView  = storybaord.instantiateViewController(withIdentifier: "friend_public_post") as! FriendPublicPostsViewController
            friendPublicPostView.friendUdid = self.friendUdid
            //trasition from right
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
            self.present(friendPublicPostView, animated: false, completion: nil)
        }
        else if(self.friendDetailsList[seletedIndex] == "Unfriend"){
            self.unfriend()
        }
        else if(self.friendDetailsList[seletedIndex] == "Mute User"){
            self.muteUser()
        }
        else if(self.friendDetailsList[seletedIndex] == "Block User"){
            self.blockUser()
        }
        else if(self.friendDetailsList[seletedIndex] == "Report User"){
            self.reportUser()
        }



    }
    
    
    func reportUser(){
        helperClass.reportUserWithUserId(_rpreportedUserId: friendUdid!)
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Okay") {
            
            print("Second button tapped")
        }
        alertView.showInfo("Thank you", subTitle: "This user has been reported. We are immediately looking at your concerns" , circleIconImage:checkAletViewImage)
        
    }
    
    func unfriend() {
        self.ref.child("Users").child(uid as! String).child("Friends").child(friendUdid!).removeValue()
        self.ref.child("Users").child(friendUdid!).child("Friends").child(uid as! String).removeValue()
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Okay") {
            
        }
        alertView.showInfo("Unfriended", subTitle: "This user has been removed from your friends list. You will not see their activity in your timeline" , circleIconImage:checkAletViewImage)
    }
    
    func muteUser(){
        helperClass.muteUserWithuserId(_otherUserUid: friendUdid!, userUid: uid as! String)
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Okay") {
            
        }
        alertView.showInfo("Thank you", subTitle: "This user has been muted . You will not see this user's gabs on your time line. You can unmute them in your settings" , circleIconImage:checkAletViewImage)
    }
    
    func blockUser(){
        helperClass.blockUserWithuserId(_otherUserUid: friendUdid!, userUid: uid as! String)
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Okay") {
            
        }
        alertView.showInfo("Thank you", subTitle: "This user has been blocked . You can unblock them in your settings" , circleIconImage:checkAletViewImage)
    }

}
