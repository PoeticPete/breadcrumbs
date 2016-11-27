//
//  CalloutView.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/17/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class CalloutView: UIView {

    var upSelected = false
    var downSelected = false
    var annotation:CustomAnnotation!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var commentsButton: UIButton!
    
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var upOutlet: UIButton!
    @IBOutlet weak var downOutlet: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        openMapForPlace()
    }
    

    @IBAction func upTapped(_ sender: AnyObject) {
        
        if downSelected {
            downTapped(downOutlet)
        }
        
        var currLikes = Int(upvotesLabel.text!)!
        
        if upSelected {
            upOutlet.tintColor = UIColor.lightGray
            currLikes -= 1
            vote(-1, annotation.post.key)
            updateScore(i: -1)
            annotation.post.upVotes = annotation.post.upVotes - 1
            myVotes[annotation.post.key] = nil
            myVotesRef.child(deviceID).child(annotation.post.key).removeValue()
        } else {
            upOutlet.tintColor = getColor(Int(upvotesLabel.text!)!)
            currLikes += 1
            vote(1, annotation.post.key)
            updateScore(i: 1)
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
            vote(1, annotation.post.key)
            updateScore(i: -1)
            annotation.post.upVotes = annotation.post.upVotes + 1
            myVotes[annotation.post.key] = nil
            myVotesRef.child(deviceID).child(annotation.post.key).removeValue()
        } else {
            downOutlet.tintColor = getColor(Int(upvotesLabel.text!)!)
            currLikes -= 1
            vote(-1, annotation.post.key)
            updateScore(i: 1)
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
    
    
    func openMapForPlace() {
        
        
        let latitude:CLLocationDegrees =  annotation.coordinate.latitude
        let longitude:CLLocationDegrees =  annotation.coordinate.longitude
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        if self.locationButton.title(for: UIControlState.normal) != nil {
            mapItem.name = "\(self.locationButton.title(for: UIControlState.normal)!)"
        } else {
            mapItem.name = ""
        }
        
        
        
        
        mapItem.openInMaps(launchOptions: options)
        
    }
    

}
