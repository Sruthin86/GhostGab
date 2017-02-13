//
//  LoginWithEmailViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/6/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SCLAlertView


class LoginWithEmailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    let green: Color = Color.green
    
    let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.email.delegate = self
        self.password.delegate = self
        let costomization:UICostomization =  UICostomization(color: green.getColor(), width:1)
        costomization.addBorder(object: self.password)
        costomization.addBorder(object: self.email)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func login_btn(_ sender: Any) {
        
        verifyEmailAndPass()
    }
    
    func verifyEmailAndPass(){
        
        if((self.email.text?.isEmpty)! || (self.password.text?.isEmpty)!){
            
            SCLAlertView().showError("Oops !!", subTitle: "Please enter all the fields ", circleIconImage:self.errorAletViewImage)
        }
        else{
            loginWithCredentials()
        }
        
        
    }
    
    func loginWithCredentials(){
        FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
            if(error != nil){
                if let errCode = FIRAuthErrorCode(rawValue: error!._code){
                    print("errorcoder")
                    print(errCode)
                    let rawVal = errCode.rawValue
                    
                    print(error.debugDescription)
                    
                    switch rawVal {
                    case 17009:
                        SCLAlertView().showError("Sorry !!", subTitle: "The password you entered do not match our records , please try again", circleIconImage:self.errorAletViewImage)
                    case 17011:
                        SCLAlertView().showError("Sorry !!", subTitle: "The credentails do not match our records , please try again!", circleIconImage:self.errorAletViewImage)
                    default:
                        SCLAlertView().showError("Sorry !!", subTitle: "The credentails do not match our records , please try again!", circleIconImage:self.errorAletViewImage)
                    }
                }
            }
            else if(user != nil){
                let ref = FIRDatabase.database().reference()
                let uid = user?.uid
                UserDefaults.standard.set(uid, forKey: fireBaseUid)
                
                
                ref.child("Users").child(uid!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                    if(snapshot.exists()){
                        let userData = snapshot.value as! [String: AnyObject]
                        UserDefaults.standard.set(userData["isUsing"], forKey: "isUsing")
                        UserDefaults.standard.set(userData["displayName"], forKey: displayName)
                        if((userData["isVerified"]) != nil){
                            var verified: Bool = userData["isVerified"] as! Bool
                            if(userData["reportedCount"] != nil){
                                var rportedCount = userData["reportedCount"] as! Int
                                if(rportedCount >= 5){
                                    let storybaord: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let lockedView  = storybaord.instantiateViewController(withIdentifier: "locked_view") as! LockedViewController
                                    self.present(lockedView, animated: true, completion: nil)
                                }
                            }
                            if(verified){
                                let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                                let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                                mainTabBarView.selectedIndex = 0
                                self.present(mainTabBarView, animated: true, completion: nil)
                            }
                            else {
                                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "userNameandPh") as! UserNameAndPhoneNoViewController
                                self.present(vc, animated:true, completion:nil)
                                
                            }
                        }
                        
                        
                    }
                        
                    else {
                        //User does not exist.
                        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "mainScreen") as! ViewController
                        self.present(vc, animated:true, completion:nil)
                    }
                })
            }
            
        }
    }
    
}
