//
//  Extensions.swift
//  Messager
//
//  Created by 陆敏慎 on 11/10/20.
//

import Foundation

extension Date {
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
