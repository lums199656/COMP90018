//
//  LikeBtn.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/31.
//

//check like btn select or not for a user
import Foundation
import RealmSwift

class LikeBtn: Object, Codable{
    @objc dynamic var id = ""
    @objc dynamic var user = ""
    @objc dynamic var select = false
    //@objc dynamic var select1 = false
}
