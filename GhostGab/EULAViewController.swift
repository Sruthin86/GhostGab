//
//  EULAViewController.swift
//  GhostGab
//
//  Created by Sruthin Gaddam on 2/13/17.
//  Copyright © 2017 Sruthin Gaddam. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {

    var logInType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back_btn(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "mainScreen") as! ViewController
        self.present(vc, animated:true, completion:nil)
    }
    

    @IBAction func agree(_ sender: Any) {
        if(logInType == "facebook"){
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FBLoginLoading") as! FBLoadingViewController
            self.present(vc, animated:true, completion:nil)
 
        }
        else if(logInType == "twitter"){
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TwitterLoginLoading") as! twitterLoadingViewController
            self.present(vc, animated:true, completion:nil)

        }
        else{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "email_screen") as! EmailSignupViewController
            self.present(vc, animated:true, completion:nil)
 
        }
        
    }
    
}
