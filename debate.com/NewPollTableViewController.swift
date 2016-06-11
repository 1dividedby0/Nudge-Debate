//
//  NewPollTableViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 2/7/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
import Foundation
class NewPollTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var privateNamesTextField: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var firstSideField: UITextField!
    @IBOutlet weak var secondSideField: UITextField!
    var query: PFQuery!
    var users: [String]!
    var privateUsers: [String]!
    var currentUser: String!
    // string = text of privateNamesTextField
    var string = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        users = [String]()
        query = PFUser.query()
        query!.findObjectsInBackgroundWithBlock({ (array, error) -> Void in
            for i in array!{
                self.users.append((i as! PFUser).username!)
            }
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        navigationItem.setLeftBarButtonItem(leftBarButton, animated: true)
    }
    func cancel(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func textFieldEdited(sender: AnyObject) {
        if privateNamesTextField.text!.characters.count > string.characters.count{
            string = privateNamesTextField.text!
            if string.containsString(","){
                let regex = try! NSRegularExpression(pattern: ",\\s*(\\S[^,]*)$", options: [])
                if let match = regex.firstMatchInString(string, options: [], range: NSRange(location: 0, length: string.characters.count)){
                    let result = string.substringFromIndex(string.startIndex.advancedBy(match.rangeAtIndex(1).location))
                    for i in users{
                        let length = result.characters.count
                        // starts searching from beginning from string instead of anywhere in string
                        if length <= i.characters.count{
                            
                            if i.lowercaseString.substringToIndex(i.startIndex.advancedBy(length)) == result.lowercaseString{
                                self.privateNamesTextField.text = string.stringByReplacingOccurrencesOfString(string.componentsSeparatedByString(",")[string.componentsSeparatedByString(",").count-1], withString: i)
                            }
                        }
                    }
                }
            }else{
                // if it is the first name in the list
                let result = string
                for i in users{
                    let length = result.characters.count
                    if length <= i.characters.count{
                        if i.lowercaseString.substringToIndex(i.startIndex.advancedBy(length)) == result.lowercaseString{
                            self.privateNamesTextField.text = i
                        }
                    }
                }
            }
        }
            string = privateNamesTextField.text!
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row]
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if `switch`.on && indexPath.row == 2{
            return 81
        }else if indexPath.row == 2{
            return 136
        }else if indexPath.row == 0 || indexPath.row == 1{
            return 67
        }else{
            return 160
        }
    }
    @IBAction func publicSwitch(sender: AnyObject) {
        
        tableView.beginUpdates()
        tableView.endUpdates()
        if `switch`.on{
            privateNamesTextField.hidden = true
            privateNamesTextField.text = ""
        }else{
            privateNamesTextField.hidden = false
        }
    }
    @IBAction func submit(sender: AnyObject) {
        let poll = Debate(title: "\(firstSideField.text!) : \(secondSideField.text!)", challenger: "", defender: "", arguments: [PFUser.currentUser()!.username!] + privateNamesTextField.text!.componentsSeparatedByString(","), forArguer: "", againstArguer: "", rebuttalRounds: 0, minutesPerArgument: 0, category: categoryArray[picker.selectedRowInComponent(0)], comments: [])
        for i in poll.arguments{
            // might not work if usernames have spaces in front of them because of adding commas and then putting spaces
            DebateClient.sendPush("\(PFUser.currentUser()!.username!) has invited you to a private poll, \(poll.title)", username: i)
        }
        let object = PFObject(className: "Private")
        object.setObject(NSKeyedArchiver.archivedDataWithRootObject(poll), forKey: "Debate")
        DebateClient.createDebate(poll, rawData: object)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
}
