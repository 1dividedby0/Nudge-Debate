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
    
    @IBAction func blueSide(_ sender: AnyObject) {
        PFUser.current()!.setObject("blue", forKey: "side")
        PFUser.current()!.saveInBackground { (success, error) -> Void in
            self.performSegue(withIdentifier: "chosen", sender: self)
        }
    }
    @IBAction func redSide(_ sender: AnyObject) {
        PFUser.current()!.setObject("red", forKey: "side")
        PFUser.current()!.saveInBackground { (success, error) -> Void in
            self.performSegue(withIdentifier: "chosen", sender: self)
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
