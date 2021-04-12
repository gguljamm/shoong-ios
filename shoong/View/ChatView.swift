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

struct Chat : View {
    @EnvironmentObject var datas : MainObservable
    @State var newChatShow = false
    @State var chatRoomShow = false
    @State var roomid = ""
    @State var url = ""
    @State var name = ""
    
    var body: some View{
        NavigationView{
            ZStack{
                NavigationLink(destination: ChatRoom(roomid: self.roomid, chatRoomShow: self.$chatRoomShow), isActive: self.$chatRoomShow) {
                    Text("")
                }
                VStack{
                    if self.datas.recents.count == 0{
                        Indicator()
                    }
                    else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 12){
                                ForEach(datas.recents){i in
                                    if (i.id == "") {
                                        Text("No message")
                                    } else {
                                        Button(action: {
                                            self.roomid = i.id
                                            self.chatRoomShow.toggle()
                                        }, label: {
                                            RecentCallView(url: i.pic, name: i.name, time: i.time, date: i.date, lastmsg: i.lastmsg)
                                        })
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }.navigationBarTitle("Chat", displayMode: .inline)
                .navigationBarItems(
                    trailing:
                    Button(action: {
                        self.newChatShow.toggle()
                    }, label: {
                        Image(systemName: "square.and.pencil").resizable().frame(width: 25, height: 25)
                    })
                )
            }.sheet(isPresented: self.$newChatShow) {
                NewChat()
            }
        }
    }
}

struct RecentCallView : View {
    var url : String
    var name: String
    var time: String
    var date : String
    var lastmsg : String
    
    var body : some View{
        VStack{
            
            HStack{
                if url != "" {
                    AnimatedImage(url: URL(string: url)!).resizable().renderingMode(.original).frame(width: 55, height: 55).clipShape(Circle())
                }
                VStack{
                    HStack{
                        VStack{
                            VStack(alignment: .leading, spacing: 6){
                                Text(name).foregroundColor(.black)
                                Text(lastmsg).foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(date).foregroundColor(.gray)
                            Text(time).foregroundColor(.gray)
                        }
                    }
                }
            }
            Divider()
            .frame(height: 1)
            .padding(.horizontal, 10)
                .background(Color(0xDDDDDD))
        }
    }
}

struct NewChat : View {
    var body : some View{
        VStack{
            Text("안뇽")
        }
    }
}

struct ChatRoom : View {
    var roomid : String
    @Binding var chatRoomShow : Bool
    
    @State var msgs = [Msg]()
    @State var txt = ""
    @State var uid = UserDefaults.standard.value(forKey: "uid") as? String ?? ""
    @State var nomsg = false
    @State var member = [String : User]()
    @State var memberName = ""
    
    var body : some View{
        VStack{
            if msgs.count == 0 {
                if nomsg {
                    Text("Start New Conversation :)").foregroundColor(Color.black.opacity(0.5)).padding(.top)
                }
                else {
                    Spacer()
                    Indicator()
                    Spacer()
                }
            } else {
                ReverseScrollView {
                    VStack{
                        ForEach(self.msgs){i in
                            HStack{
                                if self.uid == i.uid {
                                    Spacer()
                                }
                                Text(self.member[i.uid]?.name ?? "")
                                if self.uid != i.uid {
                                    Spacer()
                                }
                            }
                            HStack{
                                if self.uid == i.uid {
                                    Spacer()
                                    Text(i.text).padding().background(Color.blue).clipShape(ChatBubble(mymsg: true)).foregroundColor(.white)
                                }
                                else {
                                    Text(i.text).padding().background(Color.green).clipShape(ChatBubble(mymsg: false)).foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }.padding()
                    .background(Color.white)
                }.previewLayout(.sizeThatFits)
            }
            HStack{
                TextField("Enter Message", text: self.$txt).textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    self.pushMsg()
                }) {
                    Text("Send")
                }
            }.navigationBarTitle("\(memberName)", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.chatRoomShow.toggle()
            }, label: {
                Image(systemName: "arrow.left").resizable().frame(width: 20, height: 15)
            }))
                .padding([.bottom, .leading, .trailing])
        }
        .onAppear{
            self.getMsgs()
        }
    }
    
    func getMsgs() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("chatRoom").child(roomid).child("chat").queryLimited(toLast: 50).observe(.childAdded, with: { (snap) -> Void in
            
            let dict = snap.value as? NSDictionary
            let key = snap.key
            
            self.msgs.append(Msg(id: key, text: dict?["text"] as? String ?? "", uid: dict?["uid"] as? String ?? ""))
            // self.contentOffset = CGPoint(x: 0, y: 500)
        })
        ref.child(".info/connected").observeSingleEvent(of: .value, with: {(snap) in
            if snap.value as? Int == 1{
                self.nomsg = true
            }
        })
        ref.child("chatRoom").child(roomid).child("member").observe(.value, with: {(snap) -> Void in
            self.member = [String: User]()
            let dict = snap.value as? [String : AnyObject] ?? [:]
            var arr = [String]()
            for (key, value) in dict {
                let name = value["name"] as? String ?? ""
                let pic = value["pic"] as? String ?? ""
                self.member[key] = User(id: key, name: name, pic : pic)
                if (key != self.uid) {
                    arr.append(name)
                }
            }
            self.memberName = arr.joined(separator: ", ")
        })
    }
    
    func pushMsg() {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        if (self.uid != "" && self.txt != "") {
            let dict = ["text": self.txt, "uid": self.uid, "stamp": [".sv": "timestamp"]] as [String : Any]
            guard let key = ref.child("chatRoom").child(roomid).child("chat").childByAutoId().key else { return }
            ref.updateChildValues(["/chatRoom/\(roomid)/chat/\(key)": dict]) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data error: \(error)")
                } else {
                    let myName = self.memberName
                    let myPic = UserDefaults.standard.value(forKey: "image") as? String ?? ""
                    for (key, _) in self.member {
                        let lastChtDic = ["name": myName, "pic": myPic, "stamp": [".sv": "timestamp"], "unread": 0, "lastmsg": self.txt] as [String : Any]
                        ref.child("userList").child(key).child("chatList").child(self.roomid).setValue(lastChtDic)
                    }
                    self.txt = ""
                }
            }
        }
    }
}

struct Msg : Identifiable {
    var id : String
    var text : String
    var uid : String
}

struct User : Identifiable {
    var id : String
    var name : String
    var pic : String
}

struct ChatBubble : Shape {
    
    var mymsg : Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight, mymsg ? .topLeft : .topRight], cornerRadii: CGSize(width: 16, height: 16))
        return Path(path.cgPath)
    }
}
