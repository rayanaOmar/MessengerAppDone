//
//  StorageManager.swift
//  MessengerApp
//
//  Created by administrator on 08/01/2022.
//

import Foundation
import SwiftUI
import FirebaseStorage

final class StorageManager{
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    public typealias UPloadPictureCompletion = (Result<String,Error>) -> Void
    public func uploadProfilePicture(with data: Data, fileName:String, completion: @escaping UPloadPictureCompletion ){
        
        storage.child("image/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            guard error == nil else {
                //failed
                
                print("Failed to upload data to firebase for Image\(error?.localizedDescription)")
                completion(.failure(StorageErorr.faildToUpload))
                return
                
            }
            self.storage.child("image/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed tp get download url")
                    completion(.failure(StorageErorr.faildToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned:\(urlString)")
                completion(.success(urlString))
                
            })
            
        })
    }
    public enum StorageErorr : Error {
        case faildToUpload
        case faildToGetDownloadUrl
        
    }
}
