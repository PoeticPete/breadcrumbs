//
//  CrumbTableViewCell.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/28/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class CrumbTableViewCell: UITableViewCell {

    @IBOutlet weak var postLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
