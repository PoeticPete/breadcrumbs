//
//  PostViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 11/14/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class PostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var viewWithImage: UIView!
    @IBOutlet weak var photo: DIImageView!
    @IBOutlet weak var messageCheck: UIButton!
    
    
    var imagePicked:UIImage!
    let placeHolderText = "What's cooking, good looking?"
    var photoLocation = currentLocation
    var photoLocationName = currentLocationName
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var characterLeftLabel: UILabel!

    @IBAction func checkTapped(_ sender: Any) {
        print("tapped check")
        if imagePicked != nil {
            let newLayer = photo.layer
            imagePicked = UIImage.imageFromLayer(layer: newLayer)
            let randomRef = FIRDatabase.database().reference().childByAutoId().key
            let data = UIImageJPEGRepresentation(imagePicked, 0.5)
            let smallData = UIImageJPEGRepresentation(resizeImage(image: imagePicked, newWidth: 50.0), 0.8)
            
            let saveLocation = imagesRef.child("\(randomRef).jpg")
            let smallSaveLocation = smallImagesRef.child("\(randomRef).jpg")
            
            let uploadTask = saveLocation.put(data!, metadata: nil) { metadata, error in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    
                    let smallUploadTask = smallSaveLocation.put(smallData!, metadata: nil) { smallMetadata, error in
                        if (error != nil) {
                            // Uh-oh, an error occurred!
                        } else {
                            let downloadURL = metadata!.downloadURL
                            let smallDownloadURL = smallMetadata!.downloadURL
                            print("this is the url for downloads")
                            setNewLocation(loc: self.photoLocation, baseRef: currPostsRef, key: randomRef)
                            allPostsRef.child(randomRef).child("upVotes").setValue(0)
                            allPostsRef.child(randomRef).child("timestamp").setValue(firebaseTimeStamp)
                            allPostsRef.child(randomRef).child("hasPicture").setValue(true)
                            allPostsRef.child(randomRef).child("mediaURL").setValue(downloadURL()!.absoluteString)
                            allPostsRef.child(randomRef).child("smallMediaURL").setValue(smallDownloadURL()!.absoluteString)
                            allPostsRef.child(randomRef).child("message").setValue("picture with ID \(randomRef)")
                            allPostsRef.child(randomRef).child("locationName").setValue(self.photoLocationName)
                            myPostsRef.child(randomRef).child("timestamp").setValue(firebaseTimeStamp)
                            updateScore(i: 2)
                            justPosted = true
                        }
                    }
                }
            }
            
            
            
            
        } else {
            print(textView.text)
            let trimmedString = textView.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            setMessage(loc: currentLocation, message: trimmedString)
            justPosted = true
        }
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func xTapped(_ sender: Any) {
        print("tapped x")
        imagePicked = nil
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cameraTapped(_ sender: Any) {
        print("Tapped camera")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            print("presenting imagePicker")
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("not available")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        textView.delegate = self
        textView.text = placeHolderText
        textView.textColor = UIColor.lightGray
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if textView.text == placeHolderText {
            messageCheck.isEnabled = false
        }
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
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        print("began editing")
        print(textView.textColor == UIColor.lightGray)
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    @IBAction func xImageTapped(_ sender: Any) {
        self.viewWithImage.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("end editting")
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        
        let trimmedString = textView.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if trimmedString.characters.count == 0 {
            messageCheck.isEnabled = false
        } else {
            messageCheck.isEnabled = true
        }
        
        var charsLeft = 140 - numberOfChars
        if charsLeft < 0 {
            charsLeft = 0
        }
        characterLeftLabel.text = "\(charsLeft)"
        
        return numberOfChars < 141;
    }
    
    func setMessage(loc:CLLocation, message:String) {
        let randomKey = FIRDatabase.database().reference().childByAutoId().key
        setNewLocation(loc: loc, baseRef: currPostsRef, key: randomKey)
        
        
        allPostsRef.child(randomKey).child("message").setValue(message)
        allPostsRef.child(randomKey).child("upVotes").setValue(0)
        allPostsRef.child(randomKey).child("deviceID").setValue(deviceID)
        allPostsRef.child(randomKey).child("timestamp").setValue(firebaseTimeStamp)
        allPostsRef.child(randomKey).child("locationName").setValue(currentLocationName)
        myPostsRef.child(randomKey).child("timestamp").setValue(firebaseTimeStamp)
        updateScore(i: 1)
    }

}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let thisPhoto = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePicked = thisPhoto
            self.photo.image = imagePicked
            self.viewWithImage.isHidden = false
            photoLocation = currentLocation
            photoLocationName = currentLocationName
            print("picked \(photo)")
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
