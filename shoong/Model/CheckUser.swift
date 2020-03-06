//
//  CheckUser.swift
//  shoong
//
//  Created by Matthew on 2020/02/10.
//  Copyright © 2020 Matthew. All rights reserved.
//

import Firebase

func checkUser(completion: @escaping (Bool,String)->Void){
    var ref: DatabaseReference!

    ref = Database.database().reference()
    let userId = Auth.auth().currentUser?.uid
    ref.child("userList").child(userId!).observeSingleEvent(of: .value, with: { (snap) in
        let value = snap.value as? NSDictionary
        let uid = snap.key
        if (uid != "") {
            let userName = value?["name"] as? String ?? ""
            UserDefaults.standard.set(uid, forKey: "uid")
            UserDefaults.standard.set(userName, forKey: "userName")
            UserDefaults.standard.set(value?["image"] as? String ?? "", forKey: "image")
            UserDefaults.standard.set(value?["about"] as? String ?? "", forKey: "about")
            completion(true, userName)
            return
        }
        completion(false, "")
        
    }) { (error) in
        print(error.localizedDescription)
        completion(false, "")
    }
}
