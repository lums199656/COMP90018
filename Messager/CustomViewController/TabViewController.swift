//
//  TabViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 12/10/20.
//

import UIKit

class TabViewController: UIViewController {
    
    
    @IBOutlet weak var contentView: UIView!
    
        
    @IBOutlet weak var feedBttn: UIButton!
    @IBOutlet weak var chatBttn: UIButton!
    @IBOutlet weak var addBttn: UIButton!  // special Tab Button
    @IBOutlet weak var peopleBttn: UIButton!
    @IBOutlet weak var meBttn: UIButton!
    
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var peopleImage: UIImageView!
    @IBOutlet weak var meImage: UIImageView!
    
    private var buttons: [UIButton]!
    private var buttonImages: [UIImageView]!
        
    //Define variables to hold each ViewController associated with a tab.
    var feedViewController: UIViewController!
    var chatViewController: UIViewController!
    var addViewController: UIViewController! // special Tab VC
    var peopleViewController: UIViewController!
    var meViewController: UIViewController!
    var viewControllers: [UIViewController]!
    
    private var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        feedViewController = storyboard.instantiateViewController(withIdentifier: "feedVC")
        chatViewController = storyboard.instantiateViewController(withIdentifier: "chatNavVC")
//        addViewController = storyboard.instantiateViewController(withIdentifier: "addVC")// special Tab VC
        peopleViewController = storyboard.instantiateViewController(withIdentifier: "peopleNavVC")
        meViewController = storyboard.instantiateViewController(withIdentifier: "meVC")
        viewControllers = [feedViewController, chatViewController, peopleViewController, meViewController]
        
        buttons = [feedBttn, chatBttn, peopleBttn, meBttn]
        buttonImages = [feedImage, chatImage, peopleImage, meImage]
        
        
        // Init Setup
        tabBttnPressed(buttons[selectedIndex])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func tabBttnPressed(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        
        // Step: Remove previous VC & Button
        for image in buttonImages {
            image.isHighlighted = false
        }
        let previousVC = viewControllers[previousIndex]
        
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        
        // Step: Add New VC & Button
        buttonImages[selectedIndex].isHighlighted = true
        
        let vc = viewControllers[selectedIndex]
        addChild(vc)
        //Adjust the size of the ViewController view you are adding to match the contentView of your tabBarViewController and add it as a subView of the contentView.
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        
        // Call the viewDidAppear method of the ViewController you are adding using didMove(toParentViewController: self).
        vc.didMove(toParent: self)
        
    }
    
    @IBAction func addBttnPressed(_ sender: UIButton) {
        
    }
    
}
