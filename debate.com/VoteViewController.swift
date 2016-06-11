//
//  VoteViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 1/8/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class VoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var againstVotes: UILabel!
    @IBOutlet weak var forVotes: UILabel!
    @IBOutlet weak var forLabel: UILabel!
    @IBOutlet weak var againstLabel: UILabel!
    @IBOutlet weak var forButton: UIButton!
    @IBOutlet weak var againstButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var debate: Debate!
    var rawData: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        commentButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        commentButton.backgroundColor = UIColor.cyanColor()
        commentButton.layer.cornerRadius = 6
        if debate.forArguer != "" || debate.againstArguer != ""{
            forLabel.text = debate.forArguer
            againstLabel.text = debate.againstArguer
            forVotes.text = "\(debate.forVotes)"
            againstVotes.text = "\(debate.againstVotes)"
        }else{
            forLabel.text = debate.title.componentsSeparatedByString(":")[0]
            againstLabel.text = debate.title.componentsSeparatedByString(":")[1]
            forVotes.text = "\(debate.forVotes)"
            againstVotes.text = "\(debate.againstVotes)"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debate.comments.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = debate.comments[indexPath.row]
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel!.numberOfLines = 0
        return cell
    }
    func deleteElement(element: String, array: [String]) -> [String]{
        return array.filter() { $0 != element }
    }
    @IBAction func forVote(sender: AnyObject) {
        if !debate.forVoters.contains(PFUser.currentUser()!.username!) {
            debate.forVotes = debate.forVotes + 1
            forVotes.text = "\(debate.forVotes)"
            debate.forVoters.append(PFUser.currentUser()!.username!)
            rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
            rawData.saveEventually()
        }
        if debate.againstVoters.contains(PFUser.currentUser()!.username!){
            debate.againstVotes = debate.againstVotes - 1
            againstVotes.text = "\(debate.againstVotes)"
            debate.againstVoters = deleteElement(PFUser.currentUser()!.username!, array: debate.againstVoters)
            rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
            rawData.saveEventually()
            
        }
    }
    @IBAction func againstVote(sender: AnyObject) {
        if !debate.againstVoters.contains(PFUser.currentUser()!.username!){
            debate.againstVotes = debate.againstVotes + 1
            againstVotes.text = "\(debate.againstVotes)"
            debate.againstVoters.append(PFUser.currentUser()!.username!)
            rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
            rawData.saveEventually()
            
        }
        if debate.forVoters.contains(PFUser.currentUser()!.username!){
            debate.forVotes = debate.forVotes - 1
            forVotes.text = "\(debate.forVotes)"
            debate.forVoters = deleteElement(PFUser.currentUser()!.username!, array: debate.forVoters)
            rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
            rawData.saveEventually()
            
        }
    }
    @IBAction func comment(sender: AnyObject) {
        let alert = UIAlertController(title: "Comment", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        var commentTextField: UITextField?
        let commentAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            print(commentTextField)
            if commentTextField!.text != ""{
                self.debate.comments.append((commentTextField?.text)!)
                self.rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(self.debate)
                self.rawData.saveInBackgroundWithBlock({ (success, error) -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            
        }
        alert.addAction(cancelAction)
        alert.addAction(commentAction)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            commentTextField = textField
            commentTextField?.placeholder = "Comment"
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
