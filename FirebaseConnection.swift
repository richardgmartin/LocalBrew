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
let _USER_REF = Firebase(url: "\(BASE_URL)/users")
let _BREWERY_REF = Firebase(url: "\(BASE_URL)/breweries")

class FirebaseConnection: NSObject
{
    static let firebaseConnection = FirebaseConnection()
    
    private var _BASE_REF = Firebase(url: "\(BASE_URL)")
    //private var

    var BASE_REF:Firebase {
        return _BASE_REF
    }
    
    var USER_REF:Firebase
    {
        return _USER_REF
    }
    
    var BREWERY_REF:Firebase
    {
        return _BREWERY_REF
    }
    
    func createNewAccount(uid: String, user: Dictionary<String,String>) {
        
        USER_REF.childByAppendingPath(uid).setValue(user)
    }
    
    func createNewBrewery(brewery:Dictionary<String, AnyObject>)
    {
        BREWERY_REF.childByAutoId().setValue(brewery)
        
    }
    
    var CURRENT_USER_REF: Firebase
    {

        let userID = self.USER_REF.authData.uid
        let currentUser = Firebase(url: "\(USER_REF)").childByAppendingPath(userID)
        return currentUser!
    }
    
    
    
    

}
