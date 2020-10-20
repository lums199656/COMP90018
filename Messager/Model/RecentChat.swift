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
    var senderId : [String] = [""]
    var senderName : [String] = [""]
    var receiverId = ""
    var receiverName = ""
    @ServerTimestamp var date = Date()
    var memberIds: [String] = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
}
