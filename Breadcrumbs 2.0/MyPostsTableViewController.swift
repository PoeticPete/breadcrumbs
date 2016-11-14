//
//  ProfileViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Mike Keegan on 10/18/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import Firebase


class MyPostsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var nearbyPosts = [Post]()
    
    @IBOutlet weak var crumbsTableView: UITableView!
    @IBOutlet weak var profileDescriptionView: UIView!
    
    @IBOutlet weak var statsLabel: UILabel!
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    //@IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    let maxHeaderHeight: CGFloat = 88;
    let minHeaderHeight: CGFloat = 44;
    var previousScrollOffset: CGFloat = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:
        //create dictionary to hold key->uiimage so we don't have to reload
        
        crumbsTableView.rowHeight = 180
        
        statsLabel.adjustsFontSizeToFitWidth = true
        // somehow the profileDescriptView's height was 1000, changed below
        profileDescriptionView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 100.0)
        crumbsTableView.tableHeaderView = profileDescriptionView
        crumbsTableView.tableHeaderView?.alpha = 0.95
        navigationController?.hidesBarsOnSwipe = true
        //crumbsTableView.contentInset = UIEdgeInsetsMake(-500, 0, 0, 0);
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.headerHeight.constant = self.maxHeaderHeight
        getMyPostsAndRefresh()
    }
    
    func getMyPostsAndRefresh() {
        print("Getting posts and refreshing")
        nearbyPosts.removeAll()
        currPostsRef.observeSingleEvent(of: FIRDataEventType.value, with: { snapshot in
            for child in snapshot.children {
                let childSnap = child as! FIRDataSnapshot
                allPostsRef.child(childSnap.key).observeSingleEvent(of: FIRDataEventType.value, with: { postSnap in
                    var message:String!
                    var timestamp:NSDate!
                    var upVotes:Int!
                    var hasPicture:Bool!
                    if let m = postSnap.childSnapshot(forPath: "message").value as? String {
                        message = m
                    }
                    if let t = postSnap.childSnapshot(forPath: "timestamp").value as? TimeInterval {
                        timestamp = NSDate(timeIntervalSince1970: t/1000)
                    }
                    if let uv = postSnap.childSnapshot(forPath: "upVotes").value as? Int {
                        upVotes = uv
                    }
                    if postSnap.childSnapshot(forPath: "hasPicture").exists() {
                        if let hp = postSnap.childSnapshot(forPath: "hasPicture").value as? Bool {
                            hasPicture = hp
                        }
                    } else {
                        hasPicture = false
                    }
                    //                    print("\(message) \(timestamp) \(upVotes) \(hasPicture)")
                    
                    if message != nil && timestamp != nil && upVotes != nil && hasPicture != nil {
                        var newPost = Post(key: childSnap.key, message: message, upVotes: upVotes, timestamp: timestamp, hasPicture: hasPicture)
                        self.nearbyPosts.append(newPost)
                        self.crumbsTableView.reloadData()
                    }
                })
                
            }
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        // Calculate new header height
        var newHeight = self.headerHeight.constant
        if isScrollingDown {
            newHeight = max(self.minHeaderHeight, self.headerHeight.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(self.maxHeaderHeight, self.headerHeight.constant + abs(scrollDiff))
        }
        
        // Header needs to animate
        if newHeight != self.headerHeight.constant {
            self.headerHeight.constant = newHeight
            self.updateHeader()
            self.setScrollPosition(position: self.previousScrollOffset)
        }
        
        self.previousScrollOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeight.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeight.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeight.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func setScrollPosition(position: CGFloat) {
        self.crumbsTableView.contentOffset = CGPoint(x: self.crumbsTableView.contentOffset.x, y: position)
    }
    
    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeight.constant - self.minHeaderHeight
        let percentage = openAmount / range
        
        //self.titleTopConstraint.constant = -openAmount + 10
        self.profilePic.alpha = percentage
    }
    
    
    //Table view methods:
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.crumbsTableView.dequeueReusableCell(withIdentifier: "ProfCell") as! ProfileTableViewCell
        cell.changeIMG(newIMG: UIImage())
        
        //next step is loading this info from firebase!
        print(nearbyPosts.count)
        print(indexPath.row)
        cell.changeTitle(newTitle: nearbyPosts[indexPath.row].message)
        cell.changeDescription(newDesc: "test description yo! this is a really long line that will need a line break, so let's make sure that works! long descriptions should not be allowed in the final project. possibly character limit.")
        cell.changeLocation(newLocation: "Some GPS Coordinates or location name that the person put in")
        cell.changeScore(newScore: nearbyPosts[indexPath.row].upVotes)
        if(nearbyPosts[indexPath.row].hasPicture == true){
            cell.changeIMG(newIMG: getImageFromURL(cloudinaryBaseURL + nearbyPosts[indexPath.row].key)!)
        }
        else{
            //move the text to the left
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
        //        return CGFloat.leastNormalMagnitude
    }
    
    //end table view methods
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
