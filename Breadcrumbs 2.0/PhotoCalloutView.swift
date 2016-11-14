//
//  PhotoCalloutView.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/28/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import Firebase

class PhotoCalloutView: UIView {

    var upSelected = false
    var downSelected = false
    var annotation:CustomAnnotation!
    
    @IBOutlet weak var votingView: UIView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var upOutlet: UIButton!
    @IBOutlet weak var downOutlet: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBAction func photoTapped(_ sender: Any) {
        if votingView.isHidden == true {
            votingView.isHidden = false
            timestampLabel.isHidden = false
        } else {
            votingView.isHidden = true
            timestampLabel.isHidden = true
        }
    }
    @IBAction func upTapped(_ sender: AnyObject) {
        
        if downSelected {
            downTapped(downOutlet)
        }
        
        var currLikes = Int(upvotesLabel.text!)!
        
        if upSelected {
            upOutlet.tintColor = UIColor.lightGray
            currLikes -= 1
            vote(-1)
            annotation.post.upVotes = annotation.post.upVotes - 1
            myVotes[annotation.post.key] = nil
            myVotesRef.child(deviceID).child(annotation.post.key).removeValue()
        } else {
            upOutlet.tintColor = getColor(Int(upvotesLabel.text!)!)
            currLikes += 1
            vote(1)
            annotation.post.upVotes = annotation.post.upVotes + 1
            myVotes[annotation.post.key] = 1
            myVotesRef.child(deviceID).child(annotation.post.key).setValue(1)
        }
        upvotesLabel.text = "\(currLikes)"
        upSelected = !upSelected
        
        
    }
    
    @IBAction func downTapped(_ sender: AnyObject) {
        if upSelected {
            upTapped(upOutlet)
        }
        
        var currLikes = Int(upvotesLabel.text!)!
        if downSelected {
            downOutlet.tintColor = UIColor.lightGray
            currLikes += 1
            vote(1)
            annotation.post.upVotes = annotation.post.upVotes + 1
            myVotes[annotation.post.key] = nil
            myVotesRef.child(deviceID).child(annotation.post.key).removeValue()
        } else {
            downOutlet.tintColor = getColor(Int(upvotesLabel.text!)!)
            currLikes -= 1
            vote(-1)
            annotation.post.upVotes = annotation.post.upVotes - 1
            myVotes[annotation.post.key] = -1
            myVotesRef.child(deviceID).child(annotation.post.key).setValue(-1)
        }
        upvotesLabel.text = "\(currLikes)"
        downSelected = !downSelected
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    func doubleTapped() {
        votingView.isHidden = false
        timestampLabel.isHidden = false
        
        var flashView = UIView()
        flashView.center = CGPoint(x: 0, y: 0)
        flashView.bounds = CGRect(x: 0, y: 0, width: self.bounds.width*10, height: self.bounds.height*10)
        self.addSubview(flashView)
        let oldColor = self.backgroundColor?.withAlphaComponent(0.0)

        
        flashView.backgroundColor = getColor(Int(upvotesLabel.text!)!)
        UIView.animate(withDuration: 0.2, animations: {
            flashView.backgroundColor = oldColor
        }, completion: { void in
            flashView.removeFromSuperview()
        })
        if !upSelected {
            upTapped(upOutlet)
        }
    }
    
    func vote(_ i: Int) {
        allPostsRef.child(annotation.post.key).child("upVotes").runTransactionBlock { (currentData: FIRMutableData) -> FIRTransactionResult in
            var value = currentData.value as? Int
            if value == nil {
                value = 0
            }
            currentData.value = value! + i
            return FIRTransactionResult.success(withValue: currentData)
        }
        
    }
    
}
