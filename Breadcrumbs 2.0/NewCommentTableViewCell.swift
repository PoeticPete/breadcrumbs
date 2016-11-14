//
//  NewCommentTableViewCell.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/30/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class NewCommentTableViewCell: UITableViewCell{

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var characterLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
