//
//  PeopleViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 2/2/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var people: [PFUser]!
    var timer: NSTimer!
    override func viewDidAppear(animated: Bool) {
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            self.people = objects as! [PFUser]
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.automaticallyAdjustsScrollViewInsets = false
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            self.people = objects as! [PFUser]
            self.tableView.reloadData()
        })
        timer = NSTimer.scheduledTimerWithTimeInterval(13.5, target: self, selector: "reload", userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    func reload(){
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            self.people = objects as! [PFUser]
        })
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if people != nil{
            return people.count
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("personCell") as! PersonTableViewCell
        cell.user = people[indexPath.row]
        cell.setUp()
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
