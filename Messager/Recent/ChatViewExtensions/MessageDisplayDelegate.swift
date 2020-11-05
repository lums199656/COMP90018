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
        if mkMessages[indexPath.section].surprise {
            return  UIColor(named: "chatIncomingColor")!
        }
        return isFromCurrentSender(message: message) ? UIColor(named: "chatIncomingColor")! : UIColor(white: 0, alpha: 1 )
    }
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if mkMessages[indexPath.section].surprise {
            return UIColor(named: "suprise")!
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
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let starterVC = storyboard.instantiateViewController(identifier: "OtherUserVC") as OtherUserViewController
        starterVC.currentUserID = message.sender.senderId
        print(cell.description)
        self.navigationController!.show(starterVC, sender: self)
    }
    
    
}
