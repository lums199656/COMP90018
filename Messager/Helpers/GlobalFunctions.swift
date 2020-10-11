//
//  GlobalFunctions.swift
//  Messager
//
//  Created by 陆敏慎 on 10/10/20.
//

import Foundation

func timeElapsed(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)
    
    var elapsed = ""
    
    if seconds < 60 {
        elapsed = "Just now"
    }else if seconds < 60 * 60{
        let minutes = Int(seconds/60)
        let minText = minutes > 1 ? "mins" : "min"
        elapsed = "\(minutes) \(minText)"
    }else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds/60/60)
        let hourText = hours > 1 ? "hours" : "hour"
        elapsed = "\(hours) \(hourText)"
    } else {
        elapsed = date.longDate()
    }
    
    return elapsed
}
