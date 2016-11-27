//
//  ClusterViewController.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 11/13/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import UIKit

class ClusterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var clusteredAnnotations = [CustomAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clusteredAnnotations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if clusteredAnnotations[indexPath.row].post.hasPicture == true {
            if let img = getImageFromURL(clusteredAnnotations[indexPath.row].post.mediaURL!) {
                return UIScreen.main.bounds.width * img.size.height / img.size.width
            } else {
                return 50
            }
            
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisAnnotation = clusteredAnnotations[indexPath.row]
        if thisAnnotation.post.hasPicture == true {
            var cell = tableView.dequeueReusableCell(withIdentifier: "PhotoClusterCell") as! PhotoClusterTableViewCell
            
            cell.photo.image = getImageFromURL(thisAnnotation.post.mediaURL!)
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "ClusterCell") as! ClusterTableViewCell
            cell.messageLabel.text = clusteredAnnotations[indexPath.row].post.message
            return cell
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(clusteredAnnotations[indexPath.row].post)
        performSegue(withIdentifier: "ClusterToCrumbSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClusterToCrumbSegue" {
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
