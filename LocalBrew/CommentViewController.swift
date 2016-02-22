//
//  CommentViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/20/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var brewery:Brewery!
    var commmentsArray:NSArray = []
    let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
    @IBOutlet weak var commentsTableView: UITableView!

    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadComments()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    
    func loadComments()
    {
        FirebaseConnection.firebaseConnection.COMMENT_REF.childByAppendingPath(brewery.firebaseID).observeEventType(.Value, withBlock: { snapshot in
            
            if(snapshot.value is NSNull)
            {
                self.commmentsArray = []
            }
            else
            {
                self.commmentsArray = snapshot.value.allObjects
            }
            
            self.commentsTableView.reloadData()
            //print(self.commmentsArray)
            
            
        
        })
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commmentsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell")
        let comment = self.commmentsArray[indexPath.row] as? NSDictionary
        cell?.textLabel?.text = comment?.valueForKey("text") as? String
        cell?.detailTextLabel?.text = comment?.valueForKey("username") as? String
       
        
        return cell!
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        FirebaseConnection.firebaseConnection.COMMENT_REF.childByAppendingPath(brewery.firebaseID).childByAutoId().setValue(["text":textField.text!, "username":username!])
        
        textField.text = ""
        
        self.loadComments()
        
        return textField.resignFirstResponder()
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
}
