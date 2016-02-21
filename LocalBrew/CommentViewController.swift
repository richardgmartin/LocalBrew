//
//  CommentViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/20/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var brewery:Brewery!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.navigationItem.title = brewery.name
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("CommentCell")!
    }
    
}
