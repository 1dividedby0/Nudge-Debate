//
//  NotificationTableViewCell.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 1/1/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class NotificationTableViewCell: UITableViewCell {
    var rawData: PFObject!
    var debate: Debate!
    var parent: NotificationsTableViewController!
    var index: Int!
    @IBOutlet weak var notificationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func accept(sender: AnyObject) {
        if PFUser.currentUser()!.objectForKey("inDebate") as! Bool{
            let alert = UIAlertController(title: "You have already joined a debate!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            parent.presentViewController(alert, animated: true, completion: nil)
            return
        }
        PFUser.currentUser()!.setObject(true, forKey: "inDebate")
        PFUser.currentUser()!.saveInBackground()
        PFUser.currentUser()!.fetchInBackground()
        debate.defender = "\(debate.defender)-"
        rawData.setObject(debate.defender, forKey: defenderKey)
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let dateInFormat:String = dateFormatter.stringFromDate(NSDate())
        debate.dateStarted = dateInFormat
        rawData.setObject(dateInFormat, forKey: dateStartedKey)
        rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
        rawData.saveInBackground()
        parent.notifications.removeAtIndex(index)
        parent.loadNotifications()
        DebateClient.sendPush("\(debate.defender) has accepted your debate \(debate.title))", username: debate.challenger)
    }
    @IBAction func decline(sender: AnyObject) {
        if PFUser.currentUser()!.objectForKey("inDebate") as! Bool{
            let alert = UIAlertController(title: "You have already joined a debate!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            parent.presentViewController(alert, animated: true, completion: nil)
            return
        }
        PFUser.currentUser()!.setObject(false, forKey: "inDebate")
        PFUser.currentUser()!.saveInBackground()
        PFUser.currentUser()!.fetchInBackground()
        debate.defender = ""
        rawData.setObject(debate.defender, forKey: defenderKey)
        rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
        rawData.saveInBackground()
        parent.notifications.removeAtIndex(index)
        parent.loadNotifications()
        DebateClient.sendPush("\(debate.defender) has declined your debate \(debate.title)", username: debate.challenger)
    }

}
