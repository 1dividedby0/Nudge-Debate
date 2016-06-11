//
//  GroupsViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 2/13/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class GroupsViewController: UITableViewController {
    
    var data = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(GroupTableViewCell.self, forCellReuseIdentifier: "groupCell")
        let query = PFQuery(className: "Groups")
        query.findObjectsInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                self.data = data!
                self.tableView.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as! GroupTableViewCell
        print(data[indexPath.row].objectForKey("name")!)
        if cell.groupName != nil{
            cell.groupName.text = data[indexPath.row].objectForKey("name") as? String
        }
        cell.messages = data[indexPath.row].objectForKey("messages") as? [String]
        return cell
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
