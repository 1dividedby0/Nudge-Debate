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

class AddArgumentViewController: UIViewController, UITextViewDelegate{
    let placeHolder = "Add your argument here. Press the microphone button in your keyboard if you wish to utilize the speech to text feature."
    @IBOutlet weak var argumentTextField: UITextView!
    var rawDebate: PFObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        argumentTextField.delegate = self
        argumentTextField.text = placeHolder
        argumentTextField.textColor = UIColor.lightGray()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if argumentTextField.textColor == UIColor.lightGray(){
            argumentTextField.text = ""
            argumentTextField.textColor = UIColor.black()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolder
            textView.textColor = UIColor.lightGray()
        }
    }
    
    @IBAction func submitArgument(_ sender: AnyObject) {
        if argumentTextField.text.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
            let alert = UIAlertController(title: "Empty Argument", message: "Are you trying to lose?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Fine", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        DebateClient.postArgument(rawDebate.objectId!, argument: "\(PFUser.current()!.username!):\(argumentTextField.text)")
        let debate = DebateClient.convert(rawDebate)
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        debate.dateStarted = df.string(from: Date())
        rawDebate.setObject(debate.dateStarted, forKey: dateStartedKey)
        rawDebate["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
        //if connectedToNetwork(){
            rawDebate.saveInBackground()
        //}else{
        //    rawDebate.saveEventually()
        //}
        turnFinished = true
        DebateClient.sendPush("It is your turn!", username: (PFUser.current()?.username! == debate.forArguer) ? debate.againstArguer:debate.forArguer)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
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
