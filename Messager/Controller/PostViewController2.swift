//
//  PostViewController2.swift
//  Messager
//
//  Created by Boyang Zhang on 16/10/20.
//

import UIKit

class PostViewController2: UIViewController {
    
    var postImage: UIImage?
    var postTitle: String?
    var postDetail: String?
    
    
    @IBOutlet weak var headerCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    let categories = ActivityCategory.load()
    let current = ActivityCategory.tmpLoadCurrent()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
//        for a in Activity.Catogory.allCases{
//            print(a)
//        }
        print(categories.count, current.count)
        setupUI()
    }
    
    
    func setupUI() {
        headerCollectionView.dataSource = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    
    
    @IBAction func backBttnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        print("wwwdw")
    }
    
}


// MARK:- UICollectionView DataSource
extension PostViewController2: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return current.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentActivityPostCell", for: indexPath) as! CategoryCollectionViewCell
        let category = current[indexPath.item]
        cell.category = category
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 90)
//    }
//
    
    
    
}

 // MARK:- UITableView DataSource + Delegate
extension PostViewController2: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! ActivityTabelViewCell
        
        let category = categories[indexPath.item]
        cell.category = category
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }



}


// MARK:- Activity CollectionView Cell
class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    
    var category: ActivityCategory! {
        didSet {
            self.update()
        }
    }
    // Aktualisiere
    func update(){
        let colors:[UIColor] = [#colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), #colorLiteral(red: 0.2894071043, green: 0.9341720343, blue: 0.969543159, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.7254902124, green: 0.1283889892, blue: 0.1148036011, alpha: 1)]
        let color = Int.random(in: 0..<colors.count)
        if let category = category {
            container.layer.cornerRadius = 20
            container.backgroundColor = colors[color]
            label.text = category.name
        }
        else{
            print("ERROR")
        }
    }
}

// MARK:- Activity TabelView Cell
class ActivityTabelViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    var category: ActivityCategory! {
        didSet {
            self.update()
        }
    }
    
    func update() {
        if let category = category {
            categoryLabel.text = category.name
        } else {
            print("ERRPR")
        }
    }
    
}
