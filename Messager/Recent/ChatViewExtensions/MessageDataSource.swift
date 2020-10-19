//
//  MessageDataSource.swift
//  Messager
//
//  Created by 陆敏慎 on 17/10/20.
//

import Foundation
import MessageKit

// 返回聊天框需要的数据
extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
         return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        // 返回每一行的信息
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return mkMessages.count
    }
    
    // cell 上方的 labels
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // 每 10 条显示一个时间
        if indexPath.section % 10 == 0 {
            let showLoadMore = false
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor(named: "chatOutgoingColor") : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        
        return nil
    }
    
    // cell 下方的 labels
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + message.readData.time() : ""
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.systemGray
            
            return NSAttributedString(string: status, attributes: [.font : font, .foregroundColor: color])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section != mkMessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            
            return NSAttributedString(string: message.sentDate.time(), attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor : UIColor.darkGray])
        }
        
        return nil
    }
}
