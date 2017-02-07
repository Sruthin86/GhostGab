//
//  EmailSignupViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/6/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit

class EmailSignupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "signup_screen") as! SignUpWithEmailViewController
        self.present(vc, animated:true, completion:nil)
        
    }

    
    @IBAction func already_a_member(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login_screen") as! LoginWithEmailViewController
        self.present(vc, animated:true, completion:nil)
    
    }
    
}
