//
//  AdditionalInfo.swift
//  shoong
//
//  Created by Matthew on 2020/02/10.
//  Copyright © 2020 Matthew. All rights reserved.
//

import SwiftUI

struct AdditionalInfo : View {
    @Binding var show : Bool
    
    @State var name = ""
    @State var about = ""
    @State var image : Data = .init(count: 0)
    @State var picker = false
    @State var loading = false
    @State var alert = false
    
    var body : some View{
        VStack(alignment: .leading, spacing: 15) {
            Text("Please enter the information")
            
            HStack{
                Spacer()
                
                Button(action: {
                    
                    self.picker.toggle()
                    
                }) {
                    if self.image.count == 0{
                        Image(systemName: "person.crop.circle.badge.plus").resizable().frame(width: 90, height: 70).foregroundColor(.gray)
                    }
                    else {
                        Image(uiImage: UIImage(data: self.image)!).resizable().renderingMode(.original).frame(width: 90, height : 90).clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            
            Text("Enter Display Name").font(.body).foregroundColor(.gray).padding(.top, 12)
            
            TextField("Name", text: $name)
                .padding()
                .padding(.top, 15)
            
            Text("About You").font(.body).foregroundColor(.gray).padding(.top, 12)
            
            TextField("About", text: $about)
                .padding()
                .padding(.top, 15)
            
            if self.loading {
                HStack{
                    Spacer()
                    
                    Indicator()
                    
                    Spacer()
                }
            } else {
                Button(action: {
                    self.loading.toggle()
                    if self.name != "" && self.about != "" && self.image.count != 0 {
                        SetUserInfo(name: self.name, about: self.about, image: self.image) { (status) in
                            if (status) {
                                self.show.toggle()
                            }
                        }
                    }
                    else {
                        self.alert.toggle()
                    }
                }) {
                    Text("Submit").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                }.foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color(0xFF3344), Color(0xFF4128)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .padding(.top, 15)
            }
        }
        .padding()
        .sheet(isPresented: self.$picker, content: {
            ImagePicker(picker: self.$picker, imagedata: self.$image)
        })
        .alert(isPresented: self.$alert) {
            Alert(title: Text("Message"), message: Text("Please Fill The Contents"), dismissButton: .default(Text("Ok")) {
                self.loading.toggle()
            })
        }
    }
}
