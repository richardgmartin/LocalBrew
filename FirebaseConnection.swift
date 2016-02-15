//
//  FirebaseConnection.swift
//  LocalBrew
//
//  Created by Yemi Ajibola on 2/14/16.
//  Copyright © 2016 Richard Martin. All rights reserved.
//

import UIKit
import Firebase

let BASE_URL = "https://localbrew.firebaseio.com/"

class FirebaseConnection: NSObject
{
    static let firebaseConnection = FirebaseConnection()
    
    private var _BASE_REF = Firebase(url: "\(BASE_URL)")
    private var _USER_REF = Firebase(url: "\(BASE_URL)/users")

    var BASE_REF:Firebase {
        return _BASE_REF
    }
    
    var USER_REF:Firebase
    {
        return _USER_REF
    }
    
    func createNewAccount(uid: String, user: Dictionary<String,String>) {
        
        USER_REF.childByAppendingPath(uid).setValue(user)
    }
    
    var CURRENT_USER_REF: Firebase {
        let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
        let currentUser = Firebase(url: "\(BASE_REF)").childByAppendingPath("users").childByAppendingPath(userID)
        return currentUser!
    }
    
    
    
    

}
