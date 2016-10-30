//
//  ChangeCityViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/15/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import Foundation
import UIKit
import MapKit
// 1. declare delegate protocol
protocol ChangeCityViewControllerDelegate {
    
    
    
    func changeLocation(controller: ChangeCityViewController, didChangeCity: String, didChangeRegion: String, didChangeCountry: String)
    
}
class ChangeCityViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var regionTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var changeCityMapView: MKMapView!


    
    var breweryLatitude: Double = 0.0
    var breweryLongitude: Double = 0.0
    
    // 2. declare delegate property
    
    var delegate: ChangeCityViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //button cosmetics
        self.updateButton.tintColor = UIColor.fromHexString("#000000", alpha: 1.0)
        self.updateButton.backgroundColor = UIColor.fromHexString("#FAD201", alpha: 1.0)
        self.updateButton.layer.cornerRadius = 5
        self.updateButton.layer.borderWidth = 1
        self.updateButton.layer.borderColor = UIColor.fromHexString("#000000", alpha: 1.0) .CGColor
        self.cancelButton.tintColor = UIColor.fromHexString("#000000", alpha: 1.0)
        self.cancelButton.backgroundColor = UIColor.fromHexString("#FAD201", alpha: 1.0)
        self.cancelButton.layer.cornerRadius = 5
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = UIColor.fromHexString("#000000", alpha: 1.0) .CGColor
        
        self.cityTextField.layer.cornerRadius = 5
        self.cityTextField.layer.borderWidth = 1
        self.cityTextField.layer.borderColor = UIColor.blackColor().CGColor
        self.cityTextField.textColor = UIColor.blackColor()
        self.regionTextField.layer.cornerRadius = 5
        self.regionTextField.layer.borderWidth = 1
        self.regionTextField.layer.borderColor = UIColor.blackColor().CGColor
        self.regionTextField.textColor = UIColor.blackColor()
        self.countryTextField.layer.cornerRadius = 5
        self.countryTextField.layer.borderWidth = 1
        self.countryTextField.layer.borderColor = UIColor.blackColor().CGColor
        self.countryTextField.textColor = UIColor.blackColor()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.fromHexString("#960200", alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.fromHexString("#FAFAFF", alpha: 1.0)

    
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBarHidden = true
        let breweryLatitude:CLLocationDegrees = self.breweryLatitude
        let breweryLongitude:CLLocationDegrees = self.breweryLongitude
        let breweryLatDelta:CLLocationDegrees = 0.08
        let breweryLongDelta:CLLocationDegrees = 0.08
        let span:MKCoordinateSpan = MKCoordinateSpanMake(breweryLatDelta, breweryLongDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(breweryLatitude, breweryLongitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.changeCityMapView.setRegion(region, animated: true)

        

        
    }
    
    @IBAction func saveLocation(sender: AnyObject) {
        

        
        let city = self.cityTextField.text
        let region = self.regionTextField.text
        let country = self.countryTextField.text
        
        // 3. implement method/action

            delegate?.changeLocation(self, didChangeCity: city!, didChangeRegion:region!, didChangeCountry: country!)
        performSegueWithIdentifier("update", sender: UIButton())
        
    }
    
    @IBAction func onCancelButtonTapped(sender: AnyObject) {
        
        performSegueWithIdentifier("cancel", sender: UIButton())

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.resignFirstResponder()
    }
    
    
    
}
