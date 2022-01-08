//
//  ConversationsViewController.swift
//  MessengerApp
//
//  Created by administrator on 08/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {
    // root view controller that gets instantiated when app launches
    // check to see if user is signed in using ... user defaults
    // they are, stay on the screen. If not, show the login screen
    
    private let spinner = JGProgressHUD(style: .dark)
    
    internal let tableView: UITableView = {
           let table = UITableView()
           table.isHidden = true // first fetch the conversations, if none (don't show empty convos)
           
           table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
           return table
       }()
       
       private let noConversationsLabel: UILabel = {
           let label = UILabel()
           label.text = "No conversations"
           label.textAlignment = .center
           label.textColor = .gray
           label.font = .systemFont(ofSize: 21, weight: .medium)
           return label
       }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
               view.addSubview(tableView)
               view.addSubview(noConversationsLabel)
               setupTableView()
               fetchConversations()
       //DatabaseManger.shared.test()

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapComposeButton(){
        // present new conversation view controller
        // present in a nav controller
        
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            // present login view controller
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations(){
        // fetch from firebase and either show table or label
        
        tableView.isHidden = false
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
     }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         cell.textLabel?.text = "Hello World"
         cell.accessoryType = .disclosureIndicator
         return cell
     }
     
     // when user taps on a cell, we want to push the chat screen onto the stack
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
         
         let vc = ChatViewController()
         vc.title = "Jenny Smith"
         vc.navigationItem.largeTitleDisplayMode = .never
         navigationController?.pushViewController(vc, animated: true)
     }
}
