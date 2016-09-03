//
//  LoginViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/26/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "debatestage")!)
        // Do any additional setup after loading the view.
        passwordField.delegate = self
        loginField.delegate = self
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        loginButton.readPermissions = ["user_friends"]
        //self.view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func login(_ sender: AnyObject) {
        PFUser.logInWithUsername(inBackground: loginField.text!, password: passwordField.text!) { (user, error) -> Void in
            if error != nil{
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = error?.localizedDescription
                alert.addButton(withTitle: "OK")
                alert.show()
            }else{
                currentUser = PFUser.current()!
                let currentInstallation = PFInstallation.current()
                currentInstallation!["user"] = PFUser.current()!
                currentInstallation!.saveInBackground(block: { (success, error) -> Void in
                    if success{
                        //if PFUser.current()?.object(forKey: "side") != nil{
                            self.performSegue(withIdentifier: "loggedIn", sender: self)
                        //}else{
                            //self.performSegue(withIdentifier: "toChoose", sender: self)
                        //}
                    }
                })
            }
        }
    }
    @IBAction func exit(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
