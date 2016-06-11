//
//  DebateManagerViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 12/6/15.
//  Copyright ç 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class DebateManagerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var forClock: UILabel!
    @IBOutlet weak var addArgumentButton: UIButton!
    @IBOutlet weak var againstLabel: UILabel!
    @IBOutlet weak var forLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var againstClock: UILabel!
    var debate: Debate!
    var rawData: PFObject!
    var myDebate = false
    var currentSeconds = 0
    var reloadTimer: NSTimer!
    var clockTimer: NSTimer!
    override func viewDidAppear(animated: Bool) {
        //PFInstallation.currentInstallation().addUniqueObject(debate.title, forKey: "channels")
        //PFInstallation.currentInstallation().saveInBackground()
        if debate.forArguer == PFUser.currentUser()!.username || debate.againstArguer == PFUser.currentUser()!.username{
            myDebate = true
            print("yo")
            addArgumentButton.hidden = false
        }
        if reloadTimer != nil{
            reloadTimer.invalidate()
            reloadTimer = nil
        }
        if clockTimer != nil{
            clockTimer.invalidate()
            clockTimer = nil
        }
        
        if debate.defender != "o+"{
            forLabel.text = "For: \(debate.forArguer)"
            againstLabel.text = "Against: \(debate.againstArguer)"
            if !debate.finished{
                clockTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
            }
        }else if debate.defender == ""{
            // user has declined
            forLabel.text = debate.forArguer == debate.challenger ? debate.forArguer: "User declined"
            againstLabel.text = debate.againstArguer == debate.challenger ? debate.againstArguer: "User declined"
        }else{
            // user has not decided
            forLabel.text = debate.forArguer == debate.challenger ? debate.forArguer: "Pending"
            againstLabel.text = debate.againstArguer == debate.challenger ? debate.againstArguer: "Pending"
        }
        // Do any additional setup after loading the view.
        if !debate.finished{
            reloadTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "reload", userInfo: nil, repeats: true)
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        makeClocksHidden()
        self.navigationController?.title = debate.title
        //debate.comments = []
        //rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
        //rawData.saveInBackground()
        if debate.forArguer.stringByReplacingOccurrencesOfString("-", withString: "") == PFUser.currentUser()!.username || debate.againstArguer.stringByReplacingOccurrencesOfString("-", withString: "") == PFUser.currentUser()!.username{
            myDebate = true
            print("yo")
            addArgumentButton.hidden = false
        }
        print(debate.againstArguer)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        if debate.defender != "o+"{
            forLabel.text = "For: \(debate.forArguer)"
            againstLabel.text = "Against: \(debate.againstArguer)"
            if !debate.finished{
                clockTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
            }
        }else if debate.defender == ""{
            // user has declined
            forLabel.text = debate.forArguer == debate.challenger ? debate.forArguer: "User declined"
            againstLabel.text = debate.againstArguer == debate.challenger ? debate.againstArguer: "User declined"
        }else{
            // user has not decided
            forLabel.text = debate.forArguer == debate.challenger ? debate.forArguer: "Pending"
            againstLabel.text = debate.againstArguer == debate.challenger ? debate.againstArguer: "Pending"
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
        if !debate.finished{
            reloadTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "reload", userInfo: nil, repeats: true)
        }
    }
    func reload(){
            let query = PFQuery(className: "Debates")
            query.getObjectInBackgroundWithId(rawData.objectId!) { (object: PFObject?, error: NSError?) -> Void in
                self.rawData = object!
                self.debate = DebateClient.convert(object!)
                if self.debate.defender != "o+"{
                    self.forLabel.text = "For: \(self.debate.forArguer)"
                    self.againstLabel.text = "Against: \(self.debate.againstArguer)"
                    if !self.debate.finished && self.clockTimer == nil{
                        self.clockTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
                    }
                }else if self.debate.defender == ""{
                    self.forLabel.text = self.debate.forArguer == self.debate.challenger ? self.debate.forArguer: "User declined"
                    self.againstLabel.text = self.debate.againstArguer == self.debate.challenger ? self.debate.againstArguer: "User declined"
                }else{
                    // user has not decided
                    self.forLabel.text = self.debate.forArguer == self.debate.challenger ? self.debate.forArguer: "Pending"
                    self.againstLabel.text = self.debate.againstArguer == self.debate.challenger ? self.debate.againstArguer: "Pending"
                }
                self.tableView.reloadData()
                newData = false
            }
    }
    func makeClocksHidden(){
        if !debate.finished{
            if debate.arguments.count > 0{
                // if the last user to write an argument was the for arguer then make the forClock hidden
                forClock.hidden = debate.arguments[debate.arguments.count-1].componentsSeparatedByString(":")[0] ==
                debate.forArguer
                // if the last user to write an argument was the against arguer then make the against clock hidden
                againstClock.hidden = debate.arguments[debate.arguments.count-1].componentsSeparatedByString(":")[0] ==
                debate.againstArguer
            }else{
                // using ! so that if expression is true then make hidden false not true
                forClock.hidden = !(debate.challenger == debate.forArguer)
                againstClock.hidden = !(debate.challenger == debate.againstArguer)
            }
        }
    }
    func updateTimer(){
        if debate.finished!{
            reloadTimer.invalidate()
            clockTimer.invalidate()
            return
        }
        if debate.dateStarted == ""{
            forClock.hidden = true
            againstClock.hidden = true
            return
        }
        let dateFormatter1 = NSDateFormatter()
        dateFormatter1.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date1 = dateFormatter1.dateFromString(debate.inviteTimeStamp)
        // get time elapsed
        var secondsSinceInvite = Int(NSDate().timeIntervalSinceDate(date1!))
        // get the time left not elapsed
        // give 8 minutes for user to respond
        secondsSinceInvite = 480 - secondsSinceInvite
        if secondsSinceInvite <= 0 && debate.dateStarted == ""{
            debate.defender = ""
            debate.finished = true
            debate.winner = ""
            rawData.setObject("", forKey: defenderKey)
            rawData.setObject(true, forKey: finishedKey)
            rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
            rawData.saveInBackground()
        }
        // convert date string to NSDate form
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date = dateFormatter.dateFromString(debate.dateStarted)
        // get time elapsed
        currentSeconds = Int(NSDate().timeIntervalSinceDate(date!))
        // get the time left not elapsed
        currentSeconds = debate.minutesPerArgument*60 - currentSeconds
        makeClocksHidden()
        if !forClock.hidden{
            if turnFinished{
                forClock.hidden = true
                againstClock.hidden = false
                forClock.text = "0:00:00"
                turnFinished = false
            }
            if currentSeconds >= 0{
                if currentSeconds < 60{
                    forClock.text = "0:0:\(currentSeconds)"
                }else if currentSeconds < 3600{
                    forClock.text = "0:\(currentSeconds/60):\(currentSeconds%60)"
                }else if currentSeconds == 3600{
                    forClock.text = "1:00:00"
                }
            }else if currentSeconds < 0 && !debate.finished{
                forClock.hidden = true
                PFUser.currentUser()!.setObject(false, forKey: "inDebate")
                PFUser.currentUser()!.saveInBackground()
                PFUser.currentUser()!.fetchInBackground()
                // close the debate here
                debate.finished = true
                rawData.setObject(true, forKey: finishedKey)
                debate.winner = "\(debate.againstArguer) forfeited match! \(debate.forArguer) has won!"
                rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                rawData.saveInBackground()
                
                self.tableView.reloadData()
            }
            // if errors then remove !debate.finished!!!!!!!
            if debate.arguments.count > 1 && debate.arguments.count/2 >= debate.rebuttalRounds{
                // debate is over
                forClock.hidden = true
                againstClock.hidden = true
                PFUser.currentUser()!.setObject(false, forKey: "inDebate")
                PFUser.currentUser()!.saveInBackground()
                PFUser.currentUser()!.fetchInBackground()
                // close the debate here
                debate.finished = true
                rawData.setObject(true, forKey: finishedKey)
                debate.winner = "Debate is finished"
                rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                rawData.saveInBackground()
                
                self.tableView.reloadData()
            }
        }else{
            if turnFinished{
                forClock.hidden = false
                againstClock.hidden = true
                againstClock.text = "0:00:00"
                turnFinished = false
            }
            if currentSeconds >= 0{
                if currentSeconds < 60{
                    againstClock.text = "0:0:\(currentSeconds)"
                }else if currentSeconds < 3600{
                    againstClock.text = "0:\(currentSeconds/60):\(currentSeconds%60)"
                }else if currentSeconds == 3600{
                    againstClock.text = "1:00:00"
                }
            }else if currentSeconds < 0 && !debate.finished{
                againstClock.hidden = true
                PFUser.currentUser()?.setObject(false, forKey: "inDebate")
                PFUser.currentUser()?.saveInBackground()
                PFUser.currentUser()?.fetchInBackground()
                debate.finished = true
                rawData.setObject(true, forKey: finishedKey)
                debate.winner = "\(debate.againstArguer) forfeited match! \(debate.forArguer) has won!"
                rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                rawData.saveInBackground()
                
                self.tableView.reloadData()
            }
            // if errors then remove !debate.finished!!!!!!!
            if debate.arguments.count > 1 && debate.arguments.count/2 >= debate.rebuttalRounds{
                // debate is over
                againstClock.hidden = true
                PFUser.currentUser()!.setObject(false, forKey: "inDebate")
                PFUser.currentUser()!.saveInBackground()
                PFUser.currentUser()!.fetchInBackground()
                // close the debate here
                debate.finished = true
                rawData.setObject(true, forKey: finishedKey)
                debate.winner = "Debate is finished"
                rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                rawData.saveInBackground()
                
                self.tableView.reloadData()
            }
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debate.arguments.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("argumentCell") as! DebateManagerTableViewCell
        cell.userLabel.text = debate.arguments[indexPath.row].componentsSeparatedByString(":")[0]
        if debate.arguments[indexPath.row].componentsSeparatedByString(":").count > 1{
            cell.argumentLabel.text = debate.arguments[indexPath.row].componentsSeparatedByString(":")[1]
            print(cell.argumentLabel.text)
        }else{
            cell.argumentLabel.text = ""
        }
        return cell
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if debate.winner != ""{
            return debate.winner
        }
        return ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addArgument(sender: AnyObject) {
        
    }
    func errorHandling(){
        // make things go wrong
        if debate.dateStarted != ""{
            // convert date string to NSDate form
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let date = dateFormatter.dateFromString(debate.dateStarted)
            // get time elapsed
            currentSeconds = Int(NSDate().timeIntervalSinceDate(date!))
            // get the time left not elapsed
            currentSeconds = debate.minutesPerArgument*60 - currentSeconds
            if currentSeconds <= 0{
                let alert = UIAlertController(title: "Closed Debate", message: "This debate has ended because a user waited too long and forfeited a round.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            if debate.arguments.count > 0{
                if debate.arguments.count/2 >= debate.rebuttalRounds{
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(OKAction)
                    alert.title = "This debate is full!"
                    self.presentViewController(alert, animated: true, completion: nil)
                }else if debate.arguments[debate.arguments.count-1].componentsSeparatedByString(":")[0] == PFUser.currentUser()?.username{
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(OKAction)
                    alert.title = "Wait for your opponent to post their argument!"
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else if debate.challenger != PFUser.currentUser()!.username{
                let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(OKAction)
                alert.title = "Wait for your opponent to post their argument!"
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(OKAction)
            alert.title = "Wait for your opponent to accept the debate!"
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "newArgument"{
            rawData.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
                self.errorHandling()
            })
            if debate.arguments.count > 0 && debate.defender != ""{
                if debate.arguments[debate.arguments.count-1].componentsSeparatedByString(":")[0] == PFUser.currentUser()?.username || debate.arguments.count/2 >= debate.rebuttalRounds{
                    return false
                }
            }else if debate.challenger != PFUser.currentUser()!.username{
                return false
            }
            if debate.finished!{
                return false
            }
        }
        return true
    }
    override func viewWillDisappear(animated: Bool) {
        //PFInstallation.currentInstallation().removeObject(debate.title, forKey: "channels")
        //PFInstallation.currentInstallation().saveInBackground()
        if reloadTimer != nil{
            reloadTimer.invalidate()
            reloadTimer = nil
        }
        if clockTimer != nil{
            clockTimer.invalidate()
            clockTimer = nil
        }
    }
    @IBAction func report(sender: AnyObject) {
        let alert = UIAlertController(title: "Inappropriate Content or Spam", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Report", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            DebateClient.sendPush("\(self.debate.title) has been reported by \(PFUser.currentUser()!.username!) Dhruv!", username: "John Cena")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newArgument"{
            let nav = segue.destinationViewController as! UINavigationController
            let vc = nav.topViewController as! AddArgumentViewController
            vc.rawDebate = rawData
        }else if segue.identifier == "voteSegue"{
            let vc = segue.destinationViewController as! VoteViewController
            vc.rawData = rawData
            vc.debate = NSKeyedUnarchiver.unarchiveObjectWithData(rawData.objectForKey("Debate") as! NSData) as! Debate
        }
    }
}
