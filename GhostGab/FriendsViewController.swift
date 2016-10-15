//
//  FriendsViewController.swift
//  GhostGossip
//
//  Created by Sruthin Gaddam on 9/9/16.
//  Copyright © 2016 Sruthin Gaddam. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendsCell :UITableViewCell =  tableView.dequeueReusableCell(withIdentifier: "FriendsCell") as! FriendsTableViewCell
        
        return friendsCell
    }
   

}
