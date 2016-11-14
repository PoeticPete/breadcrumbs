//
//  ProfileTableViewCell.swift
//  Breadcrumbs 2.0
//
//  Created by Mike Keegan on 10/19/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var crumbTitleLabel: UILabel!
    @IBOutlet weak var crumbLocationLabel: UILabel!
    @IBOutlet weak var crumbDescriptionLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func changeTitle(newTitle: String){
        crumbTitleLabel.text = newTitle
    }
    
    func changeLocation(newLocation: String){
        crumbLocationLabel.text = newLocation
    }
    
    func changeDescription(newDesc: String){
        crumbDescriptionLabel.text = newDesc
    }
    
    func changeIMG(newIMG: UIImage){
        imgView.isHidden = false
        imgView.image = newIMG
        imgView.contentMode = .scaleAspectFit
    }

    func changeScore(newScore: Int){
        if(newScore>0){
            scoreLabel.textColor = UIColor.green
            scoreLabel.text = "+\(newScore)"
        }
        else if(newScore<0){
            scoreLabel.textColor = UIColor.red
            scoreLabel.text = "\(newScore)"
        }
        else{
            scoreLabel.textColor = UIColor.black
            scoreLabel.text = "\(newScore)"
        }
    }
    
    func compressIMG(){
        imgView.isHidden = true
    }
}
