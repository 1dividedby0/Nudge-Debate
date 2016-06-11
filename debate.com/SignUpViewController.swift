//
//  SignUpViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 12/18/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "debatestage")!)
        confirmPasswordField.delegate = self
        passwordField.delegate = self
        usernameField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUp(sender: AnyObject) {
        if passwordField.text == confirmPasswordField.text && !usernameField.text!.containsString("-"){
            let user = PFUser()
            user.username = usernameField.text
            user.password = passwordField.text
            user["inDebate"] = false
            user.signUpInBackgroundWithBlock { (success: Bool!, error: NSError?) -> Void in
                if error != nil || success != true{
                    let alert = UIAlertView()
                    alert.title = "Error"
                    alert.message = error?.description
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }else{
                    currentUser = PFUser.currentUser()!
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation["user"] = PFUser.currentUser()!
                    currentInstallation.saveInBackgroundWithBlock({ (success, error) -> Void in
                        self.performSegueWithIdentifier("toChoose", sender: self)
                    })
                }
            }
        }else if usernameField.text!.containsString("-") || usernameField.text!.containsString("o+"){
            let alert = UIAlertController(title: "Bad Characters", message: "Make sure your username does not include '-' or 'o+'", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Mismatch", message: "Both passwords have to be the same.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
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