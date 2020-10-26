//
//  FirebaseUserListener.swift
//  Messager
//
//  Created by 陆敏慎 on 3/10/20.
//
// 监听 app 产生的关于 User 的事件

import Foundation
import Firebase

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init () {
        
    }
    
//    注册流程：
//    1. 通过 Firesbase 自带组件 Auth 在 Authentication 表中增加用户数据
//    2. 给用户发验证邮件
//    3. 保存用户信息在本地
//    4. 在 Firestore 表创建详细的用户信息
    
    // 闭包是包含一些表达式的代码块，如果希望在函数 return 后也能使用的话则需要加上 @escaping() 使其变成「逃逸闭包」
    // 闭包中的 A in B 表达的是，在 A 的条件下执行 B
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        // 在 auth 创造一个 user
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            completion(error)
            if error == nil {
                
                // 发送验证邮件
                authDataResult!.user.sendEmailVerification { (error) in
                    print("auth email sent with error: ", error?.localizedDescription)
                }
                
                // 创建 user 并且保存在本地
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hello World!", location: "", intro: "")
                    
                    // 保存 user 信息在本地
                    saveUserLocally(user)
                    
                    // 保存 user 信息在 firestore
                    self.saveUserToFireStore(user)
                }
            }
        }
    }
    
    func saveUserToFireStore(_ user: User) {
        do {
            // 把 user 转化成 key-value
            try FirebaseReference(.User).document(user.id).setData(from: user)
            print("Added To Firebase!")
        }catch{
            print(error.localizedDescription, "adding user")
        }
    }
    
//    登陆流程：
//    1. 通过 Firesbase 自带组件 Auth 登陆
//    2. 如果 Firestore 能验证邮箱和密码则不返回 error， 否则则返回 error
//    3. 并在本地保存登录用户的信息
    
    func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil && authDataResult!.user.isEmailVerified {
                // 登陆成功后把之前本地缓存的 user 更新
                FirebaseUserListener.shared.downLoadUserFromFirebase(userId: authDataResult!.user.uid, email:email)
                completion(error, true)
            }else{
                print("email is not verified!")
                completion(error, false)
            }
        }
    }
    
    func downLoadUserFromFirebase(userId: String, email: String? = nil) {
        // 在 Firestore 中 的 User Folder 得到 key 为 userId 的 json 数据
        FirebaseReference(.User).document(userId).getDocument{(querySnapshot, error) in
            guard let document = querySnapshot else {
                print("no document for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result{
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                }else{
                    print("Document does not exist!")
                }
            case .failure(let error):
                print("Error decoding user", error)
            }
        }
    }
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            
            completion(nil)
        }catch{
            completion(error)
        }
    }
    
    // 下载所有用户信息
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void) {
        var users: [User] = []
        
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            guard let docment = querySnapshot?.documents else {
                print("No documents!")
                return
            }
            // 下载 all users
            let allUsers = docment.compactMap{ (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            
            completion(users)
        }
    }
    
    // 根据 ID 下载用户信息
    func downloadUsersFromFirebase(withIds: [String] , completion: @escaping (_ allUsers: [User]) -> Void){
        var usersArray: [User] = []
        var count = 0
        for userId in withIds {
            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
                guard let docment = querySnapshot else {
                    print("No documents!")
                    return
                }
                let user = try? docment.data(as: User.self)
                usersArray.append(user!)
                count += 1
                
                if count == withIds.count {
                    completion(usersArray)

                }
            }
        }
    }
}
