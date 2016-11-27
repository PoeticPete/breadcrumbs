//
//  ViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/14/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // declare class variables
    var geofireRef:FIRDatabaseReference!
    var geoFire:GeoFire!
    var manager:CLLocationManager!
    var flatAnnotationImage:UIImage!
    var imagePicked:UIImage!
    var annotation:CustomAnnotation!
    var annotations = [CustomAnnotation]()
    var annotationTuples = [(String,CLLocation)]()
    var selectedView = UIView()
    var clusteredAnnotations = [CustomAnnotation]()
    var mapRegionSet = false
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set class variables
        geofireRef = FIRDatabase.database().reference().child("test")
        geoFire = GeoFire(firebaseRef: geofireRef)
        setupLocationManager()
        setupAnnotationIconImage()
        getMyVotes()
        setupMap()
        getLocalMessages()
        logSession()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateTitle(notification:)), name: Notification.Name("currentScoreUpdated"), object: nil)
        
    }
    
    
    @IBAction func composeTapped(_ sender: AnyObject) {
        manager.requestLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        if justPosted == true {
            getLocalMessages()
            justPosted = false
        }
        
        scoreRef.child(deviceID).observeSingleEvent(of: .value, with: {snapshot in
            if !snapshot.exists() {
                scoreRef.child(deviceID).setValue(0)
                currentScore = 0
                self.titleButton.setTitle("0", for: UIControlState.normal)
            } else {
                currentScore = snapshot.value as! Int
                self.titleButton.setTitle("\(currentScore)", for: UIControlState.normal)
            }
            })
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get region
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        UserDefaults.standard.set(location.coordinate.latitude as NSNumber, forKey: "lastLatitude")
        UserDefaults.standard.set(location.coordinate.longitude as NSNumber, forKey: "lastLongitude")
        currentLocation = location
        if mapRegionSet == false {
            map.setRegion(region, animated: true)
            mapRegionSet = true
        }
        
        setCurrentLocationName()
        print("UPDATED \(location)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func setCurrentLocationName() {
        CLGeocoder().reverseGeocodeLocation(currentLocation)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            if placeMark == nil {
                return
            }
            
            // Location name
            if let locationName = placeMark.addressDictionary?["Name"] as? String
            {
                currentLocationName = locationName
                UserDefaults.standard.set(locationName, forKey: "lastLocationName")
            }
        }
    }
    
    
    // --------------------------ANNOTATIONS--------------------------
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        
        
        let center = CGPoint(x: view.center.x, y: view.center.y - 2 * (self.navigationController?.navigationBar.frame.size.height)!)
        print(center)
        print(view.center)
        
        
        
        
//        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            view.center = self.view.center
            view.alpha = 0
