//
//  LoginPage.swift
//  shoong
//
//  Created by Matthew on 2020/02/10.
//  Copyright © 2020 Matthew. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginPage : View {
    
    @State private var showEmailAlert = false
    
    @State var email = ""
    @State var password = ""
    @State var show = false
    @State var verifyEmail: Bool = true
    @State var errorText: String = ""
    @State var loading = false
    
    var verifyEmailAlert: Alert {
        Alert(title: Text("Verify your Email ID"), message: Text("Please click the link in the verification email sent to you"), dismissButton: .default(Text("Dismiss")){
                self.email = ""
                self.verifyEmail = true
                self.password = ""
                self.errorText = ""
                self.loading = false
         })
    }
    
    var body : some View{
        VStack(spacing: 20){
            Image("shoong_black")
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(0xeeeeee))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 15)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(0xeeeeee))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack{
                Text("Don't have an account?")
                
                NavigationLink(destination: SignupPage(show: $show), isActive: $show){
                    Button(action: {
                        self.show.toggle()
                    }) {
                        Text("Sign up").underline()
                    }
                }
                
                Spacer()
            }
            
            if self.loading{
                HStack{
                    Spacer()
                    
                    Indicator()
                    
                    Spacer()
                }
            } else {
                Button(action: {
                    self.loginFunc(email:self.email, password:self.password)
                }) {
                    Text("Log in").frame(width: UIScreen.main.bounds.width - 30, height: 50)
                }.foregroundColor(.white)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(0xFF3344), Color(0xFF4128)]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .padding(.top, 15)
                
                Text(errorText).frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            }
            
            if (!verifyEmail) {

                Button(action: {

                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if let error = error {
                            self.errorText = error.localizedDescription
                            return
                        }
                    self.showEmailAlert.toggle()

                    }
                }) {

                    Text("Send Verify Email Again")
                   
                }
                
                

            }
            
        }
        .padding()
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showEmailAlert, content: { self.verifyEmailAlert })
    }
    
    func loginFunc(email: String, password: String) {
        
        self.loading.toggle()
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            
            if let error = error {
                    
                self.errorText = error.localizedDescription
                self.loading.toggle()
                return
                
            }

            
            guard user != nil else {
                self.loading.toggle()
                return
            }

            self.verifyEmail = user?.user.isEmailVerified ?? false

            
            if(!self.verifyEmail)
                {
                    self.errorText = "Please verify your email"
                    self.loading.toggle()
                    return
                }
            
            UserDefaults.standard.set(true, forKey: "status")
            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
        }
    }
}
