//
//  GabViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/19/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase
import SCLAlertView




class GabViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var postText: UITextView!
    
    @IBOutlet weak var buttonsView: UIStackView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var buttonBottomLayout: NSLayoutConstraint!
    
    let green : Color = Color.green
    
    let red : Color = Color.red
    
    let uid = UserDefaults.standard.object(forKey: fireBaseUid)
    
    let ref = FIRDatabase.database().reference()
    
    let helperClass : HelperFunctions = HelperFunctions()
    
    let locationManager = CLLocationManager()
    
    var loaction : CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.postText.delegate = self
        let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { (timer) in
            self.postText.becomeFirstResponder()
        }
        self.countLabel.text = ""
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: .UIKeyboardWillHide, object: nil)

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled()
        {
            
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.notDetermined
            {
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            
            print("locationServices disenabled")
        }
        locationManager.startUpdatingLocation()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        loaction = locations[0]
    }
    
    func handleKeyboardNotification(notification:NSNotification){
        if let notificationinfo = notification.userInfo{
            let keyboardFrame = (notificationinfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeybaordShowing = notification.name == .UIKeyboardWillShow
            self.buttonBottomLayout.constant = isKeybaordShowing ? (keyboardFrame?.height)! : 0
            print(self.buttonBottomLayout.constant)
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
            
            
        }
        
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if(self.postText.text.characters.count > 200){
             self.countLabel.text = String(self.postText.text.characters.count)
            self.countLabel.textColor = self.red.getColor()
        }
        else {
            self.countLabel.text = String(self.postText.text.characters.count)
            self.countLabel.textColor = self.green.getColor()
        }
        
        
    }


    @IBAction func back_btn(_ sender: Any) {
        self.goToPostViewController()
        
    }
    
    func goToPostViewController(){
        let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
        mainTabBarView.selectedIndex = 0
        //trasition from left
        let transition = CATransition()
        transition.duration = 0.28
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransitionMoveIn)
        self.present(mainTabBarView, animated: false, completion: nil)
    }
    
    @IBAction func gabAsSelfToFriends(_ sender: Any) {
        //4
        
        if(self.postText.text.isEmpty || self.postText.text.characters.count > 200){
           buttonsView.shake()
        }
        else {
            self.post(typeId: 4)
        }
    }
    @IBAction func gabAsSelfToEveryone(_ sender: Any) {
        //1
        if(self.postText.text.isEmpty || self.postText.text.characters.count > 200){
            buttonsView.shake()
        }
        else {
            self.post(typeId: 1)
        }
    }
    
    @IBAction func gabAsGhost(_ sender: Any) {
        //2
        if(self.postText.text.isEmpty || self.postText.text.characters.count > 200){
            buttonsView.shake()
        }
        else {
            self.post(typeId: 2)
        }
    }
    @IBAction func gabAndGuess(_ sender: Any) {
        
        //3
        if(self.postText.text.isEmpty || self.postText.text.characters.count > 200){
            buttonsView.shake()
        }
        else {
            self.post(typeId: 3)
        }
    }
    
    
    func post(typeId: Int){
        
        self.saveNewPost(post: (self.postText?.text)!, uid:self.uid as! String, postType: typeId)
        
    }
    
    
    func saveNewPost(post:String, uid: String, postType: Int) {
        
        let currentDateToString: String = helperClass.returnCurrentDateinString()
        ref.child("Users").child(uid).observeSingleEvent(of: FIRDataEventType.value, with :{ (snapshot) in
            let userData =  snapshot.value as! [String:AnyObject]
            let displayName = userData["displayName"]
            let picUrl = userData["highResPhoto"]
            let reactionsData: [String:Int] = ["Reaction1": 0, "Reaction2": 0, "Reaction3": 0, "Reaction4": 0, "Reaction5": 0, "Reaction6": 0]
            let flags: [String : Int] = ["flagCount": 0]
            let postMetrics: [String:Int] = ["flag":0, "correctGuess":0, "wrongGuess":0]
            if let currentLocation = self.loaction {
                let locationData =  ["la": currentLocation.coordinate.latitude ,  "lx": currentLocation.coordinate.longitude]
                let postData : [String: AnyObject] = ["post":post as AnyObject , "useruid": uid as AnyObject, "displayName":displayName!, "userPicUrl" : picUrl!, "postType":postType as AnyObject,  "reactionsData":reactionsData as AnyObject, "flags":flags as AnyObject, "postMetrics":postMetrics as AnyObject,"date":currentDateToString as AnyObject, "locationData": locationData as AnyObject]
                let postDataRef = self.ref.child("Posts").childByAutoId()
                postDataRef.setValue(postData)
                let postDataId = postDataRef.key
                self.ref.child("Users").child(uid).child("posts").child(postDataId).child("posId").setValue(postDataId)
            }
            else {
            let postData : [String: AnyObject] = ["post":post as AnyObject , "useruid": uid as AnyObject, "displayName":displayName!, "userPicUrl" : picUrl!, "postType":postType as AnyObject,  "reactionsData":reactionsData as AnyObject, "flags":flags as AnyObject, "postMetrics":postMetrics as AnyObject,"date":currentDateToString as AnyObject]
                let postDataRef = self.ref.child("Posts").childByAutoId()
                postDataRef.setValue(postData)
                let postDataId = postDataRef.key
                self.ref.child("Users").child(uid).child("posts").child(postDataId).child("posId").setValue(postDataId)
            }
            
            
            self.goToPostViewController()
            // ...
        })
        
        
        
        
        
    }


}
