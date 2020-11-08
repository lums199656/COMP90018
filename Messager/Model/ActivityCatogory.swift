//
//  ActivityCatogory.swift
//  Messager
//
//  Created by Boyang Zhang on 18/10/20.
//

import Foundation

struct ActivityCategory {
    let name: String
    
    
    static func load() -> [ActivityCategory] {
        var categories: [ActivityCategory] = []
        for c in Activity.Catogory.allCases {
            categories.append(ActivityCategory(name: c.rawValue))
        }
        
        return categories
    }
    
    
    
    // TODO: tmpLoadCurrent() 之后改成从 CoreData或者Firebase拉数据
    
    // TODO: Not formal struct
    struct Current {
        var title: String
        var detail: String
        var location: String
        var imageId: String?
    }
    
    static func tmpLoadCurrent() -> [Current] {
        
        var current: [Current] = []
        
        current.append(Current(title: "BBQ&Hot Pot", detail: "Get some great bbq & chines hot pot at NO. 1 and meet new friends!", location: "83 Franklin Street Melbourne"))
        current.append(Current(title: "DOGs Party!", detail: "Make some new friends for both you and your dog!", location: "Clayton Reserve, North Melbourne"))
        current.append(Current(title: "KARAOKE NIGHT", detail: "Party and Sing Karaoke like a Rock Star!", location: "Ichi Ni Nana, 127 Brunswick Street, Melbourne"))
        current.append(Current(title: "Online Reading Club", detail: "Keep reading makes you a better person. Everyone will share a book they read this week.", location: "Online"))
        
        for i in 0...3 {
            current[i].imageId = "act\(i+12)"
        }
        
        
        return  current
    }
}
