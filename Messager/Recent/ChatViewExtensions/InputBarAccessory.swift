//
//  InputBarAccessory.swift
//  Messager
//
//  Created by 陆敏慎 on 17/10/20.
//

import Foundation
import InputBarAccessoryView

// 检测聊天内容的输入
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    // 检测正在输入的状态
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        updateMicButtonStatus(show: text == "")
    }
    
    // 点击发送按钮
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // 寻找所有关于 input 的组件，检查是否有 text
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        
        // 清空输入框
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
