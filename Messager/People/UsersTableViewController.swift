//
//  UsersTableViewController.swift
//  Messager
//
//  Created by 陆敏慎 on 5/10/20.
//

import UIKit

class UsersTableViewController: UITableViewController {

    var allUsers: [User] = []
    var filteredUsers: [User] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        print("_x UsersView")
        
        
        // 增加下拉更新的功能
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        
        // 去除多余的横线
        setupSearchController()
        tableView.tableFooterView = UIView()
        downloadUsers()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // toggle tabbar
        print("😡")
        if let vcp = self.navigationController?.parent as? TabViewController {
            print("😃")
            vcp.showTabBar()
        }
    }

    // 返回 cells 的个数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // 如果使用了搜索则返回 filteredUsers 的长度，否则返回 allUsers 的长度
        return searchController.isActive ? filteredUsers.count : allUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        let  user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        cell.configure(user: user)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        // N: 没有 actId 的群聊。就自己生成一个
        // O: 1v1 聊天，通过两个 UserId 生成 actId
        // 其他：直接输入 actId
        
        startActivityChat(users: [User.currentUser!, user], activityId: "O")
//        // chat
//        let activityId = "N"
//        let chatId = startChat(users: [User.currentUser!, user], activityId: activityId)
//        print("_x start chat", chatId)
//
//        // 打开一个 chat room 界面
//        let privateChatView = ChatViewController(chatId: chatId, recipientId: [user.id], recipientName: [user.username])
//        privateChatView.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(privateChatView, animated: true)
    }
    
    func startActivityChat(users:[User], activityId: String) {
        let chatId = startChat(users: users, activityId: activityId, activityTitle: "")
        print("_x start chat", chatId)
        var recipientId : [String] = []
        var recipientName : [String] = []
        for user in users {
            if user.id != User.currentId {
                recipientId.append(user.id)
                recipientName.append(user.username)
            }
        }
        // 打开一个 chat room 界面
        var isActivity = true
        if activityId == "O" {
            isActivity = false
        }
        let privateChatView = ChatViewController(chatId: chatId, recipientId: recipientId, recipientName: recipientName, isActivity: isActivity)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }
        
    private func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUsersFromFirebase{(allFirebaseUsers) in
            self.allUsers = allFirebaseUsers
//            print("_x", self.allUsers)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search User"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    private func filteredContentForSearchText(searchText: String){
        print("_x Searching for ", searchText)
        filteredUsers = allUsers.filter({(user) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("_x Refreshing")
        if self.refreshControl!.isRefreshing {
            self.downloadUsers()
            self.refreshControl!.endRefreshing()
        }
    }
    
    
    
}

// 如何搜索
extension UsersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

