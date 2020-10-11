//
//  StartChat.swift
//  Messager
//
//  Created by 陆敏慎 on 11/10/20.
//

import Foundation

func startChat(user1: User, user2: User) -> String {
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    return chatRoomId
}

func createRecentItems(chatRoomId: String, users: [User]) {
    // 用户是否已经有 recent chat
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments{ (snapshot, error) in
        
    }
}

// 确保两个 user 无论顺序如何都只能生成同一个 roomId
func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    
    // 拼接字符串
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    
    return chatRoomId
}
