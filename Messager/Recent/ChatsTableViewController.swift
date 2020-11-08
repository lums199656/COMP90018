//
//  ChatsTableViewController.swift
//  Messager
//
//  Created by 陆敏慎 on 11/10/20.
//

import UIKit
import Firebase
import FirebaseUI


class ChatsTableViewController: UITableViewController {
    
    
    var allRecents: [RecentChat] = []
    var filteredRecents: [RecentChat] = []
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 底板是 tableview
        print("_x ChatView")
        tableView.tableFooterView = UIView()
        downloadRecentChats()
        // 增加下拉更新的功能
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        self.setupSearchController()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // toggle tabbar
        print("😡")
        if let vcp = self.navigationController?.parent as? TabViewController {
            print("😃")
            vcp.showTabBar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // toggle tabbar
        print("😡 Chat Table View Will Disappear")
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? filteredRecents.count : allRecents.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        // Configure the cell...
        cell.configure(recent: recent)
        return cell
    }
    
    // 给每一行增加 修改功能
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中一行 cell
        tableView.deselectRow(at: indexPath, animated: true)
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        // go to chatroom
        FirebaseRecentListener.shared.clearUnreadCounter(recent: recent)
        goToChat(recent: recent, isActivity: recent.isActivity)
    }

    
    // 判定功能
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
            FirebaseRecentListener.shared.deleteRecent(recent)
            
            searchController.isActive ? self.filteredRecents.remove(at: indexPath.row) : allRecents.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func refreshRecentInfo() {
        print("_x-80 重新加载消息信息")
        var index = 0
        let db = Firestore.firestore()
        for recent in allRecents {
            if !recent.isActivity {
                let userInfo = db.collection("User")
                let userId = recent.receiverId[0]
                let query = userInfo.whereField("id", isEqualTo: userId)
                query.getDocuments { [self] (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        let storage = Storage.storage()
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let image = data["avatarLink"] as! String
                            let displayName = data["username"] as! String
                            displayNames[userId] = displayName
                            let cloudFileRef = storage.reference(withPath: "user-photoes/"+image)
                            cloudFileRef.getData(maxSize: 100 * 1024 * 1024) { data, error in
                                if let error = error {
                                    avatars[userId] = nil
                                } else {
                                    
                                    let avatar = UIImage(data: data!)
                                    avatars[userId] = avatar
                                    self.allRecents[index].activityTitle = displayName
                                    self.allRecents[index].avatarLink = image
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func downloadRecentChats() {
        FirebaseRecentListener.shared.downloadRecentChatFromFireStore { (allChats) in
            self.allRecents = allChats
            self.refreshRecentInfo()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // 刷新 recent
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing {
            self.downloadRecentChats()
            self.refreshControl!.endRefreshing()
        }
    }
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Chat"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    // 搜索筛选的策略
    private func filteredContentForSearchText(searchText: String) {
        filteredRecents = allRecents.filter({ (recent) -> Bool in
            for i in recent.receiverName {
                if i.lowercased().contains(searchText.lowercased()) {
                    return true
                }
            }
            return false
            
        })
        
        tableView.reloadData()
    }
    
    private func goToChat(recent: RecentChat, isActivity: Bool) {
        
        // 当另一方把 recent 删除时，我方点击对话框时，在数据库会为对方新创建一个 recent
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds, isActivity: isActivity, activityTitle: recent.activityTitle)
        
        
        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName, isActivity: isActivity)
        
        // 底部 bar 被隐藏
        privateChatView.hidesBottomBarWhenPushed = true
        if let vcp = self.navigationController?.parent as? TabViewController {
            print("😃")
            vcp.hideTabBar()
        }
        // 底部的 bar 转化成输入bar
        navigationController?.pushViewController(privateChatView, animated: true)
        
        
    }

}

// 如何搜索
extension ChatsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

