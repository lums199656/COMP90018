//
//  MessageLayoutDelegate.swift
//  Messager
//
//  Created by 陆敏慎 on 17/10/20.
//

import Foundation
import MessageKit

// 聊天 cell 的样式
extension ChatViewController: MessagesLayoutDelegate {
    // top label 的高
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //MARK: - Cell top label
            
        if indexPath.section % 10 == 0 {

            return 18
        }
        
        return 0
        

    }
//
//    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        return UIColor(named: "chatOutgoingColor")
//    }
//    
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        // 是否是自己发的
        return isFromCurrentSender(message: message) ? 17 : 17
//        return indexPath.section != mkMessages.count - 1 ? 0 : 10
    }
    

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
       
        if indexPath.section % 10 == 0 {
            return 18
        }
        
        return 0
    }

    
    // 设置头像
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // 将首字母作为头像
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))

    }
    
}
