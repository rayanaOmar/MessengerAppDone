//
//  DatabaseManger.swift
//  MessengerApp
//
//  Created by administrator on 07/01/2022.
//

import Foundation
import FirebaseDatabase


final class DatabaseManger {
    static let shared = DatabaseManger()
    private let database = Database.database().reference()
}

extension DatabaseManger {
   public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        })
       return
        
    }
    
    // Inser new user to database
    
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName, "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else{
                print("failed write to database")
                completion(false)
                return
            }
            completion(true)
        })
    }
}

struct ChatAppUser {
    
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    //let profilePictureUrl: String
    // check type -> email @ -
    
    var safeEmail : String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
