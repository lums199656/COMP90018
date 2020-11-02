//
//  MKMessage.swift
//  Messager
//
//  Created by 陆敏慎 on 17/10/20.
//

import Foundation
import MessageKit
import CoreLocation


// 一条 message 的结构
class MKMessage: NSObject, MessageType {
    
    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var incoming: Bool
    var senderInitials: String
    
    var audioItem: AudioMessage?
    
//    var photoMessage: PhotoMessage
    
    var status: String
    var readData: Date
    var surprise: Bool
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
//        self.kind = MessageKind.text(message.message)
        
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
        case kAUDIO:
            let audioItem = AudioMessage(duration: 2.0)
            
            self.kind = MessageKind.audio(audioItem)
            self.audioItem = audioItem
        default:
            self.kind = MessageKind.text(message.message)
            print("unknown message type")
        }
        
//        switch message.type {
//        case pattern:
//        default:
//        }
        
        self.senderInitials  = message.senderInitials
        self.sentDate = message.date
        self.readData = message.readDate
        self.incoming = User.currentId != mkSender.senderId
        self.surprise = message.surprise
        
    }
}
