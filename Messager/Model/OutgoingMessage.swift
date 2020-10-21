//
//  OutgoingMessage.swift
//  Messager
//
//  Created by 陆敏慎 on 18/10/20.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class OutgoingMessage {

    
    class func send(chartId: String, text: String, photo: UIImage?, video: String?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chartId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        if text != nil {
            // send text message
            sendTextMessage(message: message, text: text, memberIds: memberIds)
            FirebaseRecentListener.shared.updateRecents(chatRoomId: chartId, lastMessage: text)
        }
        
        // 更新 recent
    }
    // 发送推送
    class func sendMessage(message: LocalMessage, memberIds: [String]) {
        
        // 保存在本地
        RealmManager.shared.saveToRealm(message)
        
        for memberId in memberIds {
//            print("_x save message for \(memberId)")
            // 保存在 firebase
            print("_x-7 将新信息保存给", memberId)
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
}


func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    message.message = text
    message.type = kTEXT
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    
}
