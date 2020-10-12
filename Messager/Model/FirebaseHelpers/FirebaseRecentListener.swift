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
    
    func addRecent(_ recent: RecentChat) {
        do {
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }catch{
            print("Error saving recent chat", error.localizedDescription)
        }
    }
}