//            view.frame.size = CGSize(width: 300, height: 300)
        }, completion: nil)
        
        annotation = view.annotation as! CustomAnnotation
        
        if annotation.post.hasPicture == true {
            print("THIS VIEW HAS A PICTURE")
            let views = Bundle.main.loadNibNamed("PhotoCallout", owner: self, options: nil)
            let calloutview = views![0] as! PhotoCalloutView
            calloutview.layer.cornerRadius = 20
            calloutview.layer.borderWidth = 5.0
            calloutview.layer.borderColor = getColor(annotation.post.upVotes!).cgColor
            calloutview.layer.masksToBounds = true
            calloutview.annotation = annotation
            calloutview.upvotesLabel.text = "\(annotation.post.upVotes!)"
            calloutview.photoView.contentMode = .scaleAspectFill
            calloutview.timestampLabel.layer.cornerRadius = 10
            calloutview.timestampLabel.layer.masksToBounds = true
            calloutview.timestampLabel.text = "  " + timeAgoSinceDate(date: calloutview.annotation.post.timestamp, numericDates: true) + "  "
            calloutview.votingView.layer.cornerRadius = 10
            calloutview.votingView.layer.masksToBounds = true
            calloutview.votingView.isHidden = true
            calloutview.timestampLabel.isHidden = true
            calloutview.locationButton.isHidden = true
            calloutview.locationButton.layer.cornerRadius = 10
            calloutview.locationButton.layer.masksToBounds = true
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
            {
                (placemarks, error) -> Void in
                
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                if placeMark == nil {
                    return
                }
                
                // Location name
                if let locationName = placeMark.addressDictionary?["Name"] as? String
                {
                    calloutview.locationButton.alpha = 0.0
                    calloutview.locationButton.setTitle("  \(locationName)  ", for: UIControlState.normal)
                    UIView.animate(withDuration: 0.2, animations: {
                        calloutview.locationButton.alpha = 1.0
                    })
                    
                }
            }
            
            let url = annotation.post.mediaURL!
            if let img = getImageFromURL(url) {
                calloutview.photoView.image = img
            } else {
                calloutview.photoView.image = UIImage()
            }

            if myVotes[annotation.post.key] == 1 {
                calloutview.upSelected = true
                calloutview.upOutlet.tintColor = getColor(annotation.post.upVotes!)
            } else if myVotes[annotation.post.key] == -1 {
                calloutview.downSelected = true
                calloutview.downOutlet.tintColor = getColor(annotation.post.upVotes!)
            }
            
            calloutview.commentsButton.addTarget(self, action: #selector(ViewController.toCrumbTableView), for: UIControlEvents.touchUpInside)
            calloutview.commentsButton.backgroundColor = getColor(annotation.post.upVotes!)
            
            calloutview.center = CGPoint(x: self.view.center.x, y: self.view.center.y*0.67)
            calloutview.alpha = 0.0
            calloutview.backgroundColor = UIColor.white
            calloutview.isUserInteractionEnabled = true
            self.view.addSubview(calloutview)
            UIView.animate(withDuration: 0.4, animations: {
                calloutview.alpha = 1.0
            })
            
            
        } else {
            let views = Bundle.main.loadNibNamed("Callout", owner: self, options: nil)
            let calloutview = views![0] as! CalloutView
            calloutview.layer.cornerRadius = 20
            calloutview.layer.borderWidth = 5.0
            calloutview.layer.borderColor = getColor(annotation.post.upVotes!).cgColor
            calloutview.layer.masksToBounds = true
            calloutview.messageLabel.text = annotation.post.message
            calloutview.upvotesLabel.text = "\(annotation.post.upVotes!)"
            calloutview.annotation = annotation
            calloutview.timestampLabel.text = timeAgoSinceDate(date: calloutview.annotation.post.timestamp, numericDates: true)
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
            {
                (placemarks, error) -> Void in
                
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                if placeMark == nil {
                    return
                }
                
                // Location name
                if let locationName = placeMark.addressDictionary?["Name"] as? String
                {
                    calloutview.locationButton.alpha = 0.0
                    calloutview.locationButton.setTitle(locationName, for: UIControlState.normal)
                    UIView.animate(withDuration: 0.2, animations: {
                        calloutview.locationButton.alpha = 1.0
                    })
                    
                }
            }
            
            if myVotes[annotation.post.key] == 1 {
                calloutview.upSelected = true
                calloutview.upOutlet.tintColor = getColor(annotation.post.upVotes!)
            } else if myVotes[annotation.post.key] == -1 {
                calloutview.downSelected = true
                calloutview.downOutlet.tintColor = getColor(annotation.post.upVotes!)
            }
            
            
            calloutview.commentsButton.addTarget(self, action: #selector(ViewController.toCrumbTableView), for: UIControlEvents.touchUpInside)
            calloutview.commentsButton.backgroundColor = getColor(annotation.post.upVotes!)
            
            
            calloutview.alpha = 0.0
            calloutview.backgroundColor = UIColor.white
            calloutview.isUserInteractionEnabled = true
//            calloutview.center = center
            calloutview.center = CGPoint(x: self.view.center.x, y: self.view.center.y - calloutview.frame.height/2 - view.frame.height/8)
            
            self.view.addSubview(calloutview)
            UIView.animate(withDuration: 0.3, animations: {
                calloutview.alpha = 1.0
                
            })
        }

    }
    
    func toCrumbTableView() {
        self.performSegue(withIdentifier: "ShowPostSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPostSegue" {
            let nextVC = segue.destination as! CrumbTableViewController
            nextVC.annotation = annotation
            self.navigationController?.navigationBar.isHidden = false
        } else if segue.identifier == "ShowClusterSegue" {
            let nextVC = segue.destination as! ClusterViewController
            nextVC.clusteredAnnotations = clusteredAnnotations
            self.navigationController?.navigationBar.isHidden = false
        } else if segue.identifier == "ShowClusterCollectionSegue" {
            let nextVC = segue.destination as! ClusterCollectionViewController
            nextVC.clusteredAnnotations = clusteredAnnotations
            self.navigationController?.navigationBar.isHidden = false
        } else if segue.identifier == "myPostsSegue"{
            self.navigationController?.navigationBar.isHidden = false
        } else {
            self.navigationController?.navigationBar.isHidden = true
        }

    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        clearCallouts()
        map.selectedAnnotations.removeAll()
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        clearCallouts()
        map.selectedAnnotations.removeAll()
    }
    
    func clearCallouts() {
        for subview in self.view.subviews
        {
            if subview.isKind(of: CalloutView.self) || subview.isKind(of: PhotoCalloutView.self){
                subview.removeFromSuperview()

//                UIView.animate(withDuration: 1.0, animations: {
//                    subview.alpha = 0.0
//                    }, completion: { void in
//                        subview.removeFromSuperview()
//                })
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if (view.annotation?.isKind(of: MKUserLocation.self))! {
                view.canShowCallout = false
                view.isEnabled = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView!.canShowCallout = false
        } else{
            annotationView?.annotation = annotation
        }
        let thisAnnotation = annotation as! CustomAnnotation
        annotationView!.image = flatAnnotationImage.imageWithColor(color1: getColor(thisAnnotation.post.upVotes))

        
        return annotationView
    }
    
    func startLoadingIndicator() {
        refreshButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopLoadingIndicator() {
        refreshButton.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // --------------------------SETUP FUNCTIONS (CALLED IN VIEW DID LOAD)--------------------------

    func setupAnnotationIconImage() {
        flatAnnotationImage = UIImage(named: "map-marker")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
    
    func setupLocationManager() {
        manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startMonitoringSignificantLocationChanges()
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.requestLocation()
    }
    
    func setupMap() {
        map.delegate = self
        map.showsUserLocation = true
        map.mapType = .satellite
        map.showsCompass = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.mapTapped))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongTap(sender:)))
        longGestureRecognizer.delegate = self
        longGestureRecognizer.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longGestureRecognizer)
        
        if UserDefaults.standard.object(forKey: "lastLongitude") != nil && UserDefaults.standard.object(forKey: "lastLatitude") != nil && UserDefaults.standard.object(forKey: "lastLocationName") != nil {
            print("successfully retrieved all user defaults")
            currentLocation = CLLocation(latitude: UserDefaults.standard.object(forKey: "lastLatitude") as! CLLocationDegrees, longitude: UserDefaults.standard.object(forKey: "lastLongitude") as! CLLocationDegrees)
            currentLocationName = UserDefaults.standard.object(forKey: "lastLocationName") as! String
            let center = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10))
            self.map.setRegion(region, animated: true)
        }
    }
    
    
    func handleLongTap(sender: UILongPressGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.ended) {
            let location = sender.location(in: map)
            let coordinate = map.convert(location,toCoordinateFrom: map)
            let radius = UIScreen.main.bounds.width/6
            let outerPoint = CGPoint(x: location.x - radius, y: location.y - radius)
            let outerPointCoord = map.convert(outerPoint, toCoordinateFrom: map)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.selectedView.alpha = 0.0
                self.selectedView.frame = CGRect(x: outerPoint.x + radius, y: outerPoint.y + radius, width: 0, height: 0)
            })
            
            let bottomRightPoint = CGPoint(x: location.x + radius, y: location.y + radius)
            let bottomRightLoc = map.convert(bottomRightPoint, toCoordinateFrom: map)
            
            let topLeft = outerPointCoord
            let bottomRight = bottomRightLoc
            let topLeftCoord = MKMapPointForCoordinate(topLeft)
            let bottomRightCoord = MKMapPointForCoordinate(bottomRight)
            let mapRect = MKMapRectMake(topLeftCoord.x, topLeftCoord.y, bottomRightCoord.x - topLeftCoord.x, bottomRightCoord.y - topLeftCoord.y)
            
            
            var annotationsInRegion = [CustomAnnotation]()
            for x in Array(map.annotations(in: mapRect)) {
                if let newAnnotation = x.base as? CustomAnnotation {
                    annotationsInRegion.append(newAnnotation)
                }
            }
            clusteredAnnotations = annotationsInRegion
            
            if clusteredAnnotations.count > 0 {
                self.performSegue(withIdentifier: "ShowClusterCollectionSegue", sender: nil)
            }
            
            
        } else if (sender.state == UIGestureRecognizerState.began) {
            orientNorth()
            let location = sender.location(in: map)
            let coordinate = map.convert(location,toCoordinateFrom: map)
            
            let radius = UIScreen.main.bounds.width/6
            
            let outerPoint = CGPoint(x: location.x - radius, y: location.y - radius)
            let outerPointCoord = map.convert(outerPoint, toCoordinateFrom: map)
            
            let span = MKCoordinateSpan(latitudeDelta: outerPointCoord.latitude - coordinate.latitude, longitudeDelta: outerPointCoord.latitude - coordinate.latitude)
            let selectedRegion = MKCoordinateRegion(center: coordinate, span: span)
            
            selectedView = UIView(frame: CGRect(x: outerPoint.x + radius, y: outerPoint.y + radius, width: 0, height: 0))
            selectedView.backgroundColor = UIColor.green
            selectedView.layer.borderWidth = 2
            selectedView.alpha = 0
            selectedView.tag = 69
            selectedView.layer.cornerRadius = 15
            selectedView.layer.masksToBounds = true
            
            map.addSubview(selectedView)
            UIView.animate(withDuration: 0.3, animations: {
                self.selectedView.alpha = 0.3
                self.selectedView.frame = CGRect(x: outerPoint.x, y: outerPoint.y, width: radius * 2, height: radius * 2)
            })
            
        } else if (sender.state == UIGestureRecognizerState.changed) {
            let location = sender.location(in: map)
            let coordinate = map.convert(location,toCoordinateFrom: map)
            let radius = UIScreen.main.bounds.width/6
            let outerPoint = CGPoint(x: location.x - radius, y: location.y - radius)
            let outerPointCoord = map.convert(outerPoint, toCoordinateFrom: map)
            
            selectedView.frame = CGRect(x: outerPoint.x, y: outerPoint.y, width: radius * 2, height: radius * 2)
        }
        
    }

    
    func mapTapped(sender: UITapGestureRecognizer? = nil) {
        print("tapped map")
        
        for subview in self.view.subviews
        {
            clearCallouts()
            map.selectedAnnotations.removeAll()
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isKind(of: CalloutView.self))! {
            return false
        } else {
            return true
        }
    }
    
    
    
    
    // ----------------------Retrieve from Database-------------------------------------------
    func getLocalMessages() {
        print("getting local messages")
        annotations.removeAll(keepingCapacity: true)
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        clearCallouts()
        
        mostUpvotes = -5
        self.annotationTuples.removeAll(keepingCapacity: true)
        startLoadingIndicator()
        let currGeoFire = GeoFire(firebaseRef: currPostsRef)
        
        let circleQuery = currGeoFire!.query(at: currentLocation, withRadius: 1000)
//        CLLocation(latitude: 42.373222, longitude: -72.519854)
        
        circleQuery!.observe(.keyEntered, with: { snapshot in
            let newTuple = (snapshot.0!, snapshot.1!)
            self.annotationTuples.append(newTuple)
        })
        
        circleQuery?.observeReady({
            var count = 0
            if self.annotationTuples.count == 0 {
                self.stopLoadingIndicator()
            }
            for tuple in self.annotationTuples {
                allPostsRef.child(tuple.0).observeSingleEvent(of: .value, with: { messageSnap in
                    count += 1
                    if let time = messageSnap.childSnapshot(forPath: "timestamp").value as? TimeInterval {
                        let date = NSDate(timeIntervalSince1970: time/1000)
                        //                    print(date.timeIntervalSinceNow < -86000) // use this to delete messages
                        let upvotes = messageSnap.childSnapshot(forPath: "upVotes").value as! Int
                        var hasPicture = false
                        if messageSnap.childSnapshot(forPath: "hasPicture").exists() {
                            hasPicture = messageSnap.childSnapshot(forPath: "hasPicture").value as! Bool
                            let mediaURL = messageSnap.childSnapshot(forPath: "mediaURL").value as! String
                            self.addAnnotationToArray(loc: tuple.1, message: messageSnap.childSnapshot(forPath: "message").value as! String, upVotes: upvotes, key: messageSnap.key, timestamp: date, hasPicture: hasPicture, mediaURL: mediaURL)
                        } else {
                            self.addAnnotationToArray(loc: tuple.1, message: messageSnap.childSnapshot(forPath: "message").value as! String, upVotes: upvotes, key: messageSnap.key, timestamp: date, hasPicture: hasPicture)
                        }
                        
                        
                        if upvotes > mostUpvotes {
                            mostUpvotes = upvotes
                        }
                        
                        if count == self.annotationTuples.count {
                            self.addAnnotationsToMap()
                            print("everything is loaded")
                            self.stopLoadingIndicator()
                        }
                    }
                })
            }
            circleQuery?.removeAllObservers()
            
        })
    }
    
    func setMessage(loc:CLLocation, message:String) {
        let randomKey = FIRDatabase.database().reference().childByAutoId()
        
        
        setNewLocation(loc: loc, baseRef: currPostsRef, key: randomKey.key)
        allPostsRef.child(randomKey.key).child("message").setValue(message)
        allPostsRef.child(randomKey.key).child("upVotes").setValue(0)
        allPostsRef.child(randomKey.key).child("deviceID").setValue(deviceID)
        allPostsRef.child(randomKey.key).child("timestamp").setValue(firebaseTimeStamp)
        
        myPostsRef.child(randomKey.key).child("timestamp").setValue(firebaseTimeStamp)
    }
    
    func addAnnotationToArray(loc:CLLocation, message:String, upVotes:Int, key:String, timestamp:NSDate, hasPicture:Bool, mediaURL:String? = nil) {
        let point = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
        let newPost = Post(key: key, message: message, upVotes: upVotes, timestamp: timestamp, hasPicture: hasPicture, mediaURL: mediaURL)
        point.post = newPost
        annotations.append(point)
    }
    
    func addAnnotationsToMap() {
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        for annotation in annotations {
            self.map.addAnnotation(annotation)
        }
    }
    
    func orientNorth() {
        map.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
        map.setUserTrackingMode(MKUserTrackingMode.none, animated: false)
    }
    
    func logSession() {
        logSessionRef.child(deviceID).childByAutoId().setValue(firebaseTimeStamp)
    }
    
    @IBAction func refreshTapped(_ sender: AnyObject) {
        getLocalMessages()
    }
    
    func updateTitle(notification: Notification) {
        self.titleButton.setTitle("\(currentScore)", for: UIControlState.normal)
    }
    


}

