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
    var query: PFQuery<PFObject>!
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
        query!.findObjectsInBackground(block: { (array, error) -> Void in
            for i in array!{
                self.users.append((i as! PFUser).username!)
            }
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: "cancel")
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
    }
    func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func textFieldEdited(_ sender: AnyObject) {
        if privateNamesTextField.text!.characters.count > string.characters.count{
            string = privateNamesTextField.text!
            if string.contains(","){
                let regex = try! RegularExpression(pattern: ",\\s*(\\S[^,]*)$", options: [])
                if let match = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.characters.count)){
                    let result = string.substring(from: string.index(string.startIndex, offsetBy: match.range(at: 1).location))
                    for i in users{
                        let length = result.characters.count
                        // starts searching from beginning from string instead of anywhere in string
                        if length <= i.characters.count{
                            
                            if i.lowercased().substring(to: i.characters.index(i.startIndex, offsetBy: length)) == result.lowercased(){
                                self.privateNamesTextField.text = string.replacingOccurrences(of: string.components(separatedBy: ",")[string.components(separatedBy: ",").count-1], with: i)
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
                        if i.lowercased().substring(to: i.characters.index(i.startIndex, offsetBy: length)) == result.lowercased(){
                            self.privateNamesTextField.text = i
                        }
                    }
                }
            }
        }
            string = privateNamesTextField.text!
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if `switch`.isOn && (indexPath as NSIndexPath).row == 2{
            return 81
        }else if (indexPath as NSIndexPath).row == 2{
            return 136
        }else if (indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == 1{
            return 67
        }else{
            return 160
        }
    }
    @IBAction func publicSwitch(_ sender: AnyObject) {
        
        tableView.beginUpdates()
        tableView.endUpdates()
        if `switch`.isOn{
            privateNamesTextField.isHidden = true
            privateNamesTextField.text = ""
        }else{
            privateNamesTextField.isHidden = false
        }
    }
    @IBAction func submit(_ sender: AnyObject) {
        let poll = Debate(title: "\(firstSideField.text!) : \(secondSideField.text!)", challenger: "", defender: "", arguments: [PFUser.current()!.username!] + privateNamesTextField.text!.components(separatedBy: ","), forArguer: "", againstArguer: "", rebuttalRounds: 0, minutesPerArgument: 0, category: categoryArray[picker.selectedRow(inComponent: 0)], comments: [])
        for i in poll.arguments{
            // might not work if usernames have spaces in front of them because of adding commas and then putting spaces
            DebateClient.sendPush("\(PFUser.current()!.username!) has invited you to a private poll, \(poll.title)", username: i)
        }
        let object = PFObject(className: "Private")
        object.setObject(NSKeyedArchiver.archivedData(withRootObject: poll), forKey: "Debate")
        DebateClient.createDebate(poll, rawData: object)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
}
