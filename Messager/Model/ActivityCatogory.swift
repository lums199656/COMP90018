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
    static func tmpLoadCurrent() -> [ActivityCategory] {
        var categories: [ActivityCategory] = []
        for c in Activity.Catogory.allCases {
            if Int.random(in: 1...6) > 3 {
                categories.append(ActivityCategory(name: c.rawValue))
            }
        }
        return categories
    }
}
