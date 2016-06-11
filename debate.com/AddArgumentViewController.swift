//
//  AddArgumentViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 12/10/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
import SystemConfiguration
import Foundation

var turnFinished = false

class AddArgumentViewController: UIViewController{
    
    @IBOutlet weak var argumentTextField: UITextView!
    var rawDebate: PFObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitArgument(sender: AnyObject) {
        if argumentTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == ""{
            let alert = UIAlertController(title: "Empty Argument", message: "Are you trying to lose?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Fine", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        DebateClient.postArgument(rawDebate.objectId!, argument: "\(PFUser.currentUser()!.username!):\(argumentTextField.text)")
        let debate = DebateClient.convert(rawDebate)
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        debate.dateStarted = df.stringFromDate(NSDate())
        rawDebate.setObject(debate.dateStarted, forKey: dateStartedKey)
        rawDebate["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
        if connectedToNetwork(){
            rawDebate.saveInBackground()
        }else{
            rawDebate.saveEventually()
        }
        turnFinished = true
        DebateClient.sendPush("It is your turn!", username: (PFUser.currentUser()?.username! == debate.forArguer) ? debate.againstArguer:debate.forArguer)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func cancel(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
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
