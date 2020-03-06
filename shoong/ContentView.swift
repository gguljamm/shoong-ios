//
//  ContentView.swift
//  shoong
//
//  Created by Matthew on 2020/02/05.
//  Copyright © 2020 Matthew. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ContentView: View {
    
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    @State var creation = false
    
    @EnvironmentObject var datas : MainObservable
    
    var body: some View {
        VStack{
            if status {
//                if self.datas.recents.count > 0 {
//                    Text("\(self.datas.recents.count)")
//                }
//
                TabView{
                    Feed().tabItem {
                        Image(systemName: "house.fill")
                        Text("Feed")
                    }
                    Chat().tabItem {
                        Image(systemName: "ellipses.bubble.fill")
                        Text("Chat")
                    }
                    Store().tabItem {
                        Image(systemName: "cart.fill")
                        Text("Store")
                    }
                    Profile().tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                }.onAppear {
                    checkUser { (exists, user) in
                        if !exists {
                            self.creation.toggle()
                        }
                    }
                }
            }
            else {
                NavigationView{
                    LoginPage()
                }
            }
        }.onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main) {
                (_) in
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                self.status = status
            }
        }.sheet(isPresented: self.$creation) {
            AdditionalInfo(show: self.$creation)
        }.environmentObject(MainObservable())
    }
}
extension Color {
    init(_ hex: UInt32, opacity:Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class MainObservable : ObservableObject{
    
    @Published var recents = [Recent]()
    
    init() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let userId = Auth.auth().currentUser?.uid
        
        if (userId != nil) {
            ref.child("userList").child(userId!).child("chatList").observe(DataEventType.value) { (snap) in
                let dict = snap.value as? [String : AnyObject] ?? [:]
                
                self.recents = []
                
                if dict.count == 0 {
                    self.recents.append(Recent(id: "", name: "", pic: "", lastmsg: "no message", time: "", date: "", stamp: 0))
                }
                else {
                    for (key, value) in dict {
                        let val = value as? NSDictionary
                        
                        let id = key
                        let name = val?["name"] as? String ?? ""
                        let pic = val?["pic"] as? String ?? ""
                        let lastmsg = val?["lastmsg"] as? String ?? ""
                        let stamp = val?["stamp"] as! Double
                        
                        let x = stamp / 1000
                        let date = NSDate(timeIntervalSince1970: x)
                        let formatter = DateFormatter()
                        
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .none
                        
                        let datestring = formatter.string(from: date as Date)
                        
                        formatter.dateStyle = .none
                        formatter.timeStyle = .short
                        
                        let timestring = formatter.string(from: date as Date)
                        
                        self.recents.append(Recent(id: id, name: name, pic: pic, lastmsg: lastmsg, time: timestring, date: datestring, stamp: stamp))
                    }
                }
            }
        }
    }
}

struct Recent : Identifiable {
    var id : String
    var name: String
    var pic : String
    var lastmsg : String
    var time : String
    var date : String
    var stamp : Double
}
