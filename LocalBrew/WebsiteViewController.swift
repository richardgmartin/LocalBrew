//
//  WebsiteViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/18/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class WebsiteViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    var breweryDetail: Brewery!


    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.breweryDetail.website)
        let url = NSURL (string: "\(self.breweryDetail.website!)")
        let requestObj = NSURLRequest(URL: url!)
        self.webView.loadRequest(requestObj)
    }

}

