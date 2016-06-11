//
//  DebatesViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/27/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
var currentUser = PFUser.currentUser()!
var inviteTimeStampKey = "inviteTimeStamp"
var dateStartedKey = "dateStarted"
var minutesPerArgumentKey = "minutesPerArgumentKey"
var defenderKey = "defender"
var challengerKey = "challenger"
var finishedKey = "finished"
var winnerKey = "winner"
var forArguerKey = "forArguer"
var againstArguerKey = "againstArguer"
var numOfNot = 0
var refusedDebates: [String] = [String]()
class DebatesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var loading = true
    var selectedDebate: Debate!
    var selectedRawData: PFObject!
    var inDebate = false
    let currentUsername = PFUser.currentUser()!.username!
    var timer: NSTimer!
    var invitedDebates = [PFObject]()
    var blurEffectView: UIVisualEffectView!
    var menuButtonRep: UIBarButtonItem!
    var debateButton: UIButton!
    var pollButton: UIButton!
    var titleButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidAppear(animated: Bool) {
        
        var debates = [Debate]()
        let privateQuery = PFQuery(className: "Private")
        let query = PFQuery(className: "Debates")
        var invites = [PFObject]()
        privateQuery.findObjectsInBackgroundWithBlock { (data, error) -> Void in
            if data != nil{
                for i in data!{
                    let data = i["Debate"] as! NSData
                    let debate = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Debate
                    if debate.againstArguer == "" && debate.forArguer == "" && debate.arguments.contains(PFUser.currentUser()!.username!){
                        debates.append(debate)
                    }
                }
            }
        }
        query.findObjectsInBackgroundWithBlock { (data: [PFObject]?, error: NSError?) -> Void in
            if data != nil{
                self.inDebate = false
                numOfNot = 0
                for i in data!{
                    let data = i["Debate"] as! NSData
                    let debate = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Debate
                    
                    debates.append(debate)
                    
                    if debate.forArguer != "" || debate.againstArguer != ""{
                        let dateFormatter1 = NSDateFormatter()
                        dateFormatter1.dateFormat = "MM-dd-yyyy HH:mm:ss"
                        let date1 = dateFormatter1.dateFromString(debate.inviteTimeStamp)
                        // get time elapsed
                        var secondsSinceInvite = Int(NSDate().timeIntervalSinceDate(date1!))
                        // get the time left not elapsed
                        // give 8 minutes for user to respond
                        secondsSinceInvite = 480 - secondsSinceInvite
                        
                        // user has already accepted the debate
                        if debate.dateStarted != ""{
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                            let date = dateFormatter.dateFromString(debate.dateStarted)
                            var currentSeconds = Int(NSDate().timeIntervalSinceDate(date!))
                            currentSeconds = debate.minutesPerArgument*60 - currentSeconds
                            
                            if self.currentUsername == debate.defender || self.currentUsername == debate.challenger{
                                
                                // if the debate is not finished but in reality it is
                                if currentSeconds < 0 && !debate.finished{
                                    debate.finished = true
                                    i.setObject(true, forKey: finishedKey)
                                    i["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                                    i.saveInBackground()
                                // else if the debate is actually not finished
                                }else if currentSeconds > 0 && !debate.finished{
                                    self.inDebate = true
                                }
                            }
                        // user has not accepted the debate yet and time has not run out
                        }else if self.currentUsername == debate.challenger && debate.defender != ""{
                            self.inDebate = true
                        }
                        if secondsSinceInvite <= 0 && (debate.challenger == self.currentUsername || debate.defender == self.currentUsername) && debate.dateStarted == ""{
                            debate.defender = ""
                            debate.finished = true
                            i.setObject(true, forKey: finishedKey)
                            i.setObject("", forKey: defenderKey)
                            i["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                            i.saveInBackground()
                        }
                        
                        if (debate.defender == "o+" || debate.defender == PFUser.currentUser()!.username!) && debate.challenger != PFUser.currentUser()!.username! && secondsSinceInvite > 5 && !refusedDebates.contains(debate.title){
                            invites.append(i)
                        }
                    }
                }
            currentUser.setObject(self.inDebate, forKey: "inDebate")
            currentUser.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                currentUser.fetchInBackground()
                rawDebates = data!.reverse()
                debatesMain = debates.reverse()
                self.invitedDebates = invites
                isLoading = true
                self.collectionView.reloadData()
                if self.timer != nil{
                    self.timer.invalidate()
                    self.timer = nil
                }
                self.timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "reload", userInfo: nil, repeats: true)
            })
            }else{
                print(error?.localizedDescription)
            }
            //self.navigationItem.leftBarButtonItem?.badgeValue = "\(numOfNot)"
            
            self.showInvitation()
        }
    }
    func create(){
        if blurEffectView.hidden == false{
            navigationItem.setRightBarButtonItem(nil, animated: true)
            navigationItem.setLeftBarButtonItem(menuButtonRep, animated: true)
            UIView.transitionWithView(blurEffectView, duration: 0.15, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
            blurEffectView.hidden = true
            debateButton.removeFromSuperview()
            pollButton.removeFromSuperview()
            return
        }
        UIView.transitionWithView(blurEffectView, duration: 0.15, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: nil, completion: nil)
        blurEffectView.hidden = false
        debateButton.setTitle("Debate", forState: UIControlState.Normal)
        debateButton.addTarget(self, action: "createDebate", forControlEvents: UIControlEvents.TouchUpInside)
        debateButton.userInteractionEnabled = true
        view.addSubview(debateButton)
        pollButton.setTitle("Poll", forState: UIControlState.Normal)
        pollButton.addTarget(self, action: "createPoll", forControlEvents: UIControlEvents.TouchUpInside)
        pollButton.userInteractionEnabled = true
        view.addSubview(pollButton)
    }
    func createDebate(){
        self.performSegueWithIdentifier("toCreate", sender: self)
    }
    func createPoll(){
        self.performSegueWithIdentifier("newPoll", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        titleButton = UIButton(type: UIButtonType.RoundedRect)
        titleButton.frame = CGRectMake(0, 0, 90, 36)
        titleButton.layer.cornerRadius = 6
        titleButton.layer.borderColor = UIColor.orangeColor().CGColor
        titleButton.layer.borderWidth = 0.4
        titleButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        titleButton.layer.backgroundColor = UIColor.orangeColor().CGColor
        titleButton.setTitle("Create", forState: UIControlState.Normal)
        titleButton.addTarget(self, action: "create", forControlEvents: .TouchUpInside)
        self.navigationItem.titleView? = titleButton

        debateButton = UIButton(frame: CGRectMake(titleButton.center.x+50, 50, 65, 65))
        pollButton = UIButton(frame: CGRectMake(view.frame.size.width/2+20, 50, 65, 65))
        
        if self.revealViewController() != nil {
            //self.navigationItem.leftBarButtonItem?.badgeValue = "\(numOfNot)"
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            menuButtonRep = menuButton
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            blurEffectView.hidden = true
            self.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        }
        else {
            self.view.backgroundColor = UIColor.blackColor()
        }
        var debates = [Debate]()
        let query = PFQuery(className: "Debates")
        let privateQuery = PFQuery(className: "Private")
        privateQuery.findObjectsInBackgroundWithBlock { (data, error) -> Void in
            if data != nil{
                for i in data!{
                    let data = i["Debate"] as! NSData
                    let debate = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Debate
                    if debate.againstArguer == "" && debate.forArguer == "" && debate.arguments.contains(PFUser.currentUser()!.username!){
                        debates.append(debate)
                    }
                }
            }
        }

        query.findObjectsInBackgroundWithBlock { (datas: [PFObject]?, error: NSError?) -> Void in
            if datas != nil{
                self.inDebate = false
                for i in datas!{
                    let data = i["Debate"] as! NSData
                    let debate = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Debate
                    debates.append(debate)
                    
                    if debate.forArguer != "" || debate.againstArguer != ""{
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                        let date = dateFormatter.dateFromString(debate.inviteTimeStamp)
                        // get time elapsed
                        var secondsSinceInvite = Int(NSDate().timeIntervalSinceDate(date!))
                        // get the time left not elapsed
                        // give 8 minutes for user to respond
                        secondsSinceInvite = 480 - secondsSinceInvite
                        
                        // user has already accepted the debate
                        if debate.dateStarted != ""{
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                            let date = dateFormatter.dateFromString(debate.dateStarted)
                            var currentSeconds = Int(NSDate().timeIntervalSinceDate(date!))
                            currentSeconds = debate.minutesPerArgument*60 - currentSeconds
                            
                            if self.currentUsername == debate.defender || self.currentUsername == debate.challenger{
                                
                                // if the debate is not finished but in reality it is
                                if currentSeconds < 0 && !debate.finished{
                                    i.setObject(true, forKey: finishedKey)
                                    debate.finished = true
                                    i["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                                    i.saveInBackground()
                                    // else if the debate is actually not finished
                                }else if currentSeconds > 0 && !debate.finished{
                                    self.inDebate = true
                                }
                            }
                            // user has not accepted the debate yet
                        }else if self.currentUsername == debate.challenger && debate.defender != ""{
                            self.inDebate = true
                        }
                        if secondsSinceInvite <= 0 && (debate.challenger == self.currentUsername || debate.defender == self.currentUsername) && debate.dateStarted == ""{
                            debate.defender = ""
                            debate.finished = true
                            i.setObject("", forKey: defenderKey)
                            i.setObject(true, forKey: finishedKey)
                            i["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                            i.saveInBackground()
                        }
                        
                }
                currentUser.setObject(self.inDebate, forKey: "inDebate")
                currentUser.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    currentUser.fetchInBackground()
                    rawDebates = datas!.reverse()
                    debatesMain = debates.reverse()
                    isLoading = true
                    self.collectionView.reloadData()
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "reload", userInfo: nil, repeats: true)
                })
                }
            }else{
                print(error?.localizedDescription)
            }
            self.showInvitation()
        }
    }
    func reload(){
        var debates = [Debate]()
        var invites = [PFObject]()
        let query = PFQuery(className: "Debates")
        let privateQuery = PFQuery(className: "Private")
        privateQuery.findObjectsInBackgroundWithBlock { (data, error) -> Void in
            if data != nil{
                for i in data!{
                    let data = i["Debate"] as! NSData
                    let debate = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Debate
                    if debate.againstArguer == "" && debate.forArguer == "" && debate.arguments.contains(PFUser.currentUser()!.username!){
                        debates.append(debate)
                    }
                }
            }
        }

        query.findObjectsInBackgroundWithBlock { (data: [PFObject]?, error: NSError?) -> Void in
            if data != nil{
                numOfNot = 0
                self.inDebate = false
                for i in data!{
                    
                    let data = i["Debate"] as! NSData
                    let debate = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Debate
                    debates.append(debate)
                    
                    if debate.forArguer != "" || debate.againstArguer != ""{
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                    let date = dateFormatter.dateFromString(debate.inviteTimeStamp)
                    // get time elapsed
                    var secondsSinceInvite = Int(NSDate().timeIntervalSinceDate(date!))
                    // get the time left not elapsed
                    // give 8 minutes for user to respond
                    secondsSinceInvite = 480 - secondsSinceInvite
                    
                    // user has already accepted the debate
                    if debate.dateStarted != ""{
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                        let date = dateFormatter.dateFromString(debate.dateStarted)
                        var currentSeconds = Int(NSDate().timeIntervalSinceDate(date!))
                        currentSeconds = debate.minutesPerArgument*60 - currentSeconds
                        
                        if self.currentUsername == debate.defender || self.currentUsername == debate.challenger{
                            
                            // if the debate is not finished but in reality it is
                            if currentSeconds < 0 && !debate.finished{
                                debate.finished = true
                                i.setObject(true, forKey: finishedKey)
                                i["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                                i.saveInBackground()
                                // else if the debate is actually not finished
                            }else if currentSeconds > 0 && !debate.finished{
                                self.inDebate = true
                            }
                        }
                        // user has not accepted the debate yet
                    }else if self.currentUsername == debate.challenger && debate.defender != ""{
                        self.inDebate = true
                    }
                    if secondsSinceInvite <= 0 && (debate.challenger == self.currentUsername || debate.defender == self.currentUsername) && debate.dateStarted == ""{
                        debate.defender = ""
                        debate.finished = true
                        i.setObject(true, forKey: finishedKey)
                        i.setObject("", forKey: defenderKey)
                        i["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                        i.saveInBackground()
                    }
                    
                    if (debate.defender == "o+" || debate.defender == PFUser.currentUser()!.username!) && debate.challenger != PFUser.currentUser()!.username! && secondsSinceInvite > 5 && !refusedDebates.contains(debate.title){
                        invites.append(i)
                    }
                }
                }
                self.invitedDebates = invites
                rawDebates = data!.reverse()
                debatesMain = debates.reverse()
                isLoading = true
                currentUser.setObject(self.inDebate, forKey: "inDebate")
                currentUser.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    currentUser.fetchInBackground()
                    self.collectionView.reloadData()
                })
                }else{
                print(error?.localizedDescription)
            }
            //self.navigationItem.leftBarButtonItem?.badgeValue = "\(numOfNot)"
            self.showInvitation()
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedDebate = debatesMain[indexPath.row]
        selectedRawData = rawDebates[indexPath.row]
        let query = PFQuery(className: "Views")
        query.whereKey("debateObjectID", equalTo: selectedRawData.objectId!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            let object = objects![0]
            var viewers = object["viewers"] as? [String]
            if viewers == nil{
                viewers = []
            }
            if !viewers!.contains(PFUser.currentUser()!.username!){
                viewers!.append(PFUser.currentUser()!.username!)
                object.setObject(viewers!, forKey: "viewers")
                object.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if self.selectedDebate.forArguer != "" || self.selectedDebate.againstArguer != ""{
                        self.performSegueWithIdentifier("fromDebates", sender: self)
                    }else{
                        self.performSegueWithIdentifier("pollSeg", sender: self)
                    }
                })
            }else{
                if self.selectedDebate.forArguer != "" || self.selectedDebate.againstArguer != ""{
                    self.performSegueWithIdentifier("fromDebates", sender: self)
                }else{
                    self.performSegueWithIdentifier("pollSeg", sender: self)
                }
            }
        }
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return debatesMain.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("debateCell", forIndexPath: indexPath) as! DebateCollectionViewCell
        cell.layer.borderColor = UIColor.clearColor().CGColor
        let debate = debatesMain[indexPath.row]
        if debate.challenger != ""{
            let query = PFQuery(className: "Views")
            query.whereKey("debateObjectID", equalTo: rawDebates[indexPath.row].objectId!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                let viewers = objects?[0].objectForKey("viewers") as? [String]
                cell.data.text = "Views: \(viewers?.count != nil ? debate.viewers.count : 0) · Comments: \(debate.comments.count) · Votes: \(debate.forVotes + debate.againstVotes)"
            })
        }else{
            if debate.forVotes != 0 || debate.againstVotes != 0{
                if debate.forVotes > debate.againstVotes{
                    cell.data.text = "\((debate.forVotes * 100) / (debate.forVotes + debate.againstVotes))% \(debate.title.componentsSeparatedByString(":")[0])"
                }else if debate.forVotes < debate.againstVotes{
                    cell.data.text = "\((debate.againstVotes * 100) / (debate.forVotes + debate.againstVotes))% \(debate.title.componentsSeparatedByString(":")[1])"
                }else if debate.againstVotes == debate.forVotes{
                    cell.data.text = "50% \(debate.title.componentsSeparatedByString(":")[0])"
                }
            }
        }
        print(debate.category)
        switch debate.category{
        case categoryArray[0]:
            cell.image.image = UIImage(named: "economy")
        case categoryArray[1]:
            cell.image.image = UIImage(named: "education")
        case categoryArray[2]:
            cell.image.image = UIImage(named: "environment")
        case categoryArray[3]:
            cell.image.image = UIImage(named: "space")
        case categoryArray[4]:
            cell.image.image = UIImage(named: "health")
        case categoryArray[5]:
            cell.image.image = UIImage(named: "history")
        case categoryArray[6]:
            cell.image.image = UIImage(named: "language")
        case categoryArray[7]:
            cell.image.image = UIImage(named: "law")
        case categoryArray[8]:
            cell.image.image = UIImage(named: "politics")
        case categoryArray[9]:
            cell.image.image = UIImage(named: "religion")
        case categoryArray[10]:
            cell.image.image = UIImage(named: "science")
        default:
            break;
        }
        cell.name.text = debate.title
        return cell
    }
    override func viewWillDisappear(animated: Bool) {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromDebates"{
            // go to different vcs based on different actions
            let vc = segue.destinationViewController as! DebateManagerViewController
            vc.debate = selectedDebate
            vc.rawData = selectedRawData
        }else if segue.identifier == "pollSeg"{
            let vc = segue.destinationViewController as! VoteViewController
            vc.debate = selectedDebate
            vc.rawData = selectedRawData
        }
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
    func showInvitation(){
        if invitedDebates.count > 0{
            let debate = NSKeyedUnarchiver.unarchiveObjectWithData(invitedDebates[0].objectForKey("Debate") as! NSData) as! Debate
            let i = invitedDebates[0]
            let alert = UIAlertController(title: "Invitation to Debate", message: "\(debate.challenger) has invited you to the \(debate.title) debate!", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                PFUser.currentUser()!.setObject(true, forKey: "inDebate")
                PFUser.currentUser()!.saveInBackground()
                PFUser.currentUser()!.fetchInBackground()
                debate.defender = "\(PFUser.currentUser()!.username!)-"
                if debate.forArguer == "o+"{
                    debate.forArguer = "\(PFUser.currentUser()!.username!)-"
                }else if debate.againstArguer == "o+"{
                    debate.againstArguer = "\(PFUser.currentUser()!.username!)-"
                }else if debate.forArguer == PFUser.currentUser()!.username!{
                    debate.forArguer = "\(PFUser.currentUser()!.username!)-"
                }else if debate.againstArguer == PFUser.currentUser()!.username!{
                    debate.againstArguer = "\(PFUser.currentUser()!.username!)-"
                }
                i.setObject(debate.defender, forKey: defenderKey)
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                let dateInFormat:String = dateFormatter.stringFromDate(NSDate())
                debate.dateStarted = dateInFormat
                i.setObject(dateInFormat, forKey: dateStartedKey)
                i["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
                i.saveInBackgroundWithBlock({ (success, error) -> Void in
                    DebateClient.sendPush("\(debate.defender) has accepted your debate \(debate.title))", username: debate.challenger)
                })
            })
            let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                PFUser.currentUser()!.setObject(false, forKey: "inDebate")
                PFUser.currentUser()!.saveInBackground()
                PFUser.currentUser()!.fetchInBackground()
                self.invitedDebates.removeAtIndex(0)
                self.showInvitation()
                refusedDebates.append(debate.title)
            })
            alert.addAction(declineAction)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    @IBAction func chat(sender: AnyObject) {
        let controller = GroupsViewController()
        self.showViewController(controller, sender: self)
    }
}
