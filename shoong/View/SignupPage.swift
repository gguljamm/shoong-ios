//
//  Signup.swift
//  shoong
//
//  Created by Matthew on 2020/02/10.
//  Copyright © 2020 Matthew. All rights reserved.
//

import SwiftUI
import Firebase

struct SignupPage : View {
    @Binding var show : Bool
    @State var email = ""
    @State var password = ""
    @State var showPassword : Bool = false
    @State var agreeCheck: Bool = false
    @State var showAlert: Bool = false
    @State var errorText: String = ""
    @State var loading: Bool = false
    
    var alert: Alert {
     
     Alert(title: Text("Verify your Email ID"), message: Text("Please click the link in the verification email sent to you"), dismissButton: .default(Text("Dismiss")){
            self.email = ""
            self.password = ""
            self.agreeCheck = false
            self.errorText = ""
            self.show = false
         })
    }
    
    var body : some View{
        ZStack(alignment: .topLeading) {
            GeometryReader{_ in
                VStack(spacing: 20){
                    
                    Text("Email").font(.body).fontWeight(.thin).frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                    
                    TextField("Email", text: self.$email)
                        .padding()
                        .background(Capsule().fill(Color(0xeeeeee)))
                        .keyboardType(.emailAddress)
                        .frame(height: 56)
                        .textContentType(.emailAddress)
                    
                    Text("Password").font(.body).fontWeight(.thin).frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                    
                    HStack {
                        if self.showPassword {
                            TextField("Password", text: self.$password)
                        } else {
                            SecureField("Password", text: self.$password)
                        }
                        if self.password != "" {
                            Button(action: { self.showPassword.toggle() }) {
                                Image(systemName: "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding()
                    .frame(height: 56)
                    .background(Capsule().fill(Color(0xeeeeee)))
                    
                    Toggle(isOn: self.$agreeCheck)
                    {
                        Text("Agree to the Terms and Condition").fontWeight(.thin)
                        
                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                    
                    if self.loading{
                        HStack{
                            Spacer()
                            
                            Indicator()
                            
                            Spacer()
                        }
                    } else {
                        Button(action: {
                            if(self.agreeCheck){
                                self.createUser(email:self.email, password:self.password)
                            }
                            else{
                                 self.errorText = "Please Agree to the Terms and Condition"
                            }
                        }) {
                            Text("Sign up").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                        }.foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(0xFF3344), Color(0xFF4128)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                        .padding(.top, 15)
                        
                        Text(self.errorText).frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                    }
                }
            }
            Button(action: {
                self.show.toggle()
            }) {
                Image(systemName: "chevron.left").font(.title)
            }
        }.alert(isPresented: $showAlert, content: { self.alert })
        .padding()
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    func createUser(email: String, password: String) {
        self.loading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let _ = authResult?.user, error == nil else {
                let errorText: String = error?.localizedDescription ?? "unknown error"
                self.errorText = errorText
                self.loading.toggle()
                return
            }
            Auth.auth().currentUser?.sendEmailVerification { (error) in
                if let error = error {
                    self.errorText = error.localizedDescription
                    self.loading.toggle()
                    return
                }
                self.showAlert.toggle()
            }
        }
    }
}
