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
    //@IBOutlet weak var forClock: UILabel!
    @IBOutlet weak var addArgumentButton: UIButton!
    @IBOutlet weak var againstLabel: UILabel!
    @IBOutlet weak var forLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var againstClock: UILabel!
    var debate: Debate!
    var rawData: PFObject!
    var myDebate = false
    var currentSeconds = 0
    var reloadTimer: Timer!
    var clockTimer: Timer!
    override func viewDidAppear(_ animated: Bool) {
        //PFInstallation.currentInstallation().addUniqueObject(debate.title, forKey: "channels")
        //PFInstallation.currentInstallation().saveInBackground()
        if debate.forArguer == PFUser.current()!.username || debate.againstArguer == PFUser.current()!.username{
            myDebate = true
            print("yo")
            addArgumentButton.isHidden = false
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
                clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
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
            reloadTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.reload), userInfo: nil, repeats: true)
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        makeClocksHidden()
        //debate.comments = []
        //rawData["Debate"] = NSKeyedArchiver.archivedDataWithRootObject(debate)
        //rawData.saveInBackground()
        if debate.forArguer.replacingOccurrences(of: "-", with: "") == PFUser.current()!.username || debate.againstArguer.replacingOccurrences(of: "-", with: "") == PFUser.current()!.username{
            myDebate = true
            print("yo")
            addArgumentButton.isHidden = false
        }
        print(debate.againstArguer)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        if debate.defender != "o+"{
            forLabel.text = "For: \(debate.forArguer)"
            againstLabel.text = "Against: \(debate.againstArguer)"
            if !debate.finished{
                clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
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
            reloadTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: "reload", userInfo: nil, repeats: true)
        }
    }
    func reload(){
            let query = PFQuery(className: "Debates")
            query.getObjectInBackground(withId: rawData.objectId!) { (object, error) in
                self.rawData = object!
                self.debate = DebateClient.convert(object!)
                if self.debate.defender != "o+"{
                    self.forLabel.text = "For: \(self.debate.forArguer)"
                    self.againstLabel.text = "Against: \(self.debate.againstArguer)"
                    self.addArgumentButton.isHidden = false
                    if !self.debate.finished && self.clockTimer == nil{
                        self.clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
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
                //forClock.isHidden = debate.arguments[debate.arguments.count-1].components(separatedBy: ":")[0] ==
                //debate.forArguer
                // if the last user to write an argument was the against arguer then make the against clock hidden
                //againstClock.isHidden = debate.arguments[debate.arguments.count-1].components(separatedBy: ":")[0] ==
                //debate.againstArguer
            }else{
                // using ! so that if expression is true then make hidden false not true
                //forClock.isHidden = !(debate.challenger == debate.forArguer)
                //againstClock.isHidden = !(debate.challenger == debate.againstArguer)
            }
        }
    }
    func updateTimer(){
        if debate.finished{
            reloadTimer.invalidate()
            clockTimer.invalidate()
            return
        }
        if debate.dateStarted == ""{
            //forClock.isHidden = true
            //againstClock.isHidden = true
            return
        }
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date1 = dateFormatter1.date(from: debate.inviteTimeStamp)
        // get time elapsed
        var secondsSinceInvite = Int(Date().timeIntervalSince(date1!))
        // get the time left not elapsed
        // give 8 minutes for user to respond
        secondsSinceInvite = 480 - secondsSinceInvite
        if secondsSinceInvite <= 0 && debate.dateStarted == ""{
            debate.defender = ""
            debate.finished = true
            debate.winner = ""
            rawData.setObject("", forKey: defenderKey)
            rawData.setObject(true, forKey: finishedKey)
            rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
            rawData.saveInBackground()
        }
        // convert date string to NSDate form
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date = dateFormatter.date(from: debate.dateStarted)
        // get time elapsed
        currentSeconds = Int(Date().timeIntervalSince(date!))
        // get the time left not elapsed
        currentSeconds = debate.minutesPerArgument*60 - currentSeconds
        makeClocksHidden()
        if navigationItem.title == nil || navigationItem.title! == ""{
            navigationItem.title = debate.challenger
        }
        
        if navigationItem.title!.contains(debate.forArguer){
            // if the last argument was by the other user then move to the current user or the turn is finished on this client
            if debate.arguments.count > 0{
                if debate.arguments[debate.arguments.count-1].components(separatedBy: ":")[0] == String(debate.forArguer.characters.dropLast()) {
                    navigationItem.title = debate.againstArguer
                    turnFinished = false
                }
            }
            if turnFinished{
                /*forClock.isHidden = true
                againstClock.isHidden = false
                forClock.text = "0:00:00"*/
                navigationItem.title = debate.againstArguer
                turnFinished = false
                
            }
            else if currentSeconds >= 0{
                if currentSeconds < 60{
                    self.navigationItem.title = "\(navigationItem.title!.components(separatedBy: " : ")[0]) : 0.0.\(currentSeconds)"
                    //forClock.text = "0:0:\(currentSeconds)"
                }else if currentSeconds < 3600{
                    self.navigationItem.title = "\(navigationItem.title!.components(separatedBy: " : ")[0]) : 0.\(currentSeconds/60).\(currentSeconds%60)"
                    //forClock.text = "0:\(currentSeconds/60):\(currentSeconds%60)"
                }else if currentSeconds == 3600{
                    self.navigationItem.title = "\(navigationItem.title!.components(separatedBy: " : ")[0]) : 1.00.00"
                    //forClock.text = "1:00:00"
                }
            } else if currentSeconds < 0 && !debate.finished{
                //forClock.isHidden = true
                navigationItem.title = debate.againstArguer
                PFUser.current()!.setObject(false, forKey: "inDebate")
                PFUser.current()!.saveInBackground()
                PFUser.current()!.fetchInBackground()
                // close the debate here
                debate.finished = true
                rawData.setObject(true, forKey: finishedKey)
                debate.winner = "\(debate.againstArguer) forfeited match! \(debate.forArguer) has won!"
                rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                rawData.saveInBackground()
                
                self.tableView.reloadData()
            }
            // if errors then remove !debate.finished!!!!!!!
            if debate.arguments.count > 1 && debate.arguments.count/2 >= debate.rebuttalRounds{
                // debate is over
                //forClock.isHidden = true
                //againstClock.isHidden = true
                navigationItem.title = ""
                PFUser.current()!.setObject(false, forKey: "inDebate")
                PFUser.current()!.saveInBackground()
                PFUser.current()!.fetchInBackground()
                // close the debate here
                debate.finished = true
                rawData.setObject(true, forKey: finishedKey)
                debate.winner = "Debate is finished"
                rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                rawData.saveInBackground()
                
                self.tableView.reloadData()
            }
        }else{
            
            if debate.arguments.count > 0{
                if debate.arguments[debate.arguments.count-1].components(separatedBy: ":")[0] == String(debate.againstArguer.characters.dropLast()) {
                    navigationItem.title = debate.forArguer
                    turnFinished = false
                }
            }
            
            if turnFinished{
                /*forClock.isHidden = false
                againstClock.isHidden = true
                
                againstClock.text = "0:00:00" */
                
                navigationItem.title = debate.forArguer
                turnFinished = false
            }
            else if currentSeconds >= 0{
                if currentSeconds < 60{
                    self.navigationItem.title = "\(navigationItem.title!.components(separatedBy: " : ")[0]) : 0:0:\(currentSeconds)"
                    //againstClock.text = "0:0:\(currentSeconds)"
                }else if currentSeconds < 3600{
                    self.navigationItem.title = "\(navigationItem.title!.components(separatedBy: " : ")[0]) : 0.\(currentSeconds/60).\(currentSeconds%60)"
                    //againstClock.text = "0:\(currentSeconds/60):\(currentSeconds%60)"
                }else if currentSeconds == 3600{
                    self.navigationItem.title = "\(navigationItem.title!.components(separatedBy: " : ")[0]) : 1.00.00"
                    //againstClock.text = "1:00:00"
                }
            }else if currentSeconds < 0 && !debate.finished{
                //againstClock.isHidden = true
                navigationItem.title = debate.forArguer
                PFUser.current()?.setObject(false, forKey: "inDebate")
                PFUser.current()?.saveInBackground()
                PFUser.current()?.fetchInBackground()
                debate.finished = true
                rawData.setObject(true, forKey: finishedKey)
                debate.winner = "\(debate.againstArguer) forfeited match! \(debate.forArguer) has won!"
                rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                rawData.saveInBackground()
                
                self.tableView.reloadData()
            }
            // if errors then remove !debate.finished!!!!!!!
            if debate.arguments.count > 1 && debate.arguments.count/2 >= debate.rebuttalRounds{
                // debate is over
                //againstClock.isHidden = true
                navigationItem.title = debate.forArguer
    
                PFUser.current()!.setObject(false, forKey: "inDebate")
                PFUser.current()!.saveInBackground()
                PFUser.current()!.fetchInBackground()
                // close the debate here
                debate.finished = true
                rawData.setObject(true, forKey: finishedKey)
                debate.winner = "Debate is finished"
                rawData["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                rawData.saveInBackground()
                
                self.tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debate.arguments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "argumentCell") as! DebateManagerTableViewCell
        cell.userLabel.text = debate.arguments[(indexPath as NSIndexPath).row].components(separatedBy: ":")[0]
        if debate.arguments[(indexPath as NSIndexPath).row].components(separatedBy: ":").count > 1{
            let components = debate.arguments[(indexPath as NSIndexPath).row].components(separatedBy: ":")
            var text = ""
            for i in 1 ..< components.count {
                text += components[i]
            }
            cell.argumentLabel.text = text
            print(cell.argumentLabel.text)
        }else{
            cell.argumentLabel.text = ""
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if debate.winner != ""{
            return debate.winner
        }
        return ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addArgument(_ sender: AnyObject) {
        
    }
    func errorHandling(){
        // make things go wrong
        if debate.dateStarted != ""{
            // convert date string to NSDate form
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let date = dateFormatter.date(from: debate.dateStarted)
            // get time elapsed
            currentSeconds = Int(Date().timeIntervalSince(date!))
            // get the time left not elapsed
            currentSeconds = debate.minutesPerArgument*60 - currentSeconds
            if currentSeconds <= 0{
                let alert = UIAlertController(title: "Closed Debate", message: "This debate has ended because a user waited too long and forfeited a round.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            if debate.arguments.count > 0{
                if debate.arguments.count/2 >= debate.rebuttalRounds{
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    alert.title = "This debate is full!"
                    self.present(alert, animated: true, completion: nil)
                }else if debate.arguments[debate.arguments.count-1].components(separatedBy: ":")[0] == PFUser.current()?.username{
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    alert.title = "Wait for your opponent to post their argument!"
                    self.present(alert, animated: true, completion: nil)
                }
            }else if debate.challenger != PFUser.current()!.username{
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                alert.title = "Wait for your opponent to post their argument!"
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            alert.title = "Wait for your opponent to accept the debate!"
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "newArgument"{
            rawData.fetchInBackground(block: { (object, error) in
                self.errorHandling()
            })
            if debate.arguments.count > 0 && debate.defender != ""{
                if debate.arguments[debate.arguments.count-1].components(separatedBy: ":")[0] == PFUser.current()?.username || debate.arguments.count/2 >= debate.rebuttalRounds{
                    return false
                }
            }else if debate.challenger != PFUser.current()!.username{
                return false
            }
            if debate.finished{
                return false
            }
        }
        return true
    }
    override func viewWillDisappear(_ animated: Bool) {
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
    @IBAction func report(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Inappropriate Content or Spam", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Report", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
            DebateClient.sendPush("\(self.debate.title) has been reported by \(PFUser.current()!.username!) Dhruv!", username: "John Cena")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newArgument"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! AddArgumentViewController
            vc.rawDebate = rawData
        }else if segue.identifier == "voteSegue"{
            let vc = segue.destination as! VoteViewController
            vc.rawData = rawData
            vc.debate = NSKeyedUnarchiver.unarchiveObject(with: rawData.object(forKey: "Debate") as! Data) as! Debate
        }
    }
}
