//
//  MessageDisplayDelegate.swift
//  Messager
//
//  Created by 陆敏慎 on 17/10/20.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? UIColor(named: "chatIncomingColor")! : UIColor(white: 0, alpha: 1 )
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if mkMessages[indexPath.section].surprise {
            return isFromCurrentSender(message: message) ? UIColor(named: "suprise")! : UIColor(white: 0.8, alpha: 0.5 )
        }
        return isFromCurrentSender(message: message) ? UIColor(named: "chatOutgoingColor")! : UIColor(white: 0.8, alpha: 0.5 )
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if mkMessages[indexPath.section].surprise {
            return .bubble
        }
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("_x-40 点击了头像")
    }
    
}
