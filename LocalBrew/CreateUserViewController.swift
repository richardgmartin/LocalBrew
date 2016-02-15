//
//  CreateUserViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/14/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import Firebase

class CreateUserViewController: UIViewController
{
     var rootRef:Firebase!
    @IBOutlet weak var createEmailTextField: UITextField!
    @IBOutlet weak var createPasswordTextField: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.rootRef = Firebase(url: "https://localbrew.firebaseio.com")
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreateUserProfileButtonTapped(sender: AnyObject)
    {
        rootRef.createUser(createEmailTextField.text, password: createPasswordTextField.text) { (error:NSError!) -> Void in
            
            if error == nil
            {
                self.rootRef.authUser(self.createEmailTextField.text, password: self.createPasswordTextField.text, withCompletionBlock: { (error, auth) -> Void in
                    
                })
                
            }
            else
            {
                let errorAlert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                errorAlert.addAction(okAction)
                self.presentViewController(errorAlert, animated: true, completion: { () -> Void in
                    self.createEmailTextField.text = ""
                    self.createPasswordTextField.text = ""
                    
                    
                })
            }
            
            self.performSegueWithIdentifier("fromCreateUser", sender: nil)
        }
        
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}