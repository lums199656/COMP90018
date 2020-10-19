//
//  MessgaeKitDefaults.swift
//  Messager
//
//  Created by 陆敏慎 on 17/10/20.
//

import Foundation
import UIKit
import MessageKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    static let bubbleColorOutgoing = UIColor(named: "chatOutgoingBubble")
    static let bubbleColorIngoing = UIColor(named: "chatIncomingBubble")
}
