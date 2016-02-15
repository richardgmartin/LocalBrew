//
//  ChangeCityViewController.swift
//  LocalBrew
//
//  Created by Richard Martin on 2016-02-14.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

// 1. declare delegate protocol

protocol ChangeCityViewControllerDelegate {
    
    func changeLocation(controller: ChangeCityViewController, didChangeCity: String, didChangeRegion: String, didChangeCountry: String)
    
}


class ChangeCityViewController: UIViewController {

    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var regionTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
// 2. declare delegate property
    
    var delegate: ChangeCityViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func saveLocation(sender: AnyObject) {
        
        let city = self.cityTextField.text
        let region = self.regionTextField.text
        let country = self.countryTextField.text
        
        // 3. implement method/action
        
        if let delegate = self.delegate {
            delegate.changeLocation(self, didChangeCity: city!, didChangeRegion:region!, didChangeCountry: country!)
        }
        
    }
    
    
}
