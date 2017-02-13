//
//  UserNameAndPhoneNoViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SinchVerification
import FBSDKCoreKit
import FBSDKLoginKit
import SCLAlertView


class UserNameAndPhoneNoViewController: UIViewController, UITextFieldDelegate {
    
    

    @IBOutlet weak var continueButton: UIButton!
    var verifiction:Verification!
    let applicationKey = "bf8eb31b-9519-4b73-82dc-3a3fa8b79d5e"
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    var overlayView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        let greenColorGreen = Color.green
        userName.layer.borderColor = greenColorGreen.getColor().cgColor
        userName.layer.borderWidth = 1
        phoneNumber.layer.borderColor = greenColorGreen.getColor().cgColor
        phoneNumber.layer.borderWidth = 1
        self.userName.delegate = self
        self.phoneNumber.delegate = self
        
        phoneNumber.addTarget(self, action: #selector(UserNameAndPhoneNoViewController.formatPhoneNumber(sender:)), for: UIControlEvents.editingChanged)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func formatPhoneNumber(sender:UITextField!) {
        
        var phNum = self.phoneNumber.text
        phNum = phNum!.replacingOccurrences(of:"(", with: "")
            .replacingOccurrences(of:")", with: "")
            .replacingOccurrences(of:"-", with: "")
            .replacingOccurrences(of:" ", with: "")
        var characterCount :Int  = (phNum?.characters.count)!
        //let third =  stri.index(stri.startIndex, offsetBy: 2)
        
        switch  characterCount {
        case 4...6 :
            
            let formattedPhnumber = String(format: "(%@) %@",
                                           phNum!.substring(with: phNum!.startIndex ..< phNum!.index(phNum!.startIndex, offsetBy: 3)),
                                           phNum!.substring(with: phNum!.index(phNum!.startIndex, offsetBy: 3) ..< phNum!.index(phNum!.startIndex, offsetBy: characterCount)))
            self.phoneNumber.text = formattedPhnumber
            break
        case 7...10000 :
            
            if (characterCount > 10){
                characterCount = 10
            }
            let formattedPhnumber = String(format: "(%@) %@-%@",
                                           phNum!.substring(with: phNum!.startIndex ..< phNum!.index(phNum!.startIndex, offsetBy: 3)),
                                           phNum!.substring(with: phNum!.index(phNum!.startIndex, offsetBy: 3) ..< phNum!.index(phNum!.startIndex, offsetBy: 6)),
                                           phNum!.substring(with: phNum!.index(phNum!.startIndex, offsetBy: 6) ..< phNum!.index(phNum!.startIndex, offsetBy: characterCount)))
            self.phoneNumber.text = formattedPhnumber
            break
            //        case 11...1000 :
            //
            //
            //            let formattedPhnumber = String(format: "(%@) %@-%@",
            //                                           phNum!.substringWithRange(phNum!.startIndex ... phNum!.startIndex.advancedBy(2)),
            //                                           phNum!.substringWithRange(phNum!.startIndex.advancedBy(3) ... phNum!.startIndex.advancedBy(5)),
            //                                           phNum!.substringWithRange(phNum!.startIndex.advancedBy(6) ... phNum!.startIndex.advancedBy(9)))
            //            self.phoneNumber.text = formattedPhnumber
            //            break
            
        default:
            self.phoneNumber.text = phNum
            
            
        }
        
        
    }
    
    @IBAction func Continue(_ sender: AnyObject) {
        let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
        self.view.endEditing(true)
        var phNum = self.phoneNumber.text
        phNum = phNum!.replacingOccurrences(of:"(", with: "")
            .replacingOccurrences(of:")", with: "")
            .replacingOccurrences(of:"-", with: "")
            .replacingOccurrences(of:" ", with: "")
        
        let characterCount :Int  = (phNum?.characters.count)!
        
        if ((self.userName.text == nil || self.userName.text == "")   || (self.phoneNumber.text == nil || self.phoneNumber.text == "")  ) {
            
                SCLAlertView().showError("Oops !!", subTitle: "Please enter both username and phone number", circleIconImage:errorAletViewImage)
        }
        else if (characterCount < 10) {
            
           SCLAlertView().showError("Oops !!", subTitle: "Phone number should be atleast 10 digits", circleIconImage:errorAletViewImage)
            
        }
        else {
            phNum =   "+1"+phNum!
            var spinner:loadingAnimation = loadingAnimation(overlayView:overlayView, senderView:self.view)
            spinner.showOverlay(alphaValue: 1)
            verifiction = SMSVerification(applicationKey, phoneNumber: phNum!)
            verifiction.initiate({ (InitiationResult, Error) in
                if(InitiationResult.success){
                    let firebaseDBreference = FIRDatabase.database().reference()
                    
                    //                   let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showError("Hello World", subTitle: "This is a more descriptive text.")
                    //                    alertViewResponder.setTitle("New Title") // Rename title
                    //                    alertViewResponder.setSubTitle("New description") // Rename subtitle
                    //                    alertViewResponder.close()
                    let uid =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
                    firebaseDBreference.child("Users").child(uid).child("userName").setValue(self.userName.text)
                    firebaseDBreference.child("Users").child(uid).child("phoneNumber").setValue(self.phoneNumber.text)
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let verifyController = storyBoard.instantiateViewController(withIdentifier: "VerifyPhoneNo") as! VerificationViewController
                    verifyController.verifiction = self.verifiction
                    self.present(verifyController, animated: true, completion: nil)
                    
                }
                else{
                    spinner.hideOverlayView()
                }
            })
            
        }
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.userName.resignFirstResponder()
        self.phoneNumber.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
