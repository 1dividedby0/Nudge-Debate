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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func accept(_ sender: AnyObject) {
        if PFUser.current()!.object(forKey: "inDebate") as! Bool{
            let alert = UIAlertController(title: "You have already joined a debate!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            parent.present(alert, animated: true, completion: nil)
            return
        }
        PFUser.current()!.setObject(true, forKey: "inDebate")
        PFUser.current()!.saveInBackground()
        PFUser.current()!.fetchInBackground()
        debate.defender = "\(debate.defender)-"
        rawData.setObject(debate.defender, forKey: defenderKey)
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let dateInFormat:String = dateFormatter.string(from: Date())
        debate.dateStarted = dateInFormat
        rawData.setObject(dateInFormat, forKey: dateStartedKey)
        rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
        rawData.saveInBackground()
        parent.notifications.remove(at: index)
        parent.loadNotifications()
        DebateClient.sendPush("\(debate.defender) has accepted your debate \(debate.title))", username: debate.challenger)
    }
    @IBAction func decline(_ sender: AnyObject) {
        if PFUser.current()!.object(forKey: "inDebate") as! Bool{
            let alert = UIAlertController(title: "You have already joined a debate!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            parent.present(alert, animated: true, completion: nil)
            return
        }
        PFUser.current()!.setObject(false, forKey: "inDebate")
        PFUser.current()!.saveInBackground()
        PFUser.current()!.fetchInBackground()
        debate.defender = ""
        rawData.setObject(debate.defender, forKey: defenderKey)
        rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
        rawData.saveInBackground()
        parent.notifications.remove(at: index)
        parent.loadNotifications()
        DebateClient.sendPush("\(debate.defender) has declined your debate \(debate.title)", username: debate.challenger)
    }

}
