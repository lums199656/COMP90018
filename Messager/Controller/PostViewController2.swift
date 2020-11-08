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

        print(categories.count, current.count)
        setupUI()
    }
    
    
    func setupUI() {
        headerCollectionView.dataSource = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    
    // MARK:- IBActions
    @IBAction func backBttnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToPost" {
            let destinationVC = segue.destination as! PostViewController1
            let sd = sender as! ActivityTabelViewCell
            destinationVC.postCategory = sd.category.name
        }
        if segue.identifier == "collectionToPost" {
            let destinationVC = segue.destination as! PostViewController1
            let sd = sender as! CategoryCollectionViewCell

            destinationVC.postLocationString = sd.location
            destinationVC.postTitle = sd.title
            destinationVC.postDetail = sd.detail
            destinationVC.currentImageId = sd.imageId
            destinationVC.postCategory = "Recreation"
        }
    }
}


// MARK:- UICollectionView DataSource
extension PostViewController2: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return current.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentActivityPostCell", for: indexPath) as! CategoryCollectionViewCell

        cell.title = current[indexPath.item].title
        cell.detail = current[indexPath.item].detail
        cell.location = current[indexPath.item].location
        cell.imageId = current[indexPath.item].imageId
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 40)
    }

    
    
    
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
        return 100
    }



}


// MARK:- Activity CollectionView Cell
class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var currentImage: UIImageView!
    
    
    var title: String?
    var detail: String?
    var location: String?
    var imageId: String? {
        didSet {
            print("imageId")
            currentImage.image = UIImage(named: imageId!)
        }
    }
    
    var category: ActivityCategory! {
        didSet {
            self.update()
        }
    }
    
    func update(){
        let colors:[UIColor] = [#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)]
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
    @IBOutlet weak var categoryImage: UIImageView!
    
    var category: ActivityCategory! {
        didSet {
            self.update()
        }
    }
    
    func update() {
        if let category = category {
            categoryLabel.text = category.name
            
            let image = UIImage(named: category.name)
            categoryImage.image = image
            
        } else {
            print("ERRPR")
        }
        
        
    }
    
}


