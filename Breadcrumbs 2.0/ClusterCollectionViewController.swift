//
//  ClusterCollectionViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 11/14/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class ClusterCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var clusteredAnnotations = [CustomAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clusteredAnnotations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width/3 - 0
        
        return CGSize(width: width, height: width)
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let annotationPost = clusteredAnnotations[indexPath.row].post!
        if annotationPost.hasPicture == true {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoClusterCell", for: indexPath) as! PhotoCollectionViewCell
            cell.photo.image = getImageFromURL(annotationPost.mediaURL!)
            
            return cell
        } else {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageClusterCell", for: indexPath) as! TextClusterCollectionViewCell
            cell.messageLabel.text = annotationPost.message
            
            return cell
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ClusterCollectionToCrumbSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClusterCollectionToCrumbSegue" {
            var nextVC = segue.destination as! CrumbTableViewController
            let indexPath = sender as! Int
            nextVC.annotation = clusteredAnnotations[indexPath]
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
