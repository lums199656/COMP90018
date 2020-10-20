//
//  StartChat.swift
//  Messager
//
//  Created by 陆敏慎 on 11/10/20.
//

import Foundation
import Firebase

// 创建群聊
func startChat(users: [User]) -> String {
    var userIds : [String] = []
    for user in users {
        userIds.append(user.id)
    }
    let chatRoomId = chatRoomIdFrom(userIds: userIds)
    createRecentGroupItems(chatRoomId: chatRoomId, users: users, userIds: userIds)
    return chatRoomId
}

func startChat(user1: User, user2: User) -> String {
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    return chatRoomId
}

func createRecentGroupItems(chatRoomId: String, users: [User], userIds: [String]) {
    
    var memberIdsToCreateRecent = userIds
    print("_x Creating Group: ")
    for i in users {
        print("_x ", i.username)
    }
    // 用户是否已经有 recent chat
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments{ (snapshot, error) in
        
        guard let snapshot = snapshot else {return}
        if !snapshot.isEmpty {
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
        }
        for userId in memberIdsToCreateRecent {
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            
            let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser!
            
            let recentObject = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
        
            FirebaseRecentListener.shared.saveRecent(recentObject)
        }
    }
}

func createRecentItems(chatRoomId: String, users: [User]) {
    
    var memberIdsToCreateRecent = [users.first!.id, users.last!.id]

    // 用户是否已经有 recent chat
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments{ (snapshot, error) in
        
        guard let snapshot = snapshot else {return}
        if !snapshot.isEmpty {
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
        }
        print("_x", memberIdsToCreateRecent)
        for userId in memberIdsToCreateRecent {
            print("_x create recent for id: ", userId)
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            
            let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser!
            
            let recentObject = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
        
            FirebaseRecentListener.shared.saveRecent(recentObject)
        }
    }
}

func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String]{
    
    var memberIdsToCreateRecent = memberIds
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[kSENDERID] {
            if memberIdsToCreateRecent.contains(currentUserId as! String) {
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    return memberIdsToCreateRecent
}

// 确保两个 user 无论顺序如何都只能生成同一个 roomId
func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    
    // 拼接字符串
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    
    return chatRoomId
}

// 群聊的 rooId
func chatRoomIdFrom(userIds : [String]) -> String {
    let sortedUserIds = selectSort(userIds)
    var chatRoomId = ""
    for i in sortedUserIds {
        chatRoomId += i
    }
    return chatRoomId
}

func selectSort(_ arr : [String]) -> [String] {
    var arr = arr
    for i in 0 ..< arr.count{
        var minIndex = i
        for j in i ..< arr.count{
            if arr[j].compare(arr[minIndex]).rawValue < 0 {
                minIndex = j
            }
        }
        (arr[i] , arr[minIndex]) = (arr[minIndex] , arr[i])
    }
    return arr
}

// 当另一方把 recent 删除时，我方点击对话框时，在数据库会为对方新创建一个 recent
func restartChat(chatRoomId: String, memberIds: [String]) {
    FirebaseUserListener.shared.downloadUsersFromFirebase(withIds: memberIds) { (users) in
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}
