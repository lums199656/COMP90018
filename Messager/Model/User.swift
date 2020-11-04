//
//  User.swift
//  Messager
//
//  Created by 陆敏慎 on 24/9/20.
//
// 将 Firebase 的 User 数据库转成 User 对象

import Foundation
import Firebase
import FirebaseFirestoreSwift


// 创建 struct，并且需要遵循两个 protocal：Codable, Equatable
// Codable： 数据库储存的都是 json 格式，将 User 映射到数据库
// Equatable： encoding 和 decoding 的作用，判断两个 user 是否一样

// 用户信息
struct User: Codable, Equatable {
    
    var id = ""
    var username: String = ""
    var email: String = ""
    var pushId = ""
    var avatarLink = ""
    var status: String = ""
    var location = ""
    var intro = ""
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        // 如果有用户登陆
        if Auth.auth().currentUser != nil {
            // 如果 userDefault 有储存东西，则存入 dictionary
            // kCURRENTUSER 为存放在 Constants.swift 中的全局变量
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER){
                let decoder = JSONDecoder()
                do{
                    // 将 dictionary 中的数据加载到 User 中
                    // userObject 就是 User 的实例，也就是 User.self
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    kCURRENTUSERNAME = userObject.username
                    return userObject
                }catch{
                    print("Error decoding user fron user defaults!", error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    
    static func isSameUser (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
}

// 将 User 实例转成 dictionary
func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    }catch{
        print("error saving user locally ", error.localizedDescription)
    }
}

func createDummyUsers() {
    let names = ["A", "B", "C", "D", "E", "F"]
    for i in 0..<5 {
        let id = UUID().uuidString
        let user = User(id: id, username: names[i], email: "user\(i)@gmail.com", pushId: "", avatarLink: "", status: "No Status!")
        FirebaseUserListener.shared.saveUserToFireStore(user)
    }
    print("创建用户完成！")
}



