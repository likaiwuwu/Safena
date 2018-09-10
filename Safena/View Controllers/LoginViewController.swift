//
//  LoginViewController.swift
//  Safena
//
//  Created by Li-Kai Wu on 9/10/18.
//  Copyright © 2018 Li-Kai Wu. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
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
        printt("Credential: \(String(describing: FBSDKAccessToken.current()?.tokenString))")
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                printt("""
                    with: \(credential.debugDescription)
                    error: \(error.localizedDescription)
                    """)
            }
            printt("User is signed in")
            self.performSegue(withIdentifier: "LoginToNotify", sender: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User signed out")
    }

    // Buttons
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.readPermissions = ["email"]
        loginButton.center = view.center
        view.addSubview(loginButton)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
