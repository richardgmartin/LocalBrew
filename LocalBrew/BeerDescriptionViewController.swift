//
//  BeerDescriptionViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/25/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class BeerDescriptionViewController: UIViewController {

    @IBOutlet weak var beerImageView: UIImageView!
    @IBOutlet weak var beerDescriptionLabel: UILabel!
    @IBOutlet weak var beerDescriptionTextView: UITextView!
    @IBOutlet weak var beerOrganic: UILabel!
    @IBOutlet weak var beerStyle: UILabel!
    @IBOutlet weak var breweryName: UILabel!
    @IBOutlet weak var breweryNameBold: UILabel!
    @IBOutlet weak var beerOrganicBold: UILabel!
    @IBOutlet weak var beerStyleBold: UILabel!
    
    var beerDetail = Beer!()
    var breweryDetailName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        
        self.navigationItem.title = beerDetail.beerName
        self.beerOrganic.text = beerDetail.isOrganic
        self.beerImageView.image = beerDetail.beerImageIcon
        self.beerDescriptionTextView.text = beerDetail.beerDescription
        self.beerStyle.text = beerDetail.style
        self.breweryName.text = beerDetail.beerName
        self.beerDescriptionLabel.font = UIFont.boldSystemFontOfSize(17.0)
        self.beerOrganicBold.font = UIFont.boldSystemFontOfSize(17.0)
        self.beerStyleBold.font = UIFont.boldSystemFontOfSize(17.0)
        self.breweryNameBold.font = UIFont.boldSystemFontOfSize(17.0)
        self.beerDescriptionTextView.backgroundColor = UIColor.clearColor()
        
        
        
        
        
    }
    
    
    

}
