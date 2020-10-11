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

    }

    // 返回 cells 的个数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // 如果使用了搜索则返回 filteredUsers 的长度，否则返回 allUsers 的长度
        return searchController.isActive ? filteredUsers.count : allUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("_-------->",indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        let  user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        cell.configure(user: user)
        return cell
    }

    private func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUsersFromFirebase{(allFirebaseUsers) in
            self.allUsers = allFirebaseUsers
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
