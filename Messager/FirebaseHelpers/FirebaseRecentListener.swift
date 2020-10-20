//
//  FirebaseRecentListener.swift
//  Messager
//
//  Created by 陆敏慎 on 11/10/20.
//
import Foundation
import Firebase

class FirebaseRecentListener {
    static let shared = FirebaseRecentListener()
    var typingListener: ListenerRegistration!

    
    private init() {
        
    }
    
    func downloadRecentChatFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void){
        
        // 这个 Listener 可以在数据库更新数据的时候，端自动收到消息
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener{ (querysnapshot, error) in
            var recentChat: [RecentChat] = []
            guard let documents = querysnapshot?.documents else {
                print("No Documents")
                return
            }
            // 把 firebase 上的数据加载到 recent 对象
            let allRecents = documents.compactMap{(queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecents {
                // 没有讲过话的不会显示
                if recent.lastMessage != "" {
                    recentChat.append(recent)
                }
            }
            recentChat.sort(by: { $0.date! > $1.date! })
            completion(recentChat)
        }
    }
    
    func saveRecent(_ recent: RecentChat) {
        do {
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }catch{
            print("Error saving recent chat", error.localizedDescription)
        }
    }
    
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
    
    
    // 通过 message 更新 recent
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
        print("_x update recent")
        var tmpRecent = recent
        
        if !tmpRecent.senderId.contains(User.currentId) {
            tmpRecent.unreadCounter += 1

        }
            
//        if tmpRecent.senderId != User.currentId {
//            tmpRecent.unreadCounter += 1
//        }
//        
        tmpRecent.lastMessage = lastMessage
        tmpRecent.date = Date()
        
        self.saveRecent(tmpRecent)
    }
    
    
    
    func clearUnreadCounter(recent: RecentChat) {
        var newRecent = recent
        newRecent.unreadCounter = 0
        self.saveRecent(newRecent)
    }
    
    func resetRecentCounter(chatRoomId: String) {
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments{ (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("no documents recent")
                return
            }
            let allRecents = documents.compactMap{(QueryDocumentSnapshot) -> RecentChat? in
                return try? QueryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!)
                
            }
            
        }
    }
    
    // 删除一个 chat
    func deleteRecent(_ recent: RecentChat) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }
}
