//
//  StartChat.swift
//  Messager
//
//  Created by 陆敏慎 on 11/10/20.
//

import Foundation
import Firebase

// 开始一个 chat
func startChat(users: [User], activityId: String, activityTitle: String) -> String {
    var isActivity = true
    var chatRoomId: String
    if activityId == "O" {
        chatRoomId = chatRoomIdFrom(users: users)
        isActivity = false
    }else if activityId == "N" {
        chatRoomId = UUID().uuidString
    }else{
        chatRoomId = activityId
    }
    
//    let chatRoomId = chatRoomIdFrom(users: users)
    print("_x-1 chatRoomId", chatRoomId)
    createRecentItems(chatRoomId: chatRoomId, users: users, isActivity: isActivity, activityTitle: activityTitle)
    return chatRoomId
}


func createRecentItems(chatRoomId: String, users: [User], isActivity: Bool, activityTitle: String) {
    
    var memberIdsToCreateRecent : [String] = []
    for i in users {
        memberIdsToCreateRecent.append(i.id)
    }
    
    var allMembersIds : [String] = []
    var allMembersNames : [String] = []

    for i in users {
        allMembersIds.append(i.id)
        allMembersNames.append(i.username)
    }
    

    // 得到当前 chatroomId 下的所有 userId
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments{ (snapshot, error) in
        
        guard let snapshot = snapshot else {return}
        if !snapshot.isEmpty {
            // 得到需要建立 chat 但是 Recent 里没有数据的 userId
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
        }
        
        // 为数据库没有数据的 Id 加入数据
        for userId in memberIdsToCreateRecent {
            
            let senderUser = getSenderFrom(users: users, target: userId)
            
            if senderUser != nil {
                let receiverUser = getReceiverFrom(users: users, target: senderUser!)
                
                var receiverUserNames : [String] = []
                var receiverUserIds : [String] = []
                
                for i in receiverUser {
                    receiverUserNames.append(i.username)
                    receiverUserIds.append(i.id)
                }
                print("_x-3 sender: \(senderUser!.username), receivers: \(receiverUserNames)")
                
                let recentObject = RecentChat(id: UUID().uuidString,
                                              chatRoomId: chatRoomId,
                                              senderId: senderUser!.id,
                                              senderName: senderUser!.username, receiverId: receiverUserIds,
                                              receiverName: receiverUserNames, date: Date(),
                                              memberIds: allMembersIds, lastMessage: "",
                                              unreadCounter: 0,
                                              avatarLink: senderUser!.avatarLink,
                                              isActivity: isActivity,
                                              activityTitle: activityTitle)
            
            // 头像这里还没改 ！！！！！！！！！！！！
            FirebaseRecentListener.shared.saveRecent(recentObject)
                
            }else{
                print("Snender 不存在")
            }
        }
    }
}

func getSenderFrom (users: [User], target: String) -> User? {
    
    for i in users {
        if i.id == target {
            return i
        }
    }
    return nil
}

func getReceiverFrom(users: [User], target: User) -> [User] {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: target)!)
    return allUsers
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

// 确保多个 user 无论顺序如何都只能生成同一个 roomId
func chatRoomIdFrom(users: [User]) -> String {
    var chatRoomId = ""
    var userIds : [String] = []
    for i in users {
        userIds.append(i.id)
    }
    userIds = selectSort(userIds)
    
    for i in userIds {
        chatRoomId += i
    }
    return chatRoomId
}

// 排序字符串
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
func restartChat(chatRoomId: String, memberIds: [String], isActivity: Bool, activityTitle: String) {
    FirebaseUserListener.shared.downloadUsersFromFirebase(withIds: memberIds) { (users) in
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users, isActivity: isActivity, activityTitle: activityTitle)
        }
    }
}
