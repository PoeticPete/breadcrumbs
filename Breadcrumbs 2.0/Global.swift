//
//  Global.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/17/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//
import Firebase

let deviceID = UIDevice.current.identifierForVendor!.uuidString
let themeColor = UIColor(red: 34.0/255.0, green: 167.0/255.0, blue: 240.0/255.0, alpha: 1.0)
let allPostsRef = FIRDatabase.database().reference().child("allPosts")
let currPostsRef = FIRDatabase.database().reference().child("currentPostLocations")
let myVotesRef = FIRDatabase.database().reference().child("myVotes")
let myPostsRef = FIRDatabase.database().reference().child("myPosts").child(deviceID)
let commentsRef = FIRDatabase.database().reference().child("comments")
let cloudinaryBaseURL = "https://res.cloudinary.com/dufz2rmju/"
var myVotes = [String: Int]()
let firebaseTimeStamp = [".sv":"timestamp"]
var mostUpvotes = -5

// this function will create a new geoFire location in Firebase
func setNewLocation(loc: CLLocation, baseRef: FIRDatabaseReference, key:String) {
    let newGeoFire = GeoFire(firebaseRef: baseRef)
    newGeoFire?.setLocation(loc, forKey: key)
}

func getMyVotes() {
    myVotesRef.child(deviceID).observeSingleEvent(of: .value, with: { (snapshot) in
        for child in snapshot.children {
            let childSnap = child as! FIRDataSnapshot
            myVotes[childSnap.key] = childSnap.value as! Int
        }
    })
}

// get color based on number of likes
func getColor(_ likes:Int) -> UIColor {
    
//        switch likes {
//        case let x where x >= 5:
//            return UIColor(red: 22.0/255.0, green: 160.0/255.0, blue: 133.0/255.0, alpha: 1.0)
//        default:
//            return UIColor(red: 26.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0)
//        }
    
    if likes <= 0 {
        return UIColor(red: 26.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0)
    }
    
    switch likes {
    case let x where x == mostUpvotes:
        return UIColor(red: 211.0/255.0, green: 84.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    case let x where x >= mostUpvotes/2:
        return UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1.0)
    case let x where x >= mostUpvotes/4:
        return UIColor(red: 22.0/255.0, green: 160.0/255.0, blue: 133.0/255.0, alpha: 1.0)
    default:
        return UIColor(red: 26.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0)
    }
    
    // sunflower yellow - UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0, alpha: 1.0)
    // peter river blue - return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    // amythist rgba(155, 89, 182,1.0)
    // green sea - UIColor(red: 22.0/255.0, green: 160.0/255.0, blue: 133.0/255.0, alpha: 1.0)
    // turquiose - UIColor(red: 26.0/255.0, green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0)
}

func dateFromMilliseconds(ms: NSNumber) -> NSDate {
    return NSDate(timeIntervalSince1970:Double(ms) / 1000.0)
}

func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = NSDate()
    let earliest = now.earlierDate(date as Date)
    let latest = (earliest == now as Date) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else {
        return "Just now"
    }
    
}
