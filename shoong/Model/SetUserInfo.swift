//
//  SetUserInfo.swift
//  shoong
//
//  Created by Matthew on 2020/02/10.
//  Copyright © 2020 Matthew. All rights reserved.
//

import Firebase
import FirebaseStorage

func SetUserInfo(name: String, about: String, image: Data, completion: @escaping (Bool) -> Void) {
    var ref: DatabaseReference!

    ref = Database.database().reference()
    let userId = Auth.auth().currentUser?.uid
    
    let storage = Storage.storage().reference()
    
    storage.child("profilepics").child(userId!).putData(image, metadata: nil){
        (_, err) in
        if err != nil{
            print((err?.localizedDescription)!)
            return
        }
        storage.child("profilepics").child(userId!).downloadURL {
            (url, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            ref.child("userList").child(userId!).setValue(["name": name, "about": about, "image": "\(url!)", "uid": userId!]) {
                (error: Error!, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                    return
                }
                completion(true)
                UserDefaults.standard.set(name, forKey: "userName")
                UserDefaults.standard.set(url, forKey: "image")
                UserDefaults.standard.set(about, forKey: "about")
            }
        }
    }
}
