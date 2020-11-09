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
//        print("_x-4 mkMessages 数目：", mkMessages.count)
        return mkMessages.count
    }
    
    // cell 上方的 labels
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if mkMessages[indexPath.section].surprise {
            // u 仔的 suprise
//            print("_x-38 该显示 suprise 了")
            let text = "- SURPRISE -"
            let font = UIFont.systemFont(ofSize: 13)
            let color = UIColor(named: "chatOutgoingColor")
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
            
        } else if indexPath.section % 10 == 0 {
            // 每 10 条显示一个时间

            // 下拉加载
            let showLoadMore = ((indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount))
            var text = ""
            if indexPath.section == 0 {
                text = showLoadMore ? "- PULL TO LOAD MORE -" : "- THE END -"
            } else {
                text = MessageKitDateFormatter.shared.string(from: message.sentDate)
            }
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor(named: "chatOutgoingColor") : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let font = UIFont.boldSystemFont(ofSize: 10)
        let color = UIColor.darkGray
        let displayName = displayNames[message.sender.senderId] ?? String(message.sender.displayName)
        return NSAttributedString(string: displayName, attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor : UIColor.darkGray])
    }
    
//    // cell 下方的 labels
//    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        if isFromCurrentSender(message: message) {
//            let message = mkMessages[indexPath.section]
//            let status =  message.readData.time()
//            let font = UIFont.boldSystemFont(ofSize: 10)
//            let color = UIColor.systemGray
//
//            return NSAttributedString(string: status, attributes: [.font : font, .foregroundColor: color])
//        }
//        return nil
//    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let font = UIFont.boldSystemFont(ofSize: 10)
        let color = UIColor.darkGray
        let text = MessageKitDateFormatter.shared.string(from: message.sentDate)
//        let text = message.sentDate.time()
        return NSAttributedString(string:text, attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor : UIColor.darkGray])
        
        return nil
    }
    

}
