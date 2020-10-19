//
//  FCollectionReferences.swift
//  Messager
//
//  Created by 陆敏慎 on 3/10/20.
//
// 用来获取 Firebase 中的 Folder

import Foundation
import FirebaseFirestore

// 用来映射 folder名 和 folder对象
enum FCollectionReference: String {
    case User
    case Recent
    case Messages
}

// 输入一个 firebase 的 folder 名，输出一个 folder 对象。
func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
