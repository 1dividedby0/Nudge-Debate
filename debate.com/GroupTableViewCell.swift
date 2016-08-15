//
//  GroupTableViewCell.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 2/13/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class GroupTableViewCell: UITableViewCell {
    var messages: [String]!
    var name: String!
    @IBOutlet weak var groupName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        groupName.text = name
        print("DISHFkjsndfjn")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func follow(_ sender: AnyObject) {
    }

}
