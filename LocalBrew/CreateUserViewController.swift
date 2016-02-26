//
//  CreateUserViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/14/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import Firebase

class CreateUserViewController: UIViewController, UITextFieldDelegate
{
    var rootRef:Firebase!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var localBrewLabel: UILabel!
    @IBOutlet weak var createEmailTextField: UITextField!
    @IBOutlet weak var createPasswordTextField: UITextField!
    @IBOutlet weak var createUsernameTextField: UITextField!
    @IBOutlet weak var createNameTextField: UITextField!

    @IBOutlet weak var createUserProfileButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.rootRef = Firebase(url: "https://localbrew.firebaseio.com")
        
        self.createEmailTextField.layer.cornerRadius = 5
        self.createEmailTextField.layer.borderWidth = 1
        self.createEmailTextField.layer.borderColor = UIColor.blackColor().CGColor
        self.createEmailTextField.textColor = UIColor.blackColor()
        self.createPasswordTextField.layer.cornerRadius = 5
        self.createPasswordTextField.layer.borderWidth = 1
        self.createPasswordTextField.layer.borderColor = UIColor.blackColor().CGColor
        self.createPasswordTextField.textColor = UIColor.blackColor()
        self.createUsernameTextField.layer.cornerRadius = 5
        self.createUsernameTextField.layer.borderWidth = 1
        self.createUsernameTextField.layer.borderColor = UIColor.blackColor().CGColor
        self.createUsernameTextField.textColor = UIColor.blackColor()
        self.createNameTextField.layer.cornerRadius = 5
        self.createNameTextField.layer.borderWidth = 1
        self.createNameTextField.layer.borderColor = UIColor.blackColor().CGColor
        self.createNameTextField.textColor = UIColor.blackColor()
        
        self.createUserProfileButton.backgroundColor = UIColor.fromHexString("#FAD201", alpha: 1.0)
        self.createUserProfileButton.layer.cornerRadius = 5
        self.createUserProfileButton.layer.borderWidth = 1
        self.createUserProfileButton.layer.borderColor = UIColor.fromHexString("#000000", alpha: 1.0) .CGColor
        self.createUserProfileButton.tintColor = UIColor.fromHexString("#000000", alpha: 1.0)
        self.backButton.tintColor = UIColor.fromHexString("#000000", alpha: 1.0)
        self.backButton.backgroundColor = UIColor.fromHexString("#FAD201", alpha: 1.0)
        self.backButton.layer.cornerRadius = 5
        self.backButton.layer.borderWidth = 1
        self.backButton.layer.borderColor = UIColor.fromHexString("#000000", alpha: 1.0) .CGColor
        
        self.localBrewLabel.font = UIFont.boldSystemFontOfSize(20.0)

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
                self.rootRef.authUser(self.createEmailTextField!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), password: self.createPasswordTextField!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), withCompletionBlock: { error, authData  in
                    let user = ["provider":authData.provider!, "email":self.createEmailTextField.text!, "username":self.createUsernameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), "uid":authData.uid!, "name":self.createNameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())]
                    FirebaseConnection.firebaseConnection.createNewAccount(authData.uid, user: user)
                    self.userDefaults.setValue(authData.uid, forKey: "uid")

                    
                    self.performSegueWithIdentifier("fromCreateUser", sender: nil)
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
                    self.createUsernameTextField.text = ""
                    
                    
                })
            }
            
            
           
        }
        
        
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK: UITextField Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    func textFieldDidEndEditing(textField: UITextField)
    {
        textField.resignFirstResponder()
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
