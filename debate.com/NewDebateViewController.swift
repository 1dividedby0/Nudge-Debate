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
        PFUser.current()!.fetchInBackground()
        timePerArgumentField.dataSource = self
        timePerArgumentField.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        submitButton.layer.borderColor = UIColor.red.cgColor
        navigationItem.setHidesBackButton(true, animated: true)
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: "cancel")
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
        // Do any additional setup after loading the view.
    }
    func cancel(){
        navigationController!.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.isEqual(timePerArgumentField){
            selectedRowMinute = row
        }
        category = categoryArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(timePerArgumentField){
            return timeArray.count
        }
        return categoryArray.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.isEqual(timePerArgumentField){
            return timeArray[row]
        }
        return categoryArray[row]
    }
    @IBAction func submitDebate(_ sender: AnyObject) {
        for i in 0 ..< curseWordArray.count {
            if debateTopicField.text!.contains(curseWordArray[i]){
                let alert = UIAlertController(title: "We Look Down Upon Trolls", message: "If you mention another curse word, your device will be banned!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                DebateClient.sendPush("The AI has picked up \(PFUser.current()!.username!) swearing \(debateTopicField.text!)", username: "John Cena")
                return
            }
        }
        if PFUser.current()!.object(forKey: "inDebate") as! Bool == true{
            let alert = UIAlertController(title: "Don't Forget!", message: "You are currently in a debate!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
        if(Int(rebuttalRoundsField.text!)! > 1 && Int(rebuttalRoundsField.text!)! < 5 && opponentUsernameField.text != PFUser.current()!.username!){
            PFUser.current()?.saveInBackground()
            print(debateTopicField.text!)
            if autoGenerateOpponentSwitch.isOn{
                let query = PFUser.query()!
                
                //query.whereKey("inDebate", equalTo: false)
                query.findObjectsInBackground { (objects, error) in
                    var users = objects!
                    for i in 0 ..< users.count {
                        if users.count <= i{
                            break
                        }
                        if users[i].value(forKey: "inDebate") as! Bool == true {
                            users.remove(at: i)
                        }
                    }
                    if error == nil && users.count > 1{
                        var currentUserIndex = 0
                        let setOfUsers = users as! [PFUser]
                        for i in 0 ..< setOfUsers.count {
                            let user = setOfUsers[i]
                            if user.username == PFUser.current()?.username {
                                currentUserIndex = i
                                print(currentUserIndex)
                                break
                            }
                        }
                        //let randomUser = users![self.generateRand((users?.count)!, currentIndex: currentUserIndex)] as! PFUser
                        if self.forAgainstControl.selectedSegmentIndex == 0{
                            forArguer = (PFUser.current()?.username!)!
                            againstArguer = "o+"
                            defender = "o+"
                        }else{
                            againstArguer = PFUser.current()!.username!
                            forArguer = "o+"
                            defender = forArguer
                        }
                        
                        //PFUser.current()!.setObject(true, forKey: "inDebate")
                        //PFUser.current()!.saveInBackground()
                        
                        self.debate = Debate(title: self.debateTopicField.text!, challenger: (PFUser.current()?.username)!, defender: defender, arguments: [String](), forArguer: forArguer, againstArguer: againstArguer, rebuttalRounds: Int(self.rebuttalRoundsField.text!)!, minutesPerArgument: self.minutesPerArgument, category: self.category, comments: [String]())
                        self.rawData = PFObject(className: "Debates")
                        NSKeyedArchiver.setClassName("debate_com.Debate", for: Debate.self)
                        // fix by adding block to createDebate because 
                        self.rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: self.debate)
                        DebateClient.createDebate(self.debate, rawData: self.rawData, finished: {
                            self.performSegue(withIdentifier: "newDebate", sender: self)
                        })
                    }
                }
            }else{
                let query = PFUser.query()!
                query.whereKey("username", equalTo: opponentUsernameField.text!)
                query.whereKey("inDebate", equalTo: false)
                var defenderUser: String = ""
                var aArguer = ""
                var fArguer = ""
                query.findObjectsInBackground(block: { (objects, error) in
                    
                    if objects!.count > 0{
                        defenderUser = (objects![0] as! PFUser).username!
                        
                        if self.forAgainstControl.selectedSegmentIndex == 0{
                            fArguer = PFUser.current()!.username!
                            aArguer = defenderUser
                        }else{
                            fArguer = defenderUser
                            aArguer = PFUser.current()!.username!
                        }
                        
                        //PFUser.current()!.setObject(true, forKey: "inDebate")
                        //PFUser.current()!.saveInBackground()
    
                        self.debate = Debate(title: self.debateTopicField.text!, challenger: PFUser.current()!.username!, defender: defenderUser, arguments: [String](), forArguer: fArguer, againstArguer: aArguer, rebuttalRounds: Int(self.rebuttalRoundsField.text!)!, minutesPerArgument: self.minutesPerArgument, category: self.category, comments: [String]())
                    
                        self.rawData = PFObject(className: "Debates")
                        NSKeyedArchiver.setClassName("debate_com.Debate", for: Debate.self)
                        self.rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: self.debate)
                        DebateClient.createDebate(self.debate, rawData: self.rawData, finished: { 
                            self.dismiss(animated: true, completion: nil)
                        })
                    }else{
                        let alert = UIAlertController(title: "User Not Found", message: "The opponent you searched for is either in a debate or does not exist.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }else{
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            if Int(rebuttalRoundsField.text!)! < 1{
                alert.title = "You need to have more than 1 rebuttal round!"
            }else if Int(rebuttalRoundsField.text!)! > 5{
                alert.title = "You need to have less than 5 rebuttal rounds!"
            }else if opponentUsernameField.text == PFUser.current()!.username!{
                alert.title = "Don't be lonely, create a debate with someone other than yourself."
            }
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !autoGenerateOpponentSwitch.isOn && (indexPath as NSIndexPath).row == 1{
            return switchedStateHeight
        }
        return unSwitchedStateHeight
    }
    func generateRand(_ limit: Int, currentIndex: Int) -> Int{
        var possibleNums = [Int](0..<limit)
        possibleNums.remove(at: currentIndex)
        let random = Int(arc4random_uniform(UInt32(possibleNums.count)))
        return possibleNums[random]
    }
    @IBAction func `switch`(_ sender: AnyObject) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        if !autoGenerateOpponentSwitch.isOn{
            self.opponentUsernameField.isHidden = false
            self.opponentUsernameField.text = ""
        }else{
            self.opponentUsernameField.isHidden = true
        }
    }
    
    @IBAction func publicSwitch(_ sender: AnyObject) {
        if !publicSwitch.isOn{
            
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newDebate"{
            let vc = segue.destination as! DebateManagerViewController
            vc.debate = debate
            vc.rawData = rawData
        }
    }
    

}
