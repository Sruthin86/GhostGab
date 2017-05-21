//
//  NotificationViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/20/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

extension Notification.Name {
    static let reloadNotifications = Notification.Name("reloadNotifications")
}

class NotificationViewController: UIViewController , UITableViewDelegate, UITableViewDataSource  {
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var tableView: UITableView!
    
    var notificationArray = [String : AnyObject]()
    
    var notificationKeys = [String]()
    
    var spinner:loadingAnimation?
    
    var overlayView = UIView()
    
    var helperClass : HelperFunctions = HelperFunctions()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.spinner  = loadingAnimation(overlayView: overlayView, senderView: self.view)
        
        self.spinner?.showOverlayNew(alphaValue: 1)
         NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableData(_:)), name: .reloadNotifications, object: nil)
        
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let logo = UIImage(named: "Logo.png")
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 37, height: 39))
        imageView.contentMode = .scaleAspectFit
        imageView = UIImageView(image:logo)
        self.navigationController?.navigationBar.topItem?.titleView = imageView
        
        self.getNotifications()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.notificationKeys.count == 0){
            let imageName: String = "wings.png"
            let labelText: String = "You do not have any notifications yet!!! "
            let image : UIImage = UIImage(named: imageName)!
            let imageView :UIImageView = UIImageView(image: image)
            imageView.frame = CGRect(x:self.tableView.frame.width/2 - 37.5, y:self.tableView.frame.height/3, width:94, height:56)
            let textColor: Color = Color.grey
            let noDataAvailableLabel: UILabel = UILabel(frame: CGRect(x:0, y:self.tableView.frame.height/8, width:self.tableView.frame.width, height:self.tableView.frame.height) )
            
            noDataAvailableLabel.text =  labelText
            noDataAvailableLabel.textAlignment = .center
            noDataAvailableLabel.textColor =  textColor.getColor()
            noDataAvailableLabel.font = UIFont(name: "Avenir-Next", size:14.0)
            noDataAvailableLabel.numberOfLines = 2
            self.tableView.separatorStyle = .none
            var noFriendsView : UIView = UIView( frame: CGRect(x:0, y:300, width:self.tableView.frame.width, height:self.tableView.frame.height))
            noFriendsView.addSubview(imageView)
            noFriendsView.addSubview(noDataAvailableLabel)
            self.tableView.backgroundView = noFriendsView
        }
        else {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = .none
        }
        
        
        
        return self.notificationKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationFeedCell = tableView.dequeueReusableCell(withIdentifier: "notification_cell", for: indexPath) as! NotificationTableViewCell
        
        notificationFeedCell.notificationId = self.notificationKeys[indexPath.row] as! String
        var notificationFeed :[String: AnyObject] = self.notificationArray[self.notificationKeys[indexPath.row]]! as! [String : AnyObject]
        notificationFeedCell.notificationText.text = notificationFeed["notificationText"] as! String
        if(notificationFeed["isOpened"] as! Bool || notificationFeed["notificationType"] as! Int == 0 ){
            notificationFeedCell.notificationStatusImage.isHidden = true
        }
        else {
           notificationFeedCell.notificationStatusImage.isHidden = false
        }
        notificationFeedCell.notificationDateLabel.text = helperClass.getDifferenceInDates(postDate: notificationFeed["notificationDate"] as! String)
        notificationFeedCell.deleteNotification.tag =  indexPath.row
        notificationFeedCell.deleteNotification.addTarget(self, action: #selector(self.deleteNotifications), for: .touchUpInside)
        notificationFeedCell.setBackground(colorValue: "white")
        return notificationFeedCell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let notificationFeed :[String: AnyObject] = self.notificationArray[self.notificationKeys[indexPath.row]]! as! [String : AnyObject]
        let notificationId : String = self.notificationKeys[indexPath.row] as! String
        if( notificationFeed["notificationType"] as! Int == 1 ){
            let postId = notificationFeed["postId"] as! String
            self.ref.child("Posts").child(postId).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if(snapshot.exists()){
                    self.ref.child("Users").child(self.uid as! String).child("Notifications").child(notificationId).child("isOpened").setValue(true)
                    let postFeed = snapshot.value as! [String:AnyObject]
                    let storybaord: UIStoryboard = UIStoryboard(name: "Posts", bundle: nil)
                    let commentsView  = storybaord.instantiateViewController(withIdentifier: "comments_view") as! CommentsViewController
                    commentsView.postId = postId
                    commentsView.thisPostArray = postFeed
                    //trasition from right
                    self.navigationController?.pushViewController(commentsView, animated: true)
                    
                    
                }
                
                else {
                     self.ref.child("Users").child(self.uid as! String).child("Notifications").child(notificationId).child("isOpened").setValue(true)
                    let checkAletViewImage : UIImage = UIImage(named : "Logo.png")!
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("Okay") {
                        
                    }
                    alertView.showInfo("Sorry !!", subTitle: "This post has been deleted" , circleIconImage:checkAletViewImage)
                }
            })
            
           
        }
        else if ( notificationFeed["notificationType"] as! Int == 2 ){
            self.ref.child("Users").child(self.uid as! String).child("Notifications").child(notificationId).child("isOpened").setValue(true)
            let storyboard:UIStoryboard = UIStoryboard(name:"Search", bundle: nil)
            let request_view = storyboard.instantiateViewController(withIdentifier: "RequestAndSuggest")as! RequestsSuggestionsViewController
            self.navigationController?.pushViewController(request_view, animated: true)
            
        }
        else {
            self.ref.child("Users").child(self.uid as! String).child("Notifications").child(notificationId).child("isOpened").setValue(true)
        }
    }
    
    func reloadTableData(_ notification: Notification) {
        self.getNotifications()
    }
    
    
    func deleteNotifications(sender: AnyObject) {
        let notificationIndexPath = NSIndexPath(row: sender.tag, section: 0)
        var notificationId: String = self.notificationKeys[notificationIndexPath.row]
        
        let highLightedCell : NotificationTableViewCell = self.tableView.cellForRow(at: notificationIndexPath as IndexPath) as! NotificationTableViewCell
        highLightedCell.setBackground(colorValue: "lightRed")
        let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
            self.helperClass.deleteNotification(notificationId:notificationId, useruid:self.uid as! String)
        }
        
    }
    func getNotifications(){
        
        self.ref.child("Users").child(self.uid as! String).child("Notifications").observe(FIRDataEventType.value, with:{ (snapshot) in
            if(snapshot.exists()){
                self.notificationKeys.removeAll()
                self.notificationArray.removeAll()
                let notificationData =  snapshot.value as! NSDictionary
                for (key,val) in notificationData{
                    self.notificationKeys.append(key as! String)
                    self.notificationArray[key as! String] = val as! AnyObject
                    
                }
                self.notificationKeys = self.notificationKeys.sorted{ $0 > $1 }
                self.spinner?.hideOverlayViewNew()
                self.tableView.reloadData()
            }
            else{
                self.notificationKeys.removeAll()
                self.notificationArray.removeAll()
                self.tableView.reloadData()
                self.spinner?.hideOverlayViewNew()
            }
        })
    }
    
    
    
    
    
   
}
