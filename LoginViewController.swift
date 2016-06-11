//
//  LoginViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/26/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "debatestage")!)
        // Do any additional setup after loading the view.
        passwordField.delegate = self
        loginField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func login(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(loginField.text!, password: passwordField.text!) { (user: PFUser?, error: NSError?) -> Void in
            if error != nil{
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = error?.description
                alert.addButtonWithTitle("OK")
                alert.show()
            }else{
                currentUser = PFUser.currentUser()!
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation["user"] = PFUser.currentUser()!
                currentInstallation.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    if success{
                        if PFUser.currentUser()?.objectForKey("side") != nil{
                            self.performSegueWithIdentifier("loggedIn", sender: self)
                        }else{
                            self.performSegueWithIdentifier("toChoose", sender: self)
                        }
                    }
                })
            }
        }
    }
    @IBAction func exit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
