//
//  FeedData.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/8.
//

import Foundation

//需要的信息
struct FeedData {
    let detail, title, uid, user: String?
    let image: String?
    var join: [String]!
    // let star: Bool
    let category: String!
    let locationString: String!
    let distance: Int!
    let groupSize: Int!
    let endDate: String!
}
