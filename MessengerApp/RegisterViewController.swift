//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by administrator on 06/01/2022.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var userFN: UITextField!
    @IBOutlet weak var userLN: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        imgView.isUserInteractionEnabled = true
        let gestrue = UITapGestureRecognizer(target: self, action: #selector(self.presentPhotoActionSheet))
        imgView.addGestureRecognizer(gestrue)
        

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func registerBtnAction(_ sender: UIButton) {
        //make sure the user fill all fields
        guard let fName = userFN.text,
              let lName = userLN.text,
              let eMail = userEmail.text,
              let passWord = userPassword.text,
              !fName.isEmpty, !lName.isEmpty, !eMail.isEmpty, !passWord.isEmpty else{
            alertEmpty()
            return
        }
        //make sure the user password is >= 6
        guard let passWord = userPassword.text,
              passWord.count >= 6 else{
            alertPassword()
            return
        }
        
        //firebase login
        DatabaseManger.shared.userExists(with: eMail, completion: { [weak self] exists in
            guard let strongSelf = self else{
                return
            }
            
            guard !exists else{
                strongSelf.alertEmpty(meg: "Account allready exists")
                return
            }
            
            Auth.auth().createUser(withEmail: eMail, password: passWord, completion: { authResult, error in
                guard authResult != nil, error == nil else{
                    print("Error Creating User")
                    return
                }
                DatabaseManger.shared.insertUser(with: ChatAppUser(firstName: fName, lastName:
                                                                    lName, emailAddress: eMail))
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    //Function Section
    func alertEmpty(meg: String = "Text Fields must be not empty"){
        let alert = UIAlertController(title: "Error", message: meg, preferredStyle:  .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    
    func alertPassword(){
        let alert = UIAlertController(title: "Error", message: "Password Must be more than 6 Character", preferredStyle:  .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
}
    //image View section
    extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
        
        // get results of user taking picture or selecting from camera roll

       

        @objc func presentPhotoActionSheet(){

            let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)

            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in

                self?.presentCamera()

            }))

            actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in

                self?.presentPhotoPicker()

            }))

            

            present(actionSheet, animated: true)

        }

        func presentCamera() {

            let vc = UIImagePickerController()

            vc.sourceType = .camera

            vc.delegate = self

            vc.allowsEditing = true

            present(vc, animated: true)

        }

        func presentPhotoPicker() {

            let vc = UIImagePickerController()

            vc.sourceType = .photoLibrary

            vc.delegate = self

            vc.allowsEditing = true

            present(vc, animated: true)

        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            // take a photo or select a photo

            

            // action sheet - take photo or choose photo

            picker.dismiss(animated: true, completion: nil)

            print(info)

            

            guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {

                return

            }

            

            self.imgView.image = selectedImage

            

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

            picker.dismiss(animated: true, completion: nil)

        }
        
    }

