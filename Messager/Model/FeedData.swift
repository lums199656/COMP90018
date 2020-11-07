//
//  FeedData.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/8.
//

import Foundation

//需要的信息
struct FeedData {
    var detail, title, uid, user: String?
    var image: String?
    var join: [String]!
    // let star: Bool
    var category: String!
    var locationString: String!
    var distance: Int!
    var groupSize: Int!
    var endDate: String!
}
