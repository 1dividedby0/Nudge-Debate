//
//  NotificationsTableViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 1/1/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class NotificationsTableViewController: UITableViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var notifications: [String] = []
    var rawDebates: [PFObject] = []
    var debates: [Debate] = []
    var timer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Notifications"
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //loadNotifications()
        //timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "loadNotifications", userInfo: nil, repeats: true)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notification") as! NotificationTableViewCell
        cell.notificationLabel.text = notifications[(indexPath as NSIndexPath).row]
        cell.rawData = rawDebates[(indexPath as NSIndexPath).row]
        cell.debate = debates[(indexPath as NSIndexPath).row]
        cell.parent = self
        cell.index = (indexPath as NSIndexPath).row
        print(notifications[(indexPath as NSIndexPath).row])
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date = dateFormatter.date(from: cell.debate.inviteTimeStamp)
        // get time elapsed
        var currentSeconds = Int(Date().timeIntervalSince(date!))
        // get the time left not elapsed
        // give 8 minutes for user to respond
        currentSeconds = 480 - currentSeconds
        if currentSeconds <= 0{
            notifications.remove(at: (indexPath as NSIndexPath).row)
            cell.debate.defender = ""
            cell.rawData.setObject("", forKey: defenderKey)
            cell.rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: cell.debate)
            cell.rawData.saveInBackground()
            self.tableView.reloadData()
        }
        
        return cell
    }
    func loadNotifications(){
        let query = PFQuery(className: "Debates")
        query.findObjectsInBackground { (objects: [PFObject]?, error: NSError?) -> Void in
            if objects != nil{
            var nots: [String] = []
            var raws: [PFObject] = []
            var debs: [Debate] = []
            for i in objects!{
                let debate = NSKeyedUnarchiver.unarchiveObject(with: i["Debate"] as! Data) as! Debate
                // this means that the defender has not accepted yet
                print(currentUser.username!)
                if debate.defender == currentUser.username! {
                    nots.append("\(debate.challenger) has invited you to the \(debate.title) debate!")
                    raws.append(i)
                    debs.append(debate)
                }
            }
            
            self.notifications = nots
            self.rawDebates = raws
            self.debates = debs
            self.tableView.reloadData()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
}
