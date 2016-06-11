//
//  PersonTableViewCell.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 2/2/16.
//  Copyright © 2016 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
class PersonTableViewCell: UITableViewCell {
    
    var user: PFUser!
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setUp(){
        nameLabel.text = user.username!.stringByReplacingOccurrencesOfString("-", withString: "")
//        if ((user.objectForKey("profile_pic") as? PFFile) != nil){
//            let file = user.objectForKey("profile_pic") as! PFFile
//            file.getDataInBackgroundWithBlock({ (data, error) -> Void in
//                self.personImage.image = UIImage(data: data!)
//            })
//        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
