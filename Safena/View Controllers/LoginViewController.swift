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
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LoginToNotify", sender: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User signed out")
    }

    // Buttons
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    let loginButton = FBSDKLoginButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        if (Auth.auth().currentUser != nil) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LoginToNotify", sender: nil)
            }
        }

        loginButton.delegate = self
        loginButton.readPermissions = ["email"]
        loginButton.center = CGPoint(x: view.center.x, y: view.center.y + 100)
        view.addSubview(loginButton)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }
    
    override func viewWillLayoutSubviews() {
//        let leftHorizontalConstraint = loginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10)
//        let rightHorizontalConstraint = loginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 10)
//        view.addConstraints([leftHorizontalConstraint, rightHorizontalConstraint])
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
