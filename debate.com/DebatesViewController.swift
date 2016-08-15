//
//  DebatesViewController.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/27/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
//import ARSLineProgress

var currentUser = PFUser.current()!
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
class DebatesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var loading = true
    var selectedDebate: Debate!
    var selectedRawData: PFObject!
    var inDebate = false
    let currentUsername = PFUser.current()!.username!
    var timer: Timer!
    var invitedDebates = [PFObject]()
    var blurEffectView: UIVisualEffectView!
    var menuButtonRep: UIBarButtonItem!
    var debateButton: UIButton!
    var pollButton: UIButton!
    var titleButton: UIButton!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    /*override func viewDidAppear(_ animated: Bool) {
        
        var debates = [Debate]()
        let privateQuery = PFQuery(className: "Private")
        let query = PFQuery(className: "Debates")
        var invites = [PFObject]()
        /*privateQuery.findObjectsInBackground { (data, error) -> Void in
            if data != nil{
                for i in data!{
                    let data = i["Debate"] as! Data
                    NSKeyedUnarchiver.setClass(Debate.self, forClassName: "debate_com.Debate")
                    let debate = NSKeyedUnarchiver.unarchiveObject(with: data) as! Debate
                    if debate.againstArguer == "" && debate.forArguer == "" && debate.arguments.contains(PFUser.current()!.username!){
                        debates.append(debate)
                    }
                }
            }
        }*/
        query.findObjectsInBackground { (data: [PFObject]?, error: NSError?) -> Void in
            if data != nil{
                self.inDebate = false
                numOfNot = 0
                print("data is being received\(data)")
                for i in data!{
                    let data = i["Debate"] as! Data
                    NSKeyedUnarchiver.setClass(Debate.self, forClassName: "debate_com.Debate")
                    let debate = NSKeyedUnarchiver.unarchiveObject(with: data) as! Debate
                    
                    debates.append(debate)
                    
                    if debate.forArguer != "" || debate.againstArguer != ""{
                        print(debate.forArguer)
                        print("\(debate.againstArguer) dddd")
                        let dateFormatter1 = DateFormatter()
                        dateFormatter1.dateFormat = "MM-dd-yyyy HH:mm:ss"
                        let date1 = dateFormatter1.date(from: debate.inviteTimeStamp)
                        // get time elapsed
                        var secondsSinceInvite = Int(Date().timeIntervalSince(date1!))
                        // get the time left not elapsed
                        // give 8 minutes for user to respond
                        secondsSinceInvite = 480 - secondsSinceInvite
                        
                        // user has already accepted the debate
                        if debate.dateStarted != ""{
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                            let date = dateFormatter.date(from: debate.dateStarted)
                            var currentSeconds = Int(Date().timeIntervalSince(date!))
                            currentSeconds = debate.minutesPerArgument*60 - currentSeconds
                            
                            if self.currentUsername == debate.defender || self.currentUsername == debate.challenger{
                                
                                // if the debate is not finished but in reality it is
                                if currentSeconds < 0 && !debate.finished{
                                    debate.finished = true
                                    i.setObject(true, forKey: finishedKey)
                                    i["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
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
                            i["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                            i.saveInBackground()
                        }
                        
                        if (debate.defender == "o+" || debate.defender == PFUser.current()!.username!) && debate.challenger != PFUser.current()!.username! && secondsSinceInvite > 5 && !refusedDebates.contains(debate.title){
                            invites.append(i)
                        }
                    }
                }
                rawDebates = data!.reversed()
                debatesMain = debates.reversed()
                
                print("save is complete")
                self.invitedDebates = invites
                isLoading = true
                self.tableView.reloadData()
                if self.timer != nil{
                    self.timer.invalidate()
                    self.timer = nil
                }
                self.timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.reload), userInfo: nil, repeats: true)
            currentUser.setObject(self.inDebate, forKey: "inDebate")
            currentUser.saveInBackground({ (success: Bool, error: NSError?) -> Void in
                currentUser.fetchInBackground()
                
            })
            }else{
                print(error?.localizedDescription)
            }
            //self.navigationItem.leftBarButtonItem?.badgeValue = "\(numOfNot)"
            self.showInvitation()
        }
    }*/
    
    func create(){
        if blurEffectView.isHidden == false{
            navigationItem.setRightBarButton(nil, animated: true)
            navigationItem.setLeftBarButton(menuButtonRep, animated: true)
            UIView.transition(with: blurEffectView, duration: 0.15, options: UIViewAnimationOptions.transitionCrossDissolve, animations: nil, completion: nil)
            blurEffectView.isHidden = true
            debateButton.removeFromSuperview()
            pollButton.removeFromSuperview()
            return
        }
        UIView.transition(with: blurEffectView, duration: 0.15, options: UIViewAnimationOptions.transitionCrossDissolve, animations: nil, completion: nil)
        blurEffectView.isHidden = false
        debateButton.setTitle("Debate", for: UIControlState())
        debateButton.addTarget(self, action: #selector(self.createDebate), for: UIControlEvents.touchUpInside)
        debateButton.isUserInteractionEnabled = true
        view.addSubview(debateButton)
        pollButton.setTitle("Poll", for: UIControlState())
        pollButton.addTarget(self, action: #selector(self.createPoll), for: UIControlEvents.touchUpInside)
        pollButton.isUserInteractionEnabled = true
        view.addSubview(pollButton)
    }
    func createDebate(){
        self.performSegue(withIdentifier: "toCreate", sender: self)
    }
    func createPoll(){
        self.performSegue(withIdentifier: "newPoll", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        titleButton = UIButton(type: UIButtonType.roundedRect)
        titleButton.frame = CGRect(x: 0, y: 0, width: 90, height: 36)
        titleButton.layer.cornerRadius = 6
        titleButton.layer.borderColor = UIColor.orange().cgColor
        titleButton.layer.borderWidth = 0.4
        titleButton.setTitleColor(UIColor.white(), for: UIControlState())
        titleButton.layer.backgroundColor = UIColor.orange().cgColor
        titleButton.setTitle("Create", for: UIControlState())
        titleButton.addTarget(self, action: #selector(self.create), for: .touchUpInside)
        self.navigationItem.titleView? = titleButton

        debateButton = UIButton(frame: CGRect(x: titleButton.center.x+50, y: 50, width: 65, height: 65))
        pollButton = UIButton(frame: CGRect(x: view.frame.size.width/2+20, y: 50, width: 65, height: 65))
        
        if self.revealViewController() != nil {
            //self.navigationItem.leftBarButtonItem?.badgeValue = "\(numOfNot)"
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            menuButtonRep = menuButton
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clear()
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.isHidden = true
            self.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        }
        else {
            self.view.backgroundColor = UIColor.black()
        }
        //var debates = [Debate]()
        //let query = PFQuery(className: "Debates")
        //let privateQuery = PFQuery(className: "Private")
        /*privateQuery.findObjectsInBackground { (data, error) -> Void in
            if data != nil{
                for i in data!{
                    let data = i["Debate"] as! NSData
                    NSKeyedUnarchiver.setClass(Debate.self, forClassName: "debate_com.Debate")
                    let debate = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! Debate
                    if debate.againstArguer == "" && debate.forArguer == "" && debate.arguments.contains(PFUser.current()!.username!){
                        debates.append(debate)
                    }
                }
            }
        }
         */
        /*query.findObjectsInBackground { (datas: [PFObject]?, error: NSError?) -> Void in
            if datas != nil{
                self.inDebate = false
                for i in datas!{
                    let data = i["Debate"] as! NSData
                    NSKeyedUnarchiver.setClass(Debate.self, forClassName: "debate_com.Debate")
                    let debate = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! Debate
                    debates.append(debate)
                    
                    if debate.forArguer != "" || debate.againstArguer != ""{
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                        let date = dateFormatter.date(from: debate.inviteTimeStamp)
                        // get time elapsed
                        var secondsSinceInvite = Int(NSDate().timeIntervalSince(date!))
                        // get the time left not elapsed
                        // give 8 minutes for user to respond
                        secondsSinceInvite = 480 - secondsSinceInvite
                        
                        // user has already accepted the debate
                        if debate.dateStarted != ""{
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                            let date = dateFormatter.date(from: debate.dateStarted)
                            var currentSeconds = Int(NSDate().timeIntervalSince(date!))
                            currentSeconds = debate.minutesPerArgument*60 - currentSeconds
                            
                            if self.currentUsername == debate.defender || self.currentUsername == debate.challenger{
                                
                                // if the debate is not finished but in reality it is
                                if currentSeconds < 0 && !debate.finished{
                                    i.setObject(true, forKey: finishedKey)
                                    debate.finished = true
                                    i["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
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
                            i["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                            i.saveInBackground()
                        }
                        
                }
                currentUser.setObject(self.inDebate, forKey: "inDebate")
                currentUser.saveInBackground({ (success: Bool, error: NSError?) -> Void in
                    currentUser.fetchInBackground()
                    rawDebates = datas!.reversed()
                    debatesMain = debates.reversed()
                    isLoading = true
                    self.tableView.reloadData()
                    self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.reload), userInfo: nil, repeats: true)
                })
                }
            }else{
                print(error?.localizedDescription)
            }
            self.showInvitation()
        }*/
        //ARSLineProgress
        self.reload()
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.reload), userInfo: nil, repeats: true)
    }
    func reload(){
        var debates = [Debate]()
        var invites = [PFObject]()
        let query = PFQuery(className: "Debates")
        let privateQuery = PFQuery(className: "Private")
        /*privateQuery.findObjectsInBackground { (data, error) -> Void in
            if data != nil{
                for i in data!{
                    let data = i["Debate"] as! Data
                    NSKeyedUnarchiver.setClass(Debate.self, forClassName: "debate_com.Debate")
                    let debate = NSKeyedUnarchiver.unarchiveObject(with: data) as! Debate
                    if debate.againstArguer == "" && debate.forArguer == "" && debate.arguments.contains(PFUser.current()!.username!){
                        debates.append(debate)
                    }
                }
            }
        }
         */
        query.findObjectsInBackground { (data: [PFObject]?, error: NSError?) -> Void in
            if data != nil{
                numOfNot = 0
                self.inDebate = false
                for i in data!{
                    
                    let data = i["Debate"] as! Data
                    NSKeyedUnarchiver.setClass(Debate.self, forClassName: "debate_com.Debate")
                    let debate = NSKeyedUnarchiver.unarchiveObject(with: data) as! Debate
                    debates.append(debate)
                    
                    if debate.forArguer != "" || debate.againstArguer != ""{
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                    let date = dateFormatter.date(from: debate.inviteTimeStamp)
                    // get time elapsed
                    var secondsSinceInvite = Int(Date().timeIntervalSince(date!))
                    // get the time left not elapsed
                    // give 8 minutes for user to respond
                    secondsSinceInvite = 480 - secondsSinceInvite
                    
                    // user has already accepted the debate
                    if debate.dateStarted != ""{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                        let date = dateFormatter.date(from: debate.dateStarted)
                        var currentSeconds = Int(Date().timeIntervalSince(date!))
                        currentSeconds = debate.minutesPerArgument*60 - currentSeconds
                        
                        if self.currentUsername == debate.defender || self.currentUsername == debate.challenger{
                            
                            // if the debate is not finished but in reality it is
                            if currentSeconds < 0 && !debate.finished{
                                debate.finished = true
                                i.setObject(true, forKey: finishedKey)
                                i["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
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
                        i["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                        i.saveInBackground()
                    }
                    
                    if (debate.defender == "o+" || debate.defender == PFUser.current()!.username!) && debate.challenger != PFUser.current()!.username! && secondsSinceInvite > 5 && !refusedDebates.contains(debate.title){
                        invites.append(i)
                    }
                }
                }
                self.invitedDebates = invites
                rawDebates = data!.reversed()
                debatesMain = debates.reversed()
                isLoading = true
                currentUser.setObject(self.inDebate, forKey: "inDebate")
                currentUser.saveInBackground({ (success: Bool, error: NSError?) -> Void in
                    currentUser.fetchInBackground()
                    
                    self.tableView.reloadData()
                })
                }else{
                print(error?.localizedDescription)
            }
            //self.navigationItem.leftBarButtonItem?.badgeValue = "\(numOfNot)"
            self.showInvitation()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDebate = debatesMain[(indexPath as NSIndexPath).row]
        selectedRawData = rawDebates[(indexPath as NSIndexPath).row]
        
        let query = PFQuery(className: "Views")
        query.whereKey("debateObjectID", equalTo: selectedRawData.objectId!)
        query.findObjectsInBackground { (objects, error) -> Void in
            var viewObjectArray = objects!
            func view() {
                let object = viewObjectArray[0]
                var viewers = object["viewers"] as? [String]
                if viewers == nil{
                    viewers = []
                }
                if !viewers!.contains(PFUser.current()!.username!){
                    viewers!.append(PFUser.current()!.username!)
                    object.setObject(viewers!, forKey: "viewers")
                    object.saveInBackground({ (success, error) -> Void in
                        if self.selectedDebate.forArguer != "" || self.selectedDebate.againstArguer != ""{
                            self.performSegue(withIdentifier: "fromDebates", sender: self)
                        }else{
                            self.performSegue(withIdentifier: "pollSeg", sender: self)
                        }
                    })
                }else{
                    if self.selectedDebate.forArguer != "" || self.selectedDebate.againstArguer != ""{
                        self.performSegue(withIdentifier: "fromDebates", sender: self)
                    }else{
                        self.performSegue(withIdentifier: "pollSeg", sender: self)
                    }
                }
            }
            
            if viewObjectArray.count == 0{
                let viewObject = PFObject(className: "Views")
                viewObject["viewers"] = [String]()
                viewObject["debateObjectID"] = self.selectedRawData.objectId
                viewObject.saveInBackground({ (success, error) in
                    viewObjectArray.append(viewObject)
                    view()
                })
            }else{
                view()
            }
        }
        
    }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(debatesMain[0].title)
        return debatesMain.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebateCell", for: indexPath) as! DebateCell
        //cell.layer.borderColor = UIColor.clearColor().CGColor
        let debate = debatesMain[(indexPath as NSIndexPath).row]
        if debate.challenger != ""{
            let query = PFQuery(className: "Views")
            query.whereKey("debateObjectID", equalTo: rawDebates[(indexPath as NSIndexPath).row].objectId!)
            query.findObjectsInBackground({ (objects, error) -> Void in
                if objects?.count > 0{
                    let viewers = objects?[0].object(forKey: "viewers") as? [String]
                    cell.data.text = "Views: \(viewers?.count != nil ? debate.viewers.count : 0) · Comments: \(debate.comments.count) · Votes: \(debate.forVotes + debate.againstVotes)"
                }else{
                    cell.data.text = "Data Not Available"
                }
            })
        }else{
            if debate.forVotes != 0 || debate.againstVotes != 0{
                if debate.forVotes > debate.againstVotes{
                    cell.data.text = "\((debate.forVotes * 100) / (debate.forVotes + debate.againstVotes))% \(debate.title.components(separatedBy: ":")[0])"
                }else if debate.forVotes < debate.againstVotes{
                    cell.data.text = "\((debate.againstVotes * 100) / (debate.forVotes + debate.againstVotes))% \(debate.title.components(separatedBy: ":")[1])"
                }else if debate.againstVotes == debate.forVotes{
                    cell.data.text = "50% \(debate.title.components(separatedBy: ":")[0])"
                }
            }
        }
        print(debate.category)
        switch debate.category{
        case categoryArray[0]:
            cell.debateImage.image = #imageLiteral(resourceName: "economy")
        case categoryArray[1]:
            cell.debateImage.image = #imageLiteral(resourceName: "education")
        case categoryArray[2]:
            cell.debateImage.image = #imageLiteral(resourceName: "environment")
        case categoryArray[3]:
            cell.debateImage.image = #imageLiteral(resourceName: "space")
        case categoryArray[4]:
            cell.debateImage.image = #imageLiteral(resourceName: "health")
        case categoryArray[5]:
            cell.debateImage.image = #imageLiteral(resourceName: "history")
        case categoryArray[6]:
            cell.debateImage.image = #imageLiteral(resourceName: "language")
        case categoryArray[7]:
            cell.debateImage.image = #imageLiteral(resourceName: "law")
        case categoryArray[8]:
            cell.debateImage.image = #imageLiteral(resourceName: "politics")
        case categoryArray[9]:
            cell.debateImage.image = #imageLiteral(resourceName: "religion")
        case categoryArray[10]:
            cell.debateImage.image = #imageLiteral(resourceName: "science")
        default:
            break;
        }
        cell.name.text = debate.title
        return cell
    }
    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
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
            NSKeyedUnarchiver.setClass(Debate.self, forClassName: "debate_com.Debate")
            let debate = NSKeyedUnarchiver.unarchiveObject(with: invitedDebates[0].object(forKey: "Debate") as! Data) as! Debate
            let i = invitedDebates[0]
            let alert = UIAlertController(title: "Invitation to Debate", message: "\(debate.challenger) has invited you to the \(debate.title) debate!", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                PFUser.current()!.setObject(true, forKey: "inDebate")
                PFUser.current()!.saveInBackground()
                PFUser.current()!.fetchInBackground()
                debate.defender = "\(PFUser.current()!.username!)-"
                if debate.forArguer == "o+"{
                    debate.forArguer = "\(PFUser.current()!.username!)-"
                }else if debate.againstArguer == "o+"{
                    debate.againstArguer = "\(PFUser.current()!.username!)-"
                }else if debate.forArguer == PFUser.current()!.username!{
                    debate.forArguer = "\(PFUser.current()!.username!)-"
                }else if debate.againstArguer == PFUser.current()!.username!{
                    debate.againstArguer = "\(PFUser.current()!.username!)-"
                }
                i.setObject(debate.defender, forKey: defenderKey)
                let dateFormatter:DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                let dateInFormat:String = dateFormatter.string(from: Date())
                debate.dateStarted = dateInFormat
                i.setObject(dateInFormat, forKey: dateStartedKey)
                i["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                i.saveInBackground({ (success, error) -> Void in
                    DebateClient.sendPush("\(debate.defender) has accepted your debate \(debate.title))", username: debate.challenger)
                })
            })
            let declineAction = UIAlertAction(title: "Decline", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                PFUser.current()!.setObject(false, forKey: "inDebate")
                PFUser.current()!.saveInBackground()
                PFUser.current()!.fetchInBackground()
                self.invitedDebates.remove(at: 0)
                self.showInvitation()
                refusedDebates.append(debate.title)
            })
            alert.addAction(declineAction)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func chat(_ sender: AnyObject) {
        let controller = GroupsViewController()
        self.show(controller, sender: self)
    }
}
