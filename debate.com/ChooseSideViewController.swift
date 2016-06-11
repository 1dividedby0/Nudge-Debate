//
//  ChooseSideViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 3/6/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class ChooseSideViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func blueSide(sender: AnyObject) {
        PFUser.currentUser()!.setObject("blue", forKey: "side")
        PFUser.currentUser()!.saveInBackgroundWithBlock { (success, error) -> Void in
            self.performSegueWithIdentifier("chosen", sender: self)
        }
    }
    @IBAction func redSide(sender: AnyObject) {
        PFUser.currentUser()!.setObject("red", forKey: "side")
        PFUser.currentUser()!.saveInBackgroundWithBlock { (success, error) -> Void in
            self.performSegueWithIdentifier("chosen", sender: self)
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
