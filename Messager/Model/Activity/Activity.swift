//
//  Activity.swift
//  Messager
//
//  Created by Boyang Zhang on 7/10/20.
//

import Foundation

struct Activity {
    let uid: String      // uid of the application
    let userId: String   // uid of the activity initiator
    let likeCount: Int = 0  // number of likes
    let shareCount: Int = 0 // number of share to others..
    
    var pendingApp: [String] = [] // array of uid of activity_application
    var approvedApp: [String] = [] // array of uid of activity_application
    
    
}
