//
//  CrumbTableViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/28/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import Firebase

class CrumbTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var table: UITableView!
    var annotation:CustomAnnotation!
    var comments = [Comment]()
    var keyboardHeight:CGFloat!
    var newCommentField: UITextView!
    var characterLabel:UILabel!
    var keyboardVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(CrumbTableViewController.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(CrumbTableViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        getComments()
        print(annotation)
    }

    func getComments() {
        commentsRef.child(annotation.post.key).observeSingleEvent(of: .value, with: { commentsSnap in
            for child in commentsSnap.children {
                let childSnap = child as! FIRDataSnapshot
                let message = childSnap.childSnapshot(forPath: "message").value! as! String
                let timestamp = childSnap.childSnapshot(forPath: "timestamp").value as! TimeInterval
                let date = NSDate(timeIntervalSince1970: timestamp/1000)
                var upVotes = 0
                if childSnap.childSnapshot(forPath: "upVotes").exists() {
                    upVotes = childSnap.childSnapshot(forPath: "upVotes").value! as! Int
                }
                let uid = childSnap.childSnapshot(forPath: "deviceID").value as! String
                let key = childSnap.key
                self.comments.append(Comment(message: message, upVotes: upVotes, timestamp: date, deviceID: uid, key:key))
            }
            self.table.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if annotation.post.hasPicture == true {

            if indexPath.row == 0 {
                if let img = getImageFromURL(annotation.post.mediaURL!) {
                    return UIScreen.main.bounds.width * img.size.height / img.size.width
                } else {
                    return 100
                }
            } else if indexPath.row == comments.count + 1 {
                return 130.0
            }
            else {
                return 100.0
            }
        } else {
            if indexPath.row == 0 {
                return 300.0
            } else if indexPath.row == comments.count + 1 {
                return 130.0
            } else {
                return 100.0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if annotation.post.hasPicture == true && indexPath.row == 0 {
            let cell = table.dequeueReusableCell(withIdentifier: "PhotoCrumbCell") as! PhotoCrumbTableViewCell
            cell.photo.image = getImageFromURL(annotation.post.mediaURL!)
            
            cell.timestampLabel.text = "  " + timeAgoSinceDate(date: annotation.post.timestamp, numericDates: true) + "  "
            cell.annotation = self.annotation
            cell.upvotesLabel.text = "\(annotation.post.upVotes!)"
            if myVotes[annotation.post.key] == 1 {
                cell.upSelected = true
                cell.upOutlet.tintColor = getColor(annotation.post.upVotes!)
            } else if myVotes[annotation.post.key] == -1 {
                cell.downSelected = true
                cell.downOutlet.tintColor = getColor(annotation.post.upVotes!)
            }
            return cell
        } else if annotation.post.hasPicture == false && indexPath.row == 0{
            let cell = table.dequeueReusableCell(withIdentifier: "CrumbCell") as! CrumbTableViewCell
            cell.postLabel.text = annotation.post.message
            return cell
        } else if indexPath.row == comments.count + 1 {
            let cell = table.dequeueReusableCell(withIdentifier: "NewCommentCell") as! NewCommentTableViewCell
            cell.textView.delegate = self
            cell.textView.textColor = UIColor.lightGray
            self.newCommentField = cell.textView
            cell.sendButton.addTarget(self, action: #selector(CrumbTableViewController.sendTapped), for: UIControlEvents.touchUpInside)
            cell.cancelButton.addTarget(self, action: #selector(CrumbTableViewController.cancelTapped), for: UIControlEvents.touchUpInside)
            characterLabel = cell.characterLabel
            // (self, action: #selector(ViewController.toCrumbTableView), for: UIControlEvents.touchUpInside)
            return cell
            
        } else {
            // comments
            let cell = table.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
            let comment = comments[indexPath.row - 1]
            cell.messageLabel.text = comment.message
            cell.timestampLabel.text = timeAgoSinceDate(date: comment.timestamp, numericDates: true)
            
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < 1 || indexPath.row > comments.count {
            return false
        } else if comments[indexPath.row - 1].deviceID == deviceID {
            return true
        } else {
            return false
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            print("delete this")
            
            let removed = comments.remove(at: indexPath.row - 1)
            table.beginUpdates()
            table.deleteRows(at: [indexPath], with: .fade)
            table.endUpdates()
            print(commentsRef.child(annotation.post.key).child(removed.key).removeValue())
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func sendTapped() {
        print("Send tapped")
        let trimmedComment = newCommentField.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if newCommentField.text == "New comment" || trimmedComment == "" {
            return
        } else {
            let comRef = commentsRef.child(annotation.post.key).childByAutoId()
            comRef.child("message").setValue(newCommentField.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines))
            comRef.child("timestamp").setValue(firebaseTimeStamp)
            comRef.child("deviceID").setValue(deviceID)
            
            let newCom = Comment(message: trimmedComment, upVotes: 0, timestamp: NSDate(), deviceID: deviceID, key:comRef.key)
            comments.append(newCom)
            table.beginUpdates()
            table.insertRows(at: [IndexPath(row: comments.count, section: 0)], with: .fade)
            table.endUpdates()
            
        }
        
        newCommentField.text = "New comment"
        newCommentField.textColor = UIColor.lightGray
        self.view.endEditing(true)
        
        
    }
    
    func cancelTapped() {
        print("cancel tapped")
        newCommentField.text = "New comment"
        newCommentField.textColor = UIColor.lightGray
        self.view.endEditing(true)
    }
    
//    func moveTable(height: CGFloat, up: Bool)
//    {
//        let movementDistance:CGFloat = -180
//        let movementDuration: Double = 0.3
//        
//        var movement:CGFloat = 0
//        if up
//        {
//            movement = movementDistance
//        }
//        else
//        {
//            movement = -movementDistance
//        }
//        UIView.beginAnimations("animateTextField", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(movementDuration)
//        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
//        UIView.commitAnimations()
//    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("began editing")
        print(textView.textColor == UIColor.lightGray)
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("end editting")
        keyboardVisible = false
        if textView.text.isEmpty {
            textView.text = "New comment"
            textView.textColor = UIColor.lightGray
        }
//        self.moveTable(height: keyboardHeight, up:false)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        var charsLeft = 140 - numberOfChars
        if charsLeft < 0 {
            charsLeft = 0
        }
        characterLabel.text = "\(charsLeft)"
        
        return numberOfChars < 141;
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            

            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            print(self.keyboardHeightLayoutConstraint)
            
            self.table.layoutIfNeeded()
            scrollToBottom()
//            UIView.animate(withDuration: duration,
//                           delay: TimeInterval(0),
//                           options: animationCurve,
//                           animations: { self.table.layoutIfNeeded()
//            },
//                           completion: nil)

        }
    }
    
    func scrollToBottom() {
        let numberOfRows = self.table.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: 0)
            self.table.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
        }
    }
    
//    func keyboardWillShow(notification:NSNotification) {
//        if keyboardVisible == false {
//            keyboardVisible = true
//            let userInfo:NSDictionary = notification.userInfo! as NSDictionary
//            let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            print(keyboardHeight)
//            self.keyboardHeight = keyboardHeight
//            self.moveTable(height: keyboardHeight, up: true)
//        }
//    }
    


    

}
