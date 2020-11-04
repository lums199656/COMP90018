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

    
    class func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
//        message.senderName = currentUser.username
        message.senderName = kCURRENTUSERNAME
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        
        if text != nil {
//            sendTextMessage(message: message, text: text ?? "ERROR", memberIds: memberIds)
            sendTextMessage(message: message, text: text ?? "ERROR", memberIds: memberIds)

        }
        
//        if photo != nil {
//            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
//        }
//
//        if video != nil {
//            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
//        }
//
//        if location != nil {
//            sendLocationMessage(message: message, memberIds: memberIds)
//        }
        
        if audio != nil {
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
        
        // 更新 recent
    }
    
    class func sendSuprise(chatId: String, text: String?, memberIds: [String]) {
        let currentUser = User.currentUser!
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        
        if let text = text {
            sendSupriseMessage(message: message, text: text, memberIds: memberIds)
        }
        
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
        
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
    
    class func sendChannelMessage(message: LocalMessage, channel: Channel) {
        
        RealmManager.shared.saveToRealm(message)
        FirebaseMessageListener.shared.addChannelMessage(message, channel: channel)
    }
}


func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    message.message = text
    message.type = kTEXT
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    
}

fileprivate func sendSupriseMessage(message: LocalMessage, text: String, memberIds: [String]) {
    message.message = text
    message.type = kTEXT
    message.surprise = true
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    
}

func addChannelMessage(_ message: LocalMessage, channel: Channel) {
    
    do {
        let _ = try FirebaseReference(.Messages).document(channel.id).collection(channel.id).document(message.id).setData(from: message)
    }
    catch {
        print("error saving message ", error.localizedDescription)
    }
}

func sendAudioMessage(message: LocalMessage, audioFileName: String, audioDuration: Float, memberIds: [String], channel: Channel? = nil) {

    message.message = "Audio message"
    message.type = kAUDIO
    
    let fileDirectory =  "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_\(audioFileName)" + ".m4a"
    
    print("_x-27 准备上传音频")
    FileStorage.uploadAudio(audioFileName, directory: fileDirectory) { (audioUrl) in
        
        if audioUrl != nil {
            
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
            
            if channel != nil {
                OutgoingMessage.sendChannelMessage(message: message, channel: channel!)
            } else {
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }
    }
    print("_x-28 结束上传音频")
    
}

