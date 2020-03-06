//
//  FeedView.swift
//  shoong
//
//  Created by Matthew on 2020/02/06.
//  Copyright © 2020 Matthew. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct Profile : View {
    @State var uid = Auth.auth().currentUser?.uid
    @State var name = UserDefaults.standard.value(forKey: "userName") as? String ?? ""
    @State var image = UserDefaults.standard.value(forKey: "image") as? String ?? ""
    @State var about = UserDefaults.standard.value(forKey: "about") as? String ?? ""
    
    var body: some View{
        VStack(spacing: 20){
            AnimatedImage(url: URL(string: image)!).resizable().renderingMode(.original).frame(width: 120, height: 120).clipShape(Circle())
            Text(name)
            Text(about).padding(.top, 50)
            Button(action: {
                try! Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "status")
                
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
            }) {
                Text("Log out").frame(width: UIScreen.main.bounds.width - 30, height: 50)
            }
            .background(Color(.white))
            .cornerRadius(10)
            .padding(.top, 15)
        }.padding()
    }
}
