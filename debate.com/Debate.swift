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
    var title: String
    var forArguer: String
    var againstArguer: String
    var challenger: String
    var defender: String
    var arguments: [String]
    var forVotes: Int
    var againstVotes: Int
    var forVoters: [String]
    var againstVoters: [String]
    var rebuttalRounds: Int
    var minutesPerArgument: Int
    var dateStarted: String
    var finished: Bool
    var winner: String
    var inviteTimeStamp: String
    var category: String
    var comments: [String]
    var viewers: [String]
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
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let dateInFormat:String = dateFormatter.string(from: Date())
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(challenger, forKey: "challenger")
        aCoder.encode(defender, forKey: "defender")
        aCoder.encode(arguments, forKey: "arguments")
        aCoder.encode(forVotes, forKey: "forVotes")
        aCoder.encode(againstVotes, forKey: "againstVotes")
        aCoder.encode(forArguer, forKey: "forArguer")
        aCoder.encode(againstArguer, forKey: "againstArguer")
        aCoder.encode(rebuttalRounds, forKey: "rebuttalRounds")
        aCoder.encode(minutesPerArgument, forKey: "minutesPerArgument")
        aCoder.encode(dateStarted, forKey: "dateCreated")
        aCoder.encode(finished, forKey: "finished")
        aCoder.encode(winner, forKey: "winner")
        aCoder.encode(inviteTimeStamp, forKey: "inviteTimeStamp")
        aCoder.encode(category, forKey: "category")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(forVoters, forKey: "forVoters")
        aCoder.encode(againstVoters, forKey: "againstVoters")
        aCoder.encode(viewers, forKey: "viewers")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.challenger = aDecoder.decodeObject(forKey: "challenger") as! String
        self.defender = aDecoder.decodeObject(forKey: "defender") as! String
        self.arguments = aDecoder.decodeObject(forKey: "arguments") as! [String]
        self.forVotes = aDecoder.decodeInteger(forKey: "forVotes")
        self.againstVotes = aDecoder.decodeInteger(forKey: "againstVotes")
        self.againstArguer = aDecoder.decodeObject(forKey: "againstArguer") as! String
        self.forArguer = aDecoder.decodeObject(forKey: "forArguer") as! String
        self.rebuttalRounds = aDecoder.decodeInteger(forKey: "rebuttalRounds")
        self.minutesPerArgument = aDecoder.decodeInteger(forKey: "minutesPerArgument")
        self.dateStarted = aDecoder.decodeObject(forKey: "dateCreated") as! String
        self.finished = aDecoder.decodeBool(forKey: "finished")
        self.winner = aDecoder.decodeObject(forKey: "winner") as! String
        self.inviteTimeStamp = aDecoder.decodeObject(forKey: "inviteTimeStamp") as! String
        self.category = aDecoder.decodeObject(forKey: "category") as! String
        self.comments = aDecoder.decodeObject(forKey: "comments") as! [String]
        self.forVoters = aDecoder.decodeObject(forKey: "forVoters") as! [String]
        self.againstVoters = aDecoder.decodeObject(forKey: "againstVoters") as! [String]
        self.viewers = aDecoder.decodeObject(forKey: "viewers") as! [String]
    }
}
