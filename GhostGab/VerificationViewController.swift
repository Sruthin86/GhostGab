//
//  VerificationViewController.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 8/3/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit
import SinchVerification
import SCLAlertView

class VerificationViewController: UIViewController {

    @IBOutlet weak var VerifyCodeTextField: UITextField!
    var verifiction:Verification!
    let applicationKey = "bf8eb31b-9519-4b73-82dc-3a3fa8b79d5e"
    override func viewDidLoad() {
        super.viewDidLoad()
        let greenColorEnum = Color.green
        VerifyCodeTextField.layer.borderColor = greenColorEnum.getColor().CGColor
        VerifyCodeTextField.layer.borderWidth = 1;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func VerifyButton(sender: AnyObject) {
        let errorAletViewImage : UIImage = UIImage(named : "Logo.png")!
        verifiction.verify(self.VerifyCodeTextField.text!) { (success:Bool, error:NSError?)  ->Void in
            if(success){
                let storybaord: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                let mainTabBarView  = storybaord.instantiateViewControllerWithIdentifier("MainTabView") as! MainTabBarViewController
                self.presentViewController(mainTabBarView, animated: true, completion: nil)
            }
            else {
                
               SCLAlertView().showError("Oops !!", subTitle: "Please enter the correct verification code!!", circleIconImage:errorAletViewImage)
            }
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

}
