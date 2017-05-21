//
//  FriendsOfFriendViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/14/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import OneSignal

class FriendsOfFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var tableView: UITableView!
    
    var friendsArray = [String: AnyObject]()
    
    var friendsArrayKey = [String]()
    
    var friendUdid: String?
    
    var currentUserDisplayName: String?
    
    var spinner:loadingAnimation?
    
    var overlayView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        
        self.spinner?.showOverlayNew(alphaValue: 1)
        self.getFriends()
        
        self.navigationItem.title = ""
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var imageName = "Reaction1_lg.png"
        var labelText = "you will find your friends soon!!! "
        
        
        if let friendsLength : Int = self.friendsArrayKey.count{
            if (friendsLength > 0){
                self.tableView.backgroundView = .none
                self.tableView.separatorStyle = .singleLine
                return friendsLength
            }
            else {
                imageName = "Reaction3_lg.png"
                labelText = "No Results Found!!! "
                displyNoDataLabel(imageName:imageName, labelText:labelText)
                return 0
                
            }
        }
            
        else {
            
            displyNoDataLabel(imageName:imageName, labelText:labelText)
            return 0
            
        }
        
        
        
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendsCell :FriendsOfFriendTableViewCell =  tableView.dequeueReusableCell(withIdentifier: "friends_of_friend") as! FriendsOfFriendTableViewCell
        
        friendsCell.setImageData(photoUrl: self.friendsArray[self.friendsArrayKey[indexPath.row]]!.value(forKey :"highResPhoto")! as! String)
        friendsCell.displayName.text = self.friendsArray[self.friendsArrayKey[indexPath.row]]!.value(forKey :"displayName")! as? String
        friendsCell.addButton.isHidden = true
        if(!(self.friendsArray[self.friendsArrayKey[indexPath.row]]!.value(forKey :"isExists") as! Bool)){
            friendsCell.addButton.isHidden = false
            friendsCell.addButton.tag = indexPath.row
            friendsCell.addButton.addTarget(self, action: #selector(self.addFriendButton), for: .touchUpInside)
        }
        
        friendsCell.setBackground(colorValue: "white")
        return friendsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let friendUdidToPass =  self.friendsArrayKey[index]
        var overlayView = UIView()
        
        
        if(friendUdidToPass == self.currentUserId){
            let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
            let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
            mainTabBarView.selectedIndex = 2
            //trasition from left
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
            self.present(mainTabBarView, animated: false, completion: nil)
            
        }
            
        else {
            let storybaord: UIStoryboard = UIStoryboard(name: "Friends", bundle: nil)
            let friendDetailsView  = storybaord.instantiateViewController(withIdentifier: "friend_details") as! FriendDetailsViewController
            friendDetailsView.friendUdid = friendUdidToPass
            //trasition from right
             self.navigationController?.pushViewController(friendDetailsView, animated:true)
        }
        
    }
    func addFriendButton(sender: AnyObject){
        let OnesignalIndexPath = NSIndexPath(row: sender.tag, section: 0)
        let highLightedCell : FriendsOfFriendTableViewCell = self.tableView.cellForRow(at: OnesignalIndexPath as IndexPath) as! FriendsOfFriendTableViewCell
        highLightedCell.setBackground(colorValue: "lightGreen")
        highLightedCell.addButton.isEnabled = false
        let reqOneSignalId = self.friendsArray[self.friendsArrayKey[OnesignalIndexPath.row]]!.value(forKey :"oneSignalId")
        let requestedUserUid = self.friendsArrayKey[OnesignalIndexPath.row]
        let requestedDisplayName = self.friendsArray[self.friendsArrayKey[OnesignalIndexPath.row]]!.value(forKey :"displayName")
        ref.child("Users").child(currentUserId).child("RequestsSent").child(requestedUserUid).setValue(requestedDisplayName)
        ref.child("Users").child(requestedUserUid).child("Requests").child(currentUserId).setValue(self.currentUserDisplayName)
        let notificationText: String = self.currentUserDisplayName! + " sent you a friend request"
        OneSignal.postNotification(["contents": ["en": notificationText], "include_player_ids": [reqOneSignalId]])
        let timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
            highLightedCell.setBackground(colorValue: "white")
        }
        
    }
    
    
    
    
    
    func getFriends() -> Void {
        
        ref.child("Users").child(self.friendUdid!).child("Friends").observe(FIRDataEventType.value, with: {(snapshot) in
            
            if (!snapshot.exists()){
                self.spinner?.hideOverlayViewNew()
                self.friendsArray.removeAll()
                self.friendsArrayKey.removeAll()
                self.tableView.reloadData()
            }
            else {
                self.friendsArray.removeAll()
                self.friendsArrayKey.removeAll()
                let friendData = snapshot.value as! [String:String] as [String : AnyObject]
                for (key,value) in friendData {
                    
                    self.ref.child("Users").child(key).observeSingleEvent(of: .value, with: { snapshot in
                        if(snapshot.childrenCount > 0 ){
                            let data:NSDictionary  = snapshot.value as! NSDictionary
                            self.ref.child("Users").child(self.currentUserId).observeSingleEvent(of: .value, with: { snap in
                                if(snap.exists()){
                                    let userData:NSDictionary  = snap.value as! NSDictionary
                                    self.currentUserDisplayName = userData["displayName"] as! String
                                    var isExists: Bool = false
                                    if (userData ["blockedByUsers"] != nil){
                                        var blockedData = userData["blockedByUsers"] as! NSDictionary
                                        if(blockedData[key] != nil){
                                            isExists = true
                                        }
                                    }
                                    
                                    if(userData["RequestsSent"] != nil){
                                        var reqSentData = userData["RequestsSent"] as! NSDictionary
                                        if(reqSentData[key] != nil){
                                            isExists = true
                                        }
                                        
                                    }
                                    if(userData["Requests"] != nil){
                                        var reqData = userData["Requests"] as! NSDictionary
                                        if(reqData[key] != nil){
                                            isExists = true
                                        }
                                    }
                                    
                                    if(userData["Friends"] != nil){
                                        var frnd = userData["Friends"] as! NSDictionary
                                        if(frnd[key] != nil){
                                            isExists = true
                                        }
                                        
                                    }
                                    if(key == self.currentUserId){
                                        isExists = true
                                    }
                                    data.setValue(isExists, forKey: "isExists")
                                    self.friendsArrayKey.append(key as! String)
                                    self.friendsArray[key as! String] = data as AnyObject?
                                    //                                    self.friendsArray[key]?.set(isExists, forKey: "isExists")
                                    
                                    self.tableView.reloadData()
                                    self.spinner?.hideOverlayViewNew()
                                }
                            })
                        }
                            
                        else {
                            
                            self.spinner?.hideOverlayViewNew()
                        }
                    })
                    
                    
                }
                
            }
            
        })
    }
    
}
