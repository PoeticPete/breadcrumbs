//
//  Post.swift
//  Breadcrumbs 2.0
//
//  Created by Peter Tao on 10/30/16.
//  Copyright © 2016 Poetic Pete. All rights reserved.
//

import Foundation

struct Post {
    var key:String!
    var message: String!
    var upVotes: Int!
    var timestamp: NSDate!
    var hasPicture: Bool!
    var mediaURL: String?
    
    init(key:String, message:String, upVotes:Int, timestamp:NSDate, hasPicture:Bool!, mediaURL:String? = nil) {
        self.key = key
        self.message = message
        self.upVotes = upVotes
        self.timestamp = timestamp
        self.hasPicture = hasPicture
        self.mediaURL = mediaURL
    }
    
}
