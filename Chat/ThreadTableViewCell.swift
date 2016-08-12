//
//  ThreadTableViewCell.swift
//  Chat
//
//  Created by Patrick Ridd on 8/11/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import UIKit

class ThreadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static var text = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    
    func updateCell(thread: Thread) {
        
        ThreadTableViewCell.text = ""
        
        for user in thread.users {
            ThreadTableViewCell.text += "\(user.username) "
        }
        
        self.usernameLabel.text = ThreadTableViewCell.text
        self.dateLabel.text = self.dateFormatter.stringFromDate(thread.timestamp)
    }
    
}


