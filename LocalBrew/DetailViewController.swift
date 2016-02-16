//
//  DetailViewController.swift
//  LocalBrew
//
//  Created by Michael Sandoval on 2/15/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBeerButton: UIBarButtonItem!
    @IBOutlet weak var breweryIconImageView: UIImageView!
    
    var favoriteBeerObjects = [FavoriteBeer]()
    var breweryDetail: Brewery!
    
    

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.breweryIconImageView.image = self.breweryDetail.breweryImageIcon
        self.title = self.breweryDetail.name
        







        
    }

  
    
    @IBAction func addBeerOnButtonTapped(sender: AnyObject) {
        
        addFavoriteBeer()
        
    }
    
    
    func addFavoriteBeer() {
        let addBeer = UIAlertController(title: "Add your favorite Beer!", message: nil, preferredStyle: .Alert)
        addBeer.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, addBeer](action: UIAlertAction!) in
            let answer = addBeer.textFields![0].text
            let favoriteBeer = FavoriteBeer(name: answer!, favorite: 0)
            self.favoriteBeerObjects.append(favoriteBeer)
             self.tableView.reloadData()
        }
        addBeer.addAction(submitAction)
        
        presentViewController(addBeer, animated: true, completion: nil)
        
       
        
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return favoriteBeerObjects.count
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let favoriteBeer = favoriteBeerObjects[indexPath.row]

        
        if let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteBeerCellID") as? FavoriteBeerCell{
            cell.configureCell(favoriteBeer)
            return cell
            
        } else {
            return FavoriteBeerCell()
        }
    
    }

}
