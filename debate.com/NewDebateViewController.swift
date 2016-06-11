//
//  NewDebateViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/28/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
import Darwin

let categoryArray = ["Economy", "Education", "Environment", "Extraterrestrial", "Health", "History", "Languages", "Law", "Politics", "Religion", "Science"]

class NewDebateViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    let timeArray = ["3 min", "5 min", "7 min", "9 min", "10 min"]
    
    var selectedRowMinute = 0
    var minutesPerArgument = 0
    let unSwitchedStateHeight: CGFloat = 90.0
    let switchedStateHeight: CGFloat = 140.0
    var rawData: PFObject!
    var category = ""
    @IBOutlet weak var publicTableViewCell: UITableViewCell!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var timePerArgumentField: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var rebuttalRoundsField: UITextField!
    @IBOutlet weak var forAgainstControl: UISegmentedControl!
    @IBOutlet weak var opponentUsernameField: UITextField!
    @IBOutlet weak var autoGenerateOpponentSwitch: UISwitch!
    @IBOutlet weak var debateTopicField: UITextField!
    @IBOutlet weak var generateTableViewCell: UITableViewCell!
    @IBOutlet weak var submitButton: UIButton!
    var debate: Debate!
    override func viewDidLoad() {
        super.viewDidLoad()
        PFUser.currentUser()!.fetchInBackground()
        timePerArgumentField.dataSource = self
        timePerArgumentField.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        submitButton.layer.borderColor = UIColor.redColor().CGColor
        navigationItem.setHidesBackButton(true, animated: true)
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        navigationItem.setLeftBarButtonItem(leftBarButton, animated: true)
        // Do any additional setup after loading the view.
    }
    func cancel(){
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.isEqual(timePerArgumentField){
            selectedRowMinute = row
        }
        category = categoryArray[row]
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(timePerArgumentField){
            return timeArray.count
        }
        return categoryArray.count
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.isEqual(timePerArgumentField){
            return timeArray[row]
        }
        return categoryArray[row]
    }
    @IBAction func submitDebate(sender: AnyObject) {
        for var i = 0; i < curseWordArray.count; i++ {
            if debateTopicField.text!.containsString(curseWordArray[i]){
                let alert = UIAlertController(title: "We Look Down Upon Trolls", message: "If you mention another curse word, your device will be banned!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                DebateClient.sendPush("The AI has picked up \(PFUser.currentUser()!.username!) swearing \(debateTopicField.text!)", username: "John Cena")
                return
            }
        }
        if PFUser.currentUser()!.objectForKey("inDebate") as! Bool == true{
            let alert = UIAlertController(title: "Don't Forget!", message: "You are currently in a debate!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        var forArguer: String = ""
        var defender = ""
        var againstArguer = ""
        if selectedRowMinute == 0{
            minutesPerArgument = 3
        }else if selectedRowMinute == 1{
            minutesPerArgument = 5
        }else if selectedRowMinute == 2{
            minutesPerArgument = 7
        }else if selectedRowMinute == 3{
            minutesPerArgument = 9
        }else if selectedRowMinute == 4{
            minutesPerArgument = 10
        }
        if(Int(rebuttalRoundsField.text!) > 1 && Int(rebuttalRoundsField.text!) < 5 && opponentUsernameField.text != PFUser.currentUser()!.username!){
            PFUser.currentUser()?.saveInBackground()
            print(debateTopicField.text!)
            if autoGenerateOpponentSwitch.on{
                let query = PFUser.query()!
                query.whereKey("inDebate", equalTo: false)
                query.findObjectsInBackgroundWithBlock { (users: [PFObject]?, error: NSError?) -> Void in
                    if users?.count > 1{
                        var currentUserIndex = 0
                        let setOfUsers = users as! [PFUser]
                        for var i = 0; i<setOfUsers.count; i++ {
                            let user = setOfUsers[i]
                            if user.username == PFUser.currentUser()?.username {
                                currentUserIndex = i
                                print(currentUserIndex)
                                break
                            }
                        }
                        //let randomUser = users![self.generateRand((users?.count)!, currentIndex: currentUserIndex)] as! PFUser
                        if self.forAgainstControl.selectedSegmentIndex == 0{
                            forArguer = (PFUser.currentUser()?.username!)!
                            againstArguer = "o+"
                            defender = "o+"
                        }else{
                            againstArguer = PFUser.currentUser()!.username!
                            forArguer = "o+"
                            defender = forArguer
                        }
                        
                        PFUser.currentUser()!.setObject(true, forKey: "inDebate")
                        PFUser.currentUser()!.saveInBackground()
                        
                        self.debate = Debate(title: self.debateTopicField.text!, challenger: (PFUser.currentUser()?.username)!, defender: defender, arguments: [String](), forArguer: forArguer, againstArguer: againstArguer, rebuttalRounds: Int(self.rebuttalRoundsField.text!)!, minutesPerArgument: self.minutesPerArgument, category: self.category, comments: [String]())
                        self.rawData = PFObject(className: "Debates")
                        self.rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(self.debate)
                        DebateClient.createDebate(self.debate, rawData: self.rawData)
                        self.performSegueWithIdentifier("newDebate", sender: self)
                    }
                }
            }else{
                let query = PFUser.query()!
                query.whereKey("username", equalTo: opponentUsernameField.text!)
                query.whereKey("inDebate", equalTo: false)
                var defenderUser: String = ""
                var aArguer = ""
                var fArguer = ""
                query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if objects!.count > 0{
                        defenderUser = (objects![0] as! PFUser).username!
                        
                        if self.forAgainstControl.selectedSegmentIndex == 0{
                            fArguer = PFUser.currentUser()!.username!
                            aArguer = defenderUser
                        }else{
                            fArguer = defenderUser
                            aArguer = PFUser.currentUser()!.username!
                        }
                        
                        PFUser.currentUser()!.setObject(true, forKey: "inDebate")
                        PFUser.currentUser()!.saveInBackground()
    
                        self.debate = Debate(title: self.debateTopicField.text!, challenger: PFUser.currentUser()!.username!, defender: defenderUser, arguments: [String](), forArguer: fArguer, againstArguer: aArguer, rebuttalRounds: Int(self.rebuttalRoundsField.text!)!, minutesPerArgument: self.minutesPerArgument, category: self.category, comments: [String]())
                    
                        self.rawData = PFObject(className: "Debates")
                        self.rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(self.debate)
                        DebateClient.createDebate(self.debate, rawData: self.rawData)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "User Not Found", message: "The opponent you searched for is either in a debate or does not exist.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            }
        }else{
            let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(OKAction)
            if Int(rebuttalRoundsField.text!) < 1{
                alert.title = "You need to have more than 1 rebuttal round!"
            }else if Int(rebuttalRoundsField.text!) > 5{
                alert.title = "You need to have less than 5 rebuttal rounds!"
            }else if opponentUsernameField.text == PFUser.currentUser()!.username!{
                alert.title = "Don't be lonely, create a debate with someone other than yourself."
            }
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !autoGenerateOpponentSwitch.on && indexPath.row == 1{
            return switchedStateHeight
        }
        return unSwitchedStateHeight
    }
    func generateRand(limit: Int, currentIndex: Int) -> Int{
        var possibleNums = [Int](0..<limit)
        possibleNums.removeAtIndex(currentIndex)
        let random = Int(arc4random_uniform(UInt32(possibleNums.count)))
        return possibleNums[random]
    }
    @IBAction func `switch`(sender: AnyObject) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        if !autoGenerateOpponentSwitch.on{
            self.opponentUsernameField.hidden = false
            self.opponentUsernameField.text = ""
        }else{
            self.opponentUsernameField.hidden = true
        }
    }
    
    @IBAction func publicSwitch(sender: AnyObject) {
        if !publicSwitch.on{
            
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newDebate"{
            let vc = segue.destinationViewController as! DebateManagerViewController
            vc.debate = debate
            vc.rawData = rawData
        }
    }
    

}
