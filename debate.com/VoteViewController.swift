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
        
        commentButton.setTitleColor(UIColor.white, for: UIControlState())
        commentButton.backgroundColor = UIColor.cyan
        commentButton.layer.cornerRadius = 6
        print(debate)
        print(debate.forArguer)
        print(debate.againstArguer)
        if debate.forArguer != "" || debate.againstArguer != ""{
            forLabel.text = debate.forArguer
            againstLabel.text = debate.againstArguer
            forVotes.text = "\(debate.forVotes)"
            againstVotes.text = "\(debate.againstVotes)"
        }else{
            forLabel.text = debate.title.components(separatedBy: ":")[0]
            againstLabel.text = debate.title.components(separatedBy: ":")[1]
            forVotes.text = "\(debate.forVotes)"
            againstVotes.text = "\(debate.againstVotes)"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debate.comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = debate.comments[(indexPath as NSIndexPath).row]
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel!.numberOfLines = 0
        return cell
    }
    func deleteElement(_ element: String, array: [String]) -> [String]{
        return array.filter() { $0 != element }
    }
    @IBAction func forVote(_ sender: AnyObject) {
        if !debate.forVoters.contains(PFUser.current()!.username!) {
            debate.forVotes = debate.forVotes + 1
            forVotes.text = "\(debate.forVotes)"
            debate.forVoters.append(PFUser.current()!.username!)
            rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
            rawData.saveEventually()
        }
        if debate.againstVoters.contains(PFUser.current()!.username!){
            debate.againstVotes = debate.againstVotes - 1
            againstVotes.text = "\(debate.againstVotes)"
            debate.againstVoters = deleteElement(PFUser.current()!.username!, array: debate.againstVoters)
            rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
            rawData.saveEventually()
            
        }
    }
    @IBAction func againstVote(_ sender: AnyObject) {
        if !debate.againstVoters.contains(PFUser.current()!.username!){
            debate.againstVotes = debate.againstVotes + 1
            againstVotes.text = "\(debate.againstVotes)"
            debate.againstVoters.append(PFUser.current()!.username!)
            rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
            rawData.saveEventually()
            
        }
        if debate.forVoters.contains(PFUser.current()!.username!){
            debate.forVotes = debate.forVotes - 1
            forVotes.text = "\(debate.forVotes)"
            debate.forVoters = deleteElement(PFUser.current()!.username!, array: debate.forVoters)
            rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
            rawData.saveEventually()
            
        }
    }
    @IBAction func comment(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Comment", message: "", preferredStyle: UIAlertControllerStyle.alert)
        var commentTextField: UITextField?
        let commentAction = UIAlertAction(title: "Done", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
            print(commentTextField)
            if commentTextField!.text != ""{
                self.debate.comments.append((commentTextField?.text)!)
                self.rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: self.debate)
                self.rawData.saveInBackground(block: { (success, error) -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
            
        }
        alert.addAction(cancelAction)
        alert.addAction(commentAction)
        alert.addTextField { (textField: UITextField) -> Void in
            commentTextField = textField
            commentTextField?.placeholder = "Comment"
        }
        self.present(alert, animated: true, completion: nil)
    }
}
