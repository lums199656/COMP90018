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
    
//    var photoMessage: PhotoMessage
    
    var status: String
    var readData: Date
    
    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
//        switch message.type {
//        case pattern:
//        default:
//        }
        
        self.senderInitials  = message.senderInitials
        self.sentDate = message.date
        self.readData = message.readDate
        self.incoming = User.currentId != mkSender.senderId
        
    }
}
