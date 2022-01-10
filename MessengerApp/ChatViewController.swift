//
//  ViewController.swift
//  MessengerApp
//
//  Created by administrator on 07/01/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

// message model
struct Message: MessageType {
    
    public var sender: SenderType // sender for each message
    public var messageId: String // id to de duplicate
    public var sentDate: Date // date time
    public var kind: MessageKind // text, photo, video, location, emoji
}
extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
// sender model
struct Sender: SenderType {
    public var photoURL: String // extend with photo URL
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public let otherUserEmail: String
    private var conversationId: String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    //private var selfSender = Sender(photoURL: "", senderId: "1", displayName: "rayana")
    private var selfSender: Sender? {
            
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return nil
            }
            let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
            
            return Sender(photoURL: "",
                          senderId: safeEmail,
                          displayName: "Me")
        }
    
    
    
    init(with email: String, id: String?) {
            self.conversationId = id
            self.otherUserEmail = email
            super.init(nibName: nil, bundle: nil)
            
            // creating a new conversation, there is no identifier
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

        // Do any additional setup after loading the view.
    }
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
            DatabaseManger.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
                switch result {
                case .success(let messages):
                    print("success in getting messages: \(messages)")
                    guard !messages.isEmpty else {
                        print("messages are empty")
                        return
                    }
                    self?.messages = messages
                    
                    DispatchQueue.main.async {
                        self?.messagesCollectionView.reloadDataAndKeepOffset()
                        
                        if shouldScrollToBottom {
                            self?.messagesCollectionView.scrollToLastItem()
                        }
                    }
                case .failure(let error):
                    print("failed to get messages: \(error)")
                }
            })
        }
        
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            messageInputBar.inputTextView.becomeFirstResponder()
            if let conversationId = conversationId {
                listenForMessages(id: conversationId, shouldScrollToBottom: true)
            }
            
        }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
        return sender
        }
        fatalError("Self Sender is nil, email should be cached")
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count

    }
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
          guard let message = message as? Message else {
              return
          }

          switch message.kind {
          case .photo(let media):
              guard let imageUrl = media.url else {
                  return
              }
              imageView.sd_setImage(with: imageUrl, completed: nil)
          default:
              break
          }
      }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
            let sender = message.sender
            if sender.senderId == selfSender?.senderId {
                // our message that we've sent
                return .link
            }

            return .secondarySystemBackground
        }

        func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

            let sender = message.sender

            if sender.senderId == selfSender?.senderId {
                // show our image
                if let currentUserImageURL = self.senderPhotoURL {
                    avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
                }
                else {
                    // images/safeemail_profile_picture.png
                    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                        return
                    }

                    let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
                    let path = "images/\(safeEmail)_profile_picture.png"

                    // fetch url
                    StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                        switch result {
                        case .success(let url):
                            self?.senderPhotoURL = url
                            DispatchQueue.main.async {
                                avatarView.sd_setImage(with: url, completed: nil)
                            }
                        case .failure(let error):
                            print("\(error)")
                        }
                    })
                }
            }
            else {
                // other user image
                if let otherUsrePHotoURL = self.otherUserPhotoURL {
                    avatarView.sd_setImage(with: otherUsrePHotoURL, completed: nil)
                }
                else {
                    // fetch url
                    let email = self.otherUserEmail

                    let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
                    let path = "images/\(safeEmail)_profile_picture.png"

                    // fetch url
                    StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                        switch result {
                        case .success(let url):
                            self?.otherUserPhotoURL = url
                            DispatchQueue.main.async {
                                avatarView.sd_setImage(with: url, completed: nil)
                            }
                        case .failure(let error):
                            print("\(error)")
                        }
                    })
                }
            }

        }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
                  return
              }
        
        print("Sending: \(text)")
        let mmessage = Message(sender: selfSender,
                               messageId: messageId,
                               sentDate: Date(),
                               kind: .text(text))
        // Send Message
        if isNewConversation {
            // create convo in database
            
            DatabaseManger.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: mmessage, completion: { [weak self] success in
                if success {
                    print("message sent")
                }
                else {
                    print("faield ot send")
                }
            })
        }
        else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            
            // append to existing conversation data
            DatabaseManger.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: mmessage, completion: { success in
                if success {
                    print("message sent")
                    self.isNewConversation = false
                }
                else {
                    print("failed to send")
                }
            })
        }
    }
    private func createMessageId() -> String? {
        // date, otherUesrEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("created message id: \(newIdentifier)")
        
        return newIdentifier
    }
    
}
