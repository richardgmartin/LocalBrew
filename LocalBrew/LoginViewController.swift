//
//  LoginViewController.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/14/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import Firebase


class LoginViewController: UIViewController
{
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    var rootRef:Firebase!

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
    
    @IBAction func onLoginButtonTapped(sender: UIButton)
    {
        rootRef.authUser(loginEmailTextField.text, password: loginPasswordTextField.text) { (error, auth) -> Void in
            self.performSegueWithIdentifier("fromLogin", sender: nil)
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
