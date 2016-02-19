//
//  LoginViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/14/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import Firebase


class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    var rootRef:Firebase!
    let userDefaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.rootRef = Firebase(url: "https://localbrew.firebaseio.com")
        //let userRef = rootRef.childByAppendingPath("users")
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginErrorAlert(tittle: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func onLoginButtonTapped(sender: UIButton)
    {
        
        if loginEmailTextField.text?.characters.count > 0 && loginPasswordTextField.text?.characters.count > 0
        {
            FirebaseConnection.firebaseConnection.BASE_REF.authUser(loginEmailTextField.text, password: loginPasswordTextField.text)
                { (error, auth) -> Void in
                    if error != nil
                    {
                        print(error.description)
                        self.loginErrorAlert("Error", message: "Check your username and password combination")
                    }
                    else
                    {
                        self.userDefaults.setValue(auth.uid, forKey: "uid")
                        FirebaseConnection.firebaseConnection.CURRENT_USER_REF.observeEventType(FEventType.Value, withBlock: { snapshot in
                            let currentUsername = snapshot.value.objectForKey("username") as? String
                            print(currentUsername)
                            let currentName = snapshot.value.objectForKey("name") as? String
                            print(currentName)
                            let currentUser = ["provider":auth.provider, "username":currentUsername, "name":currentName]
                            self.rootRef.childByAppendingPath("users").childByAppendingPath(auth.uid).setValue(currentUser)
                            self.userDefaults.setValue(auth.uid, forKey: "uid")
                            self.performSegueWithIdentifier("fromLogin", sender: nil)
                            }, withCancelBlock: { error in
                                print(error.description)
                        })
                        
                    }
            }
        }
        else
        {
            loginErrorAlert("Error", message: "Please enter a username and password.")
        }
    }
    
    
    
    @IBAction func prepareForUnWind(segue : UIStoryboardSegue)
    {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - UITextField Delegates
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
