//
//  UnMuteViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/12/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SCLAlertView

class UnMuteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var unMuteArray = [String: AnyObject]()
    
    var unMuteArrayKey = [String]()
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
    
    let ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMutedUsers()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var imageName = "Reaction1_lg.png"
        var labelText = "you have no muted friends!!! "
        
        if let unMuteArrayKeyLength : Int = unMuteArrayKey.count{
            if (unMuteArrayKeyLength > 0){
                self.tableView.backgroundView = .none
                self.tableView.separatorStyle = .singleLine
                return unMuteArrayKeyLength
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
        let unmuteCell = tableView.dequeueReusableCell(withIdentifier: "unmute_cell", for: indexPath) as! UnMuteTableViewCell
        unmuteCell.mutedUserUid = self.unMuteArrayKey[indexPath.row]
        unmuteCell.setImageData(photoUrl: self.unMuteArray[self.unMuteArrayKey[indexPath.row]]!.value(forKey :"highResPhoto")! as! String)
        unmuteCell.mutedUserName.text = self.unMuteArray[self.unMuteArrayKey[indexPath.row]]!.value(forKey :"displayName")! as? String
        unmuteCell.unmuteBtn.tag = indexPath.row
        unmuteCell.unmuteBtn.addTarget(self, action: #selector(self.unMuterUser), for: .touchUpInside)
        
        return unmuteCell
    }
    
    
    func unMuterUser(sender: AnyObject){
        let unmuteIndexPath = NSIndexPath(row: sender.tag, section: 0)
        var mutedUserUid = self.unMuteArrayKey[unmuteIndexPath.row]
        
        let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("yes") {
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                self.ref.child("Users").child(self.currentUserId).child("mutedUsers").child(mutedUserUid).removeValue()
                self.ref.child("Users").child(mutedUserUid).child("mutedByUsers").child(self.currentUserId).removeValue()
                self.getMutedUsers()
            }
        }
        alertView.addButton("No") {
            
            
        }
        alertView.showSuccess("Are you sure", subTitle: "Do you want to un mute this user" , circleIconImage:checkAletViewImage)
        
    }
    
    func getMutedUsers() {
        
        ref.child("Users").child(currentUserId).child("mutedUsers").observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            
            if (!snapshot.exists()){
                self.unMuteArray.removeAll()
                self.unMuteArrayKey.removeAll()
                self.tableView.reloadData()
            }
            else {
                self.unMuteArray.removeAll()
                self.unMuteArrayKey.removeAll()
                let unmuteData = snapshot.value as! [String:String]
                for (key,value) in unmuteData {
                    
                    self.ref.child("Users").child(key).observeSingleEvent(of: .value, with: { snapshot in
                        if(snapshot.childrenCount > 0 ){
                            let data:NSDictionary  = snapshot.value as! NSDictionary
                            self.unMuteArrayKey.append(key as! String)
                            self.unMuteArray[key as! String] = data as AnyObject?
                            self.tableView.reloadData()
                        }
                            
                        else {
                            
                            
                        }
                    })
                    
                }
                
            }
            
        })
    }
    
    
    
    @IBAction func back_btn(_ sender: Any) {
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
