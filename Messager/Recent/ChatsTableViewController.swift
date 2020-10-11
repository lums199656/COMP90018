//
//  ChatsTableViewController.swift
//  Messager
//
//  Created by 陆敏慎 on 11/10/20.
//

import UIKit

class ChatsTableViewController: UITableViewController {
    
    
    var allRecents: [RecentChat] = []
    var filteredRecents: [RecentChat] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 底板是 tableview
        print("_x ChatView")
        tableView.tableFooterView = UIView()
        downloadRecentChats()
        // 增加下拉更新的功能
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allRecents.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell

        // Configure the cell...
        cell.configure(recent: allRecents[indexPath.row])

        return cell
    }
    
    private func downloadRecentChats() {
        FirebaseRecentListener.shared.downloadRecentChatFromFireStore { (allChats) in
            self.allRecents = allChats
            print("_x 下载了 \(self.allRecents.count) 条数据")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("_x Refreshing")
        if self.refreshControl!.isRefreshing {
            self.downloadRecentChats()
            self.refreshControl!.endRefreshing()
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
