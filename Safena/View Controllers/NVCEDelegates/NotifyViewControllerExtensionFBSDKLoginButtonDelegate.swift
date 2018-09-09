//
//  NotifyViewControllerExtensionFBSDKLoginButtonDelegate.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/10/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Firebase

extension NotifyViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            printt("""
                loginButton: \(loginButton.debugDescription)
                didCompleteWith: \(result.debugDescription)
                error: \(error.localizedDescription)
                """)
            return
        }
        print("Success")
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                printt("""
                    with: \(credential.debugDescription)
                    error: \(error.localizedDescription)
                    """)
            }
            printt("User is signed in")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User signed out")
    }
    
    
}
