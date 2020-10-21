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
        
        // chat
        let chatId = startChat(users: [User.currentUser!, user, allUsers[8]])
        print("_x start chat", chatId)
        
        // 打开一个 chat room 界面
        let privateChatView = ChatViewController(chatId: chatId, recipientId: [user.id], recipientName: [user.username])
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
