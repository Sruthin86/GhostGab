//
//  VerificationViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 11/19/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import SinchVerification
import Firebase
import FirebaseDatabase
import SCLAlertView

class VerificationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var VerifyCodeTextField: UITextField!
    var verifiction:Verification!
    let applicationKey = "bba57591-11c0-49a5-b3e0-52c2fc9af5ee"
    
    let currentUserId =  UserDefaults.standard.object(forKey: fireBaseUid) as! String
     let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let greenColorEnum = Color.green
        VerifyCodeTextField.layer.borderColor = greenColorEnum.getColor().cgColor
        VerifyCodeTextField.layer.borderWidth = 1;
        self.VerifyCodeTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func VerifyButton(_ sender: AnyObject) {
        let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
        verifiction.verify(self.VerifyCodeTextField.text!) {  (success:Bool, error:Error?) -> (Void)   in
            if(success){
                self.ref.child("Users").child(self.currentUserId).child("isVerified").setValue(true)
                let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                let mainTabBarView  = storybaord.instantiateViewController(withIdentifier: "MainTabView") as! MainTabBarViewController
                self.present(mainTabBarView, animated: true, completion: nil)
            }
            else {
                
                               SCLAlertView().showError("Oops !!", subTitle: "Please enter the correct verification code!!", circleIconImage:errorAletViewImage)
            }
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.VerifyCodeTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
