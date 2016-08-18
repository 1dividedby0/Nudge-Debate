//
//  DebateClient.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/28/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import Foundation
import Parse
var debatesMain = [Debate]()
var rawDebates = [PFObject]()
var isLoading = false
class DebateClient{
    static func sendPush(_ message: String, username: String){
        if username != "o+"{
            let userQuery = PFUser.query()!
            userQuery.whereKey("username", equalTo: username)
            
            let query = PFQuery<PFInstallation>(className: "PFInstallation")
            query.whereKey("user", matchesQuery: userQuery)
            
            let push = PFPush()
            push.setQuery(query)
            push.setMessage(message)
            
            push.sendInBackground { (success: Bool, error: NSError?) -> Void in
                if error == nil && success{
                    print("push notification sent to user \(username)!")
                }
            }
        }else{
            let userQuery = PFUser.query()!
            userQuery.whereKey("username", notEqualTo: PFUser.current()!.username!)
            let query = PFQuery<PFInstallation>(className: "PFInstallation")
            
            query.whereKey("user", matchesQuery: userQuery)
            
            let push = PFPush()
            push.setQuery(query)
            push.setMessage(message)
            
            push.sendInBackground(block: { (success, error) -> Void in
                if error != nil{
                    print("push notification failed!")
                }
            })
        }
    }
    static func retrieveDebates(){
        var debates = [Debate]()
        let query = PFQuery(className: "Debates")
        query.findObjectsInBackground { (data: [PFObject]?, error: NSError?) -> Void in
            if data != nil{
                for i in data!{
                    let data = i["Debate"] as! Data
                    debates.append(NSKeyedUnarchiver.unarchiveObject(with: data) as! Debate)
                }
                rawDebates = data!
                debatesMain = debates
                isLoading = true
            }else{
                
                print(error?.localizedDescription)
            }
        }
    }

    static func convert(_ object: PFObject) -> Debate{
        return NSKeyedUnarchiver.unarchiveObject(with: object["Debate"] as! Data) as! Debate
    }
    static func createDebate(_ debate: Debate, rawData: PFObject) -> PFObject{
        
        let object = rawData
        object.setObject(debate.title, forKey: "Title")
        object.setObject(debate.finished, forKey: finishedKey)
        object.setObject(debate.challenger, forKey: challengerKey)
        object.setObject(debate.defender, forKey: defenderKey)
        object.setObject(debate.minutesPerArgument, forKey: minutesPerArgumentKey)
        object.setObject(debate.dateStarted, forKey: dateStartedKey)
        object.setObject(debate.inviteTimeStamp, forKey: inviteTimeStampKey)
        object.setObject(debate.winner, forKey: winnerKey)
        object.setObject(debate.forArguer, forKey: forArguerKey)
        object.setObject(debate.againstArguer, forKey: againstArguerKey)
        
        object.saveInBackground { (success: Bool, error: NSError?) -> Void in
            if success && debate.challenger != ""{
                print("success in creating a new debate")
                
                DebateClient.sendPush("You have 8 minutes to respond: \(PFUser.current()!.username) has invited you to a debate!", username: debate.defender)
                rawData.fetchInBackground(block: { (object, error) in
                    let viewer = PFObject(className: "Views")
                    if let theLatest = object{
                        viewer.setObject(theLatest.objectId!, forKey: "debateObjectID")
                        viewer.setObject([String](), forKey: "viewers")
                        viewer.saveInBackground()
                    }
                })
                
            }
        }
        return object
    }
    static func postArgument(_ debateID: String, argument: String){
        let query = PFQuery(className: "Debates")
            query.getObjectInBackground(withId: debateID, block: { (data: PFObject?, error: NSError?) -> Void in
                let debate = NSKeyedUnarchiver.unarchiveObject(with: data!["Debate"] as! Data) as! Debate
                debate.arguments.append(argument)
                data!["Debate"] = NSKeyedArchiver.archivedData(withRootObject: debate)
                data!.saveInBackground()
            })
        }
    static func updateDebate(_ index: Int, debate: Debate){
        let data = NSKeyedArchiver.archivedData(withRootObject: debate)
        var object: PFObject!
        let query = PFQuery(className: "Debates")
        query.findObjectsInBackground { (objects: [PFObject]?, error: NSError?) -> Void in
            object = objects![index]
            object["Debate"] = data
            object.saveInBackground(block: { (success: Bool, error: NSError?) -> Void in
                if success{
                    print("success in updating")
                }
            })
        }
    }
    static func voteAndComment(){
        
    }
}
let curseWordArray = ["fuck", "shit", "asshole", "cunt", "fag", "fuk", "fck", "fcuk", "fucked", "assfuck", "assfucker", "fucker",
    "motherfucker", "asscock", "asshead", "asslicker", "asslick", "assnigger", "nigger", "asssucker", "bastard", "bitchtits",
    "bitches", "bitch", "brotherfucker", "bullshit", "bumblefuck", "buttfucka", "fucka", "buttfucker", "buttfucka", "fagbag", "fagfucker",
    "faggit", "faggot", "faggotcock", "fagtard", "fatass", "fuckoff", "fuckstick", "fucktard", "fuckwad", "fuckwit", "dick",
    "dickfuck", "dickhead", "dickjuice", "dickmilk", "doochbag", "douchebag", "douche", "dickweed", "dyke", "dumbass", "dumass",
    "fuckboy", "fuckbag", "gayass", "gayfuck", "gaylord", "gaytard", "nigga", "niggers", "niglet", "paki", "piss", "prick", "pussy",
    "poontang", "poonany", "porchmonkey","porch monkey", "poon", "queer", "queerbait", "queerhole", "queef", "renob", "rimjob", "ruski",
    "sandnigger", "sand nigger", "schlong", "shitass", "shitbag", "shitbagger", "shitbreath", "chinc", "carpetmuncher", "chink", "choad", "clitface"
    , "clusterfuck", "cockass", "cockbite", "cockface", "skank", "skeet", "skullfuck", "slut", "slutbag", "splooge", "twatlips", "twat",
    "twats", "twatwaffle", "vaj", "vajayjay", "va-j-j", "wank", "wankjob", "wetback", "whore", "whorebag", "whoreface"]
