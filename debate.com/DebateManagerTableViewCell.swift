//
//  DebateManagerTableViewCell.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 12/6/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit

class DebateManagerTableViewCell: UITableViewCell {
    @IBOutlet weak var argumentLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
