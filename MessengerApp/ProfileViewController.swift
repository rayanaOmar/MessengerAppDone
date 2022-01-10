//
//  ProfileViewController.swift
//  MessengerApp
//
//  Created by administrator on 07/01/2022.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var imgViewProfile: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        imgViewProfile.layer.borderColor = UIColor.white.cgColor

        imgViewProfile.layer.borderWidth = 3

        imgViewProfile.layer.masksToBounds = true

        imgViewProfile.layer.cornerRadius = imgViewProfile.frame.size.width/2

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {

            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {

                return

            }



            let safeEmail = DatabaseManger.safeEmail(emailAddress: email)

            let filename = safeEmail + "_profile_picture.png"

            let path = "image/"+filename

            StorageManager.shared.downloadURL(for: path, completion: { result in

                switch result {

                case .success(let url):

                    self.imgViewProfile.sd_setImage(with: url, completed: nil)

                case .failure(let error):

                    print("Download Url Failed: \(error)")

                }

            })

            

        }
    

    @IBAction func logoutBtnAction(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else{
                return
            }
            
            do{
                try FirebaseAuth.Auth.auth().signOut()
                let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "BackToLogin") as! LoginViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
                
            }catch{
                print("Error Log Out: \(error.localizedDescription)")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
        
    }
    
}
