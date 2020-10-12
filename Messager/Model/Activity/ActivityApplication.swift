//
//  ActivityApplication.swift
//  Messager
//
//  Created by Boyang Zhang on 7/10/20.
//

import Foundation



struct ActivityApplication {
    
    
    let uid: String          // uid of application
    let applicantId: String  // uid of application owner
    let activityId: String   // uid of activity
    let status: Status       //
    
    enum Status {
        case pending, approved, declined, abolished
        // declined by activity owner
        // abolished by activity applicant
    }

    
}
