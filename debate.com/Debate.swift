//
//  Debate.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/28/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import Foundation
import Parse
class Debate: NSObject, NSCoding{
    var title: String!
    var forArguer: String!
    var againstArguer: String!
    var challenger: String!
    var defender: String!
    var arguments: [String]!
    var forVotes: Int!
    var againstVotes: Int!
    var forVoters: [String]!
    var againstVoters: [String]!
    var rebuttalRounds: Int!
    var minutesPerArgument: Int!
    var dateStarted: String!
    var finished: Bool!
    var winner: String!
    var inviteTimeStamp: String!
    var category: String!
    var comments: [String]!
    var viewers: [String]!
    init(title: String, challenger: String, defender: String, arguments: [String], forArguer: String, againstArguer: String, rebuttalRounds: Int, minutesPerArgument: Int, category: String, comments: [String]){
        self.title = title
        self.challenger = challenger
        self.defender = defender
        self.arguments = arguments
        self.forVotes = 0
        self.againstVotes = 0
        self.forArguer = forArguer
        self.againstArguer = againstArguer
        self.rebuttalRounds = rebuttalRounds
        self.minutesPerArgument = minutesPerArgument
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let dateInFormat:String = dateFormatter.stringFromDate(NSDate())
        self.dateStarted = ""
        self.finished = false
        self.winner = ""
        self.inviteTimeStamp = dateInFormat
        self.category = category
        self.comments = comments
        self.forVoters = [String]()
        self.againstVoters = [String]()
        self.viewers = [String]()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(challenger, forKey: "challenger")
        aCoder.encodeObject(defender, forKey: "defender")
        aCoder.encodeObject(arguments, forKey: "arguments")
        aCoder.encodeInteger(forVotes, forKey: "forVotes")
        aCoder.encodeInteger(againstVotes, forKey: "againstVotes")
        aCoder.encodeObject(forArguer, forKey: "forArguer")
        aCoder.encodeObject(againstArguer, forKey: "againstArguer")
        aCoder.encodeInteger(rebuttalRounds, forKey: "rebuttalRounds")
        aCoder.encodeInteger(minutesPerArgument, forKey: "minutesPerArgument")
        aCoder.encodeObject(dateStarted, forKey: "dateCreated")
        aCoder.encodeBool(finished, forKey: "finished")
        aCoder.encodeObject(winner, forKey: "winner")
        aCoder.encodeObject(inviteTimeStamp, forKey: "inviteTimeStamp")
        aCoder.encodeObject(category, forKey: "category")
        aCoder.encodeObject(comments, forKey: "comments")
        aCoder.encodeObject(forVoters, forKey: "forVoters")
        aCoder.encodeObject(againstVoters, forKey: "againstVoters")
        aCoder.encodeObject(viewers, forKey: "viewers")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObjectForKey("title") as! String
        self.challenger = aDecoder.decodeObjectForKey("challenger") as! String
        self.defender = aDecoder.decodeObjectForKey("defender") as! String
        self.arguments = aDecoder.decodeObjectForKey("arguments") as! [String]
        self.forVotes = aDecoder.decodeIntegerForKey("forVotes")
        self.againstVotes = aDecoder.decodeIntegerForKey("againstVotes")
        self.againstArguer = aDecoder.decodeObjectForKey("againstArguer") as! String
        self.forArguer = aDecoder.decodeObjectForKey("forArguer") as! String
        self.rebuttalRounds = aDecoder.decodeIntegerForKey("rebuttalRounds")
        self.minutesPerArgument = aDecoder.decodeIntegerForKey("minutesPerArgument")
        self.dateStarted = aDecoder.decodeObjectForKey("dateCreated") as! String
        self.finished = aDecoder.decodeBoolForKey("finished")
        self.winner = aDecoder.decodeObjectForKey("winner") as! String
        self.inviteTimeStamp = aDecoder.decodeObjectForKey("inviteTimeStamp") as! String
        self.category = aDecoder.decodeObjectForKey("category") as! String
        self.comments = aDecoder.decodeObjectForKey("comments") as! [String]
        self.forVoters = aDecoder.decodeObjectForKey("forVoters") as! [String]
        self.againstVoters = aDecoder.decodeObjectForKey("againstVoters") as! [String]
        self.viewers = aDecoder.decodeObjectForKey("viewers") as? [String]
    }
}