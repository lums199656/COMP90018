//
//  RecentChat.swift
//  Messager
//
//  Created by 陆敏慎 on 10/10/20.
//
import Foundation
import FirebaseFirestoreSwift

struct RecentChat: Codable {
    var id = ""
    var chatRoomId = ""
    var senderId = "" // 当前登陆用户
    var senderName = ""
    var receiverId : [String] = [] // 发送给的用户
    var receiverName : [String] = []
    @ServerTimestamp var date = Date()
    var memberIds: [String] = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    var isActivity = false
    var activityTitle = "Squad Up"
}
