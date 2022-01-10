//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var enterEmailLable: UITextField!
    @IBOutlet weak var enterPasswordLable: UITextField!
    
    
    private let spinner = JGProgressHUD(style: .dark)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapRegister(){
       let vc = self.storyboard?.instantiateViewController(withIdentifier: "ToRegisterPage") as! RegisterViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    //login Action
    @IBAction func loginBtnAction(_ sender: UIButton) {
        //make sure the user enter the email and the password
        guard let userEmail = enterEmailLable.text,
              let userPassword = enterPasswordLable.text,
              !userEmail.isEmpty,
              !userPassword.isEmpty else{
            alertLogInError()
            return
        }
       
        
        //FireBase Login
        Auth.auth().signIn(withEmail: userEmail, password: userPassword, completion: { [weak self] authResult, error in
            guard let strongSelf = self else{
                return
                
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }

           guard let result = authResult, error == nil else{
            print("Failed to log in user with email \(userEmail)")
                return

            }
            let user = result.user
            let safeEmail = DatabaseManger.safeEmail(emailAddress: userEmail)

                        DatabaseManger.shared.getDataFor(path: safeEmail, completion: { result in

                            switch result {

                            case .success(let data):

                                guard let userData = data as? [String: Any],

                                      let firstName = userData["first_name"] as? String,

                                      let lastName = userData["last_name"] as? String else {

                                          return

                                      }

                                UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

                                

                            case .failure(let error):

                                print("Failed to read data with error \(error)")

                            }

                        })

                        

                        UserDefaults.standard.setValue(userEmail, forKey: "email")
            
            
            print("Logged In User: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)

            }) 
    }
    
    //FaceBook Action
    @IBAction func facebookBtnAction(_ sender: UIButton) {
    }
    
    //Function Section
    //check Empty
    func alertLogInError(){
        let alert = UIAlertController(title: "Error", message: "Text Fields must be not empty", preferredStyle:  .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
  
}
