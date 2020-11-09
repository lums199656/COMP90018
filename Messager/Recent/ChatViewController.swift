//
//  ChatViewController.swift
//  Messager
//
//  Created by 陆敏慎 on 12/10/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
// 用来保存 message
import RealmSwift
import Firebase
import FirebaseUI


class ChatViewController: MessagesViewController {
    
    
    // pop up
    var popup: UIView!
    
    //MARK: - Views
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 60, y: 10, width: 180, height: 25))
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()

    
    private var chatId = ""
    private var reipientId : [String] = []
    private var recipientName : [String] = []
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    // 组件
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    //一个聊天框内的所有聊天内容
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    var notificationToken: NotificationToken?
    
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    private var isActivity: Bool = true
    
    // TODO: EDIT THIS:
    private var activityId: String?
    var activityManager: ActivityManager?
    
    init(chatId: String, recipientId: [String], recipientName: [String], isActivity: Bool) {
        
        
        super.init(nibName: nil, bundle: nil)
        
        self.isActivity = isActivity
        self.chatId = chatId
        self.reipientId = recipientId
        self.recipientName = recipientName
        
        if isActivity {
            self.activityId = self.chatId
        }
        
        if let actId = self.activityId {
            activityManager = ActivityManager(actId)
        }
        
        print("_x-80 重新加载消息信息")
        let db = Firestore.firestore()
        let allMembers = recipientId + [currentUser.senderId]
        for userId in allMembers {
            let userInfo = db.collection("User")
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
                                if reipientId.count > 0 {
                                    titleLabel.text = displayNames[reipientId[0]] ?? recipientName[0]
                                }
                                loadChats()

                            }
                        }
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK:- View Lifecycle
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        configueMessageCollectionView()

        configureLeftBarButton()
        configureCustomTitle()


        // _. Setup Shake Gesture
        configureGestureRecognizer()
        
        configureMessageInputBar()

        loadChats()
        listenForNewChats()
        
        //activityManager
        activityManager?.delegate = self
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("Chat Will Appear")
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Chat Did Apear")
        super.viewDidAppear(animated)
        // 关闭正在播放的音频
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }
    
    // MARK:- Shake Gesture
    override func becomeFirstResponder() -> Bool {  // For Shake Gesture
        super.becomeFirstResponder()
        return false
    }
  
    var isUserAllowedToCheckIn: Bool = false {
        didSet {
            print("didSet isUserAtActivityLocation")
            if isUserAllowedToCheckIn {
                
                OutgoingMessage.sendSuprise(chatId: chatId, text: "「\(currentUser.displayName)」 ARRIVED !", memberIds: [User.currentId] + reipientId)

            } else {
                let distance = Int(userDistanceFromActivityLocation ?? 9999)/1000
                
                OutgoingMessage.sendSuprise(chatId: chatId, text: "「\(currentUser.displayName)」IS RUNNING TO「YOU」\n   ONLY \(distance) KM ❤️", memberIds: [User.currentId] + reipientId)
            }
        }
    }
    
    var userDistanceFromActivityLocation: Int?
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
                print("👻Shimmy Shaky")
                activityManager?.currentUserTryToCheckIn()
        }
    }
    

    // MARK:-
    // 下拉加载操作
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayingMessagesCount < allLocalMessages.count {
                // 加载之前的信息
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
    }
    
    
    // 设定 title
    private func configureCustomTitle() {
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        titleLabel.frame(forAlignmentRect: CGRect(x: leftBarButtonView.bounds.midX, y: leftBarButtonView.bounds.midY, width: 200, height: 50))
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
                
        var tmpText = ""
        if !isActivity {
            print("_x-41 ")
            tmpText = displayNames[reipientId[0]] ?? recipientName[0]
        }
        titleLabel.text = tmpText
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    @objc func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func removeListeners() {
//        FirebaseTypingListener.shared.removeTypingListener()
        FirebaseMessageListener.shared.removeListeners()
    }
    
    
    private func configueMessageCollectionView() {
        // 部署 message 界面需要的组件
        // 得补充 ChatViewExtension
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        // 下拉刷新
        messagesCollectionView.refreshControl = refreshController

        
        // 加上滚动功能
        // 当点击键盘时，会将聊天框滚动到底部
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    // 设置输入框
    private func configureMessageInputBar() {
        // 检测 bar 是否被检测
        messageInputBar.delegate = self
        // 照片按钮
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus")
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("_x-17 attach button pressed")
        }
        // 麦克风按钮
        micButton.image = UIImage(systemName: "mic.fill")
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.addGestureRecognizer(longPressGesture)
        
        // 将两个 button 放入布局, MessageKit 可以查看布局
        // imageButton
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        updateMicButtonStatus(show: true)
        
        
        // textField
        // 不让用户能够在此处黏贴 image
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        
        //
        
    }
    
    // 设置何时现实 mic 何时显示 send
    func updateMicButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }    
    
    
    // Message 的发送
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        print("_x 发送信息")
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId] + reipientId)
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }
    
    // 插入信息以待展示
    private func insertMessages() {
        
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber  = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
        
//
//        for message in allLocalMessages {
//            insertMessage(message)
//        }
    }
    
    // 下拉加载旧信息
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber) {
            insertOlderMessage(allLocalMessages[i])
        }
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }
    
    
    
    // 检测是否有新的信息
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }

    
    //MARK: - Load Chats
    private func loadChats() {
                
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)

        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        print("_x-10 这个聊天框: \(chatId) 我们有 \(allLocalMessages.count) messages")

        
        // 如果本地一条信息都没，尝试从 firebase 下载数据保存到 localdb
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }

        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in

            //updated message
            switch changes {
            // 新增
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                // 始终显示最下面
                self.messagesCollectionView.scrollToBottom(animated: true)
            
            //更改
            case .update(_, _ , let insertions, _):

                for index in insertions {
                    // 将每个 message 渲染出来
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }

            case .error(let error):
                print("Error on new insertion", error.localizedDescription)
            }
        })
    }
    
    private func checkForOldChats() {
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    
    
    
    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
    }

    @objc func recordAudio() {
        switch longPressGesture.state {
        case .began:
            showDino()
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            dismissAlert()
            AudioRecorder.shared.finishRecording()
            
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                // send message
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
            } else {
                print("_x-21 no audio file")
            }
            audioFileName = ""
            
        default:
            print("_x-20 unkown")
        }
        print("long press")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK:-
extension ChatViewController: ActivityManagerDelegate {
    func activityManagerDid() {
        
    }
    
    func activityManager(_ manager: ActivityManager, didUpdateActivityTitle title: String) {
        titleLabel.text = title
    }

    func activityManager(_ manager: ActivityManager, didCheckInUser isAllowed: Bool, distanceToActivityLocation distance: Int?) {
        self.userDistanceFromActivityLocation = distance
        
        isUserAllowedToCheckIn = isAllowed
    }


}


// MARK:- PopUp
extension ChatViewController {
    
    func showDino() {
        popup = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        popup.cornerRadius = 10
        
        let popIcon = UIImageView(frame: CGRect(x: 50, y: 20, width: 100, height: 100))
        popIcon.image = UIImage(named: "mic1")
        popup.addSubview(popIcon)
        
        var gif_index = 1
        
        popup.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        popup.center = view.center
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            popIcon.image = UIImage(named: "mic\(gif_index)")
            gif_index += 1
            if gif_index > 3 {
                gif_index = 1
            }
        }
        
        self.view.addSubview(popup)
        
    }
    
    @objc func dismissAlert() {

        if popup != nil {
            popup.removeFromSuperview()
        }
    }
    
}
