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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friendsCell :UITableViewCell =  tableView.dequeueReusableCellWithIdentifier("FriendsCell") as! FriendsTableViewCell
        
        return friendsCell
    }
   

}
