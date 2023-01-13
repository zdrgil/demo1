//
//  LoginView2.swift
//  Assignment2
//
//  Created by   Siu Chan on 9/1/2023.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct LoginView2: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var showPassword: Bool = false
    @State var creatAccount : Bool = false
    @State var errorshow:Bool = false
    @State var errorMsg : String = ""
    @State var isLoading : Bool = false
    @AppStorage("log_status") var logStatus : Bool = false
    @AppStorage("user_profile_url") var profileURL : URL?
    @AppStorage("user_name") var usernamestored : String = ""
    @AppStorage("user_UID") var userUID : String = ""

     var isSignInButtonDisabled: Bool {
        [email, password].contains(where: \.isEmpty)
    }
    var body: some View {
        
        GeometryReader {
            geometry in
            ZStack{
                Image("bg4")
                    .resizable()
                    .aspectRatio(geometry.size, contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
            }
            VStack(spacing: 10){
                Text("Sign in ")
                    .font(.largeTitle.bold())
                    .hAlign(.leading)
                    .foregroundColor(.white)
                VStack{
                    
                    
                    TextField("email",
                              text: $email ,
                              prompt: Text("Email").foregroundColor(.black)
                    )
                    .padding(15)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.blue, lineWidth: 2)
                    }
                    .padding()

                    HStack {
                        
                        Group {
                            if showPassword {
                                TextField("Password", // how to create a secure text field
                                            text: $password,
                                            prompt: Text("Password").foregroundColor(.black)) // How to change the color of the TextField Placeholder
                            } else {
                                SecureField("Password", // how to create a secure text field
                                            text: $password,
                                            prompt: Text("Password").foregroundColor(.black)) // How to change the color of the TextField Placeholder
                            }
                        }
                        .padding(15)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.blue, lineWidth: 2) // How to add rounded corner to a TextField and change it colour
                        }
                        

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.red) // how to change image based in a State variable
                        }
                        

                    }.padding(.horizontal)
                    
                    
                    
                  
                    
                    Button("Reset",action: resetPassword)
                        .font(.callout)
                        .fontWeight(.medium)
                        .tint(.blue)
                        .hAlign(.trailing)
                        .padding(15)
                    
                    Spacer()

                    Button (
                        action: loginUser
                    ){
                        Text("Sign In")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity) // how to make a button fill all the space available horizontaly
                    .background(
                        isSignInButtonDisabled ?
                        LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.blue, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                        
                    )
                    
                    .cornerRadius(20)
                    .disabled(isSignInButtonDisabled) // how to disable while some condition is applied
                    .padding()
                    
                    HStack{
                        Text("Dont have account?")
                            .foregroundColor(.gray)
                        Button("Register now"){
                            creatAccount.toggle()
                            
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        
                        
                    }
                    .font(.callout)
                    
                    
                    
                }
              
               
            }
        
            .vAlign(.top)
            .padding(10)
            .overlay(content:{
                Loginstatus(show: $isLoading)
            })
            .fullScreenCover(isPresented: $creatAccount){
                RegisterView()
            }
         .alert(errorMsg,isPresented: $errorshow, actions: {})
        }
       
//
    }
    
    func loginUser() {
        isLoading = true
        closekeyboard()
        Task{
            do{
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("User Found")
                try await fetchUser()

            }catch{
                print(error)
                
            }
        }
    }
    
    func resetPassword(){
        Task{
            do{
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("Link Sent")
            }catch{
                await setError(error)
                isLoading = false
                
            }
        }
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else{return}
       let User =  try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        await MainActor.run(body: {
            userUID = userID

            usernamestored = User.username
            profileURL = User.userProfileURL
            logStatus = true
        })
    }
    
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            errorMsg = error.localizedDescription
            errorshow.toggle()
            isLoading = false
        })
    }
}



struct LoginView2_Previews: PreviewProvider {
    static var previews: some View {
        LoginView2()
    }
}


struct RegisterView: View{
    @State var email: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var profilePic : Data?
    
    @Environment(\.dismiss) var dismiss
    @State var showpicker : Bool = false
    @State var photoitem : PhotosPickerItem?
    @State var errorshow:Bool = false
    @State var errorMsg : String = ""
    @State var isLoading : Bool = false
    @AppStorage("log_status") var logStatus : Bool = false
    @AppStorage("user_profile_url") var profileURL : URL?
    @AppStorage("user_name") var usernamestored : String = ""
    @AppStorage("user_UID") var userUID : String = ""
    var body: some View{
        
        
        VStack(spacing: 10){
            Text("Register")
                .font(.largeTitle.bold())
            
            
            
    
            
            VStack(spacing: 12){
                
                ViewThatFits{
                    ScrollView(.vertical,showsIndicators: false){
                        View123()
                    }
                    View123()
                }

                
                HStack{
                    Text("Already have account?")
                        .foregroundColor(.gray)
                    Button("Login now"){
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    
                }
                .font(.callout)
                .vAlign(.bottom)
            }
                .vAlign(.top)
                .padding(10)
                .overlay(content:{
                    Loginstatus(show: $isLoading)
                })
                .photosPicker(isPresented: $showpicker, selection: $photoitem)
                .onChange(of: photoitem){ newValue in
                    if let newValue{
                        Task{
                            do{
                                guard let imageData = try await newValue.loadTransferable(type: Data.self) else{return}
                                await MainActor.run(body: {
                                    profilePic = imageData
                                })
                            }catch{}
                        }
                    }
                }
                .alert(errorMsg,isPresented: $errorshow, actions: {})

        }
        
            
            
             
        
    }
    
    @ViewBuilder
    func View123()->some View{
        VStack(spacing: 10){
            ZStack{
                if let profilePic, let image = UIImage(data: profilePic){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                }else {
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                
            }
            .frame(width: 85,height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showpicker.toggle()
            }
            .padding(.top,25)
            
            
            TextField("Name",text:$userName)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Email",text:$email)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            
            SecureField("Password",text:$password)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            
            Button( action: registerUser){
                Text("sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .disableopacity(userName == "" || email == "" || password ==
            "" || profilePic == nil  )
            .padding(.top,10)
        }
    }
    func registerUser ()   {
        isLoading = true
        closekeyboard()
        Task{
            do{
                try await  Auth.auth().createUser(withEmail: email, password: password)
                
                guard let userUID =  Auth.auth().currentUser?.uid else{return}
                guard let imageData = profilePic else{return}
                let storageRe = Storage.storage().reference().child("profile_images").child(userUID)
                let _ = try await storageRe.putDataAsync(imageData)
                let downloadURL =  try await storageRe.downloadURL()
                let user = User(username: userName, userUID: userUID, userEmail: email, userProfileURL: downloadURL)
                let _ =  try Firestore.firestore().collection("Users").document(userUID).setData(from: user,completion: { error in
                    if error == nil {
                        print ("Saved")
                        usernamestored = userName
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                        
                    }
                })
                
                
                
            }catch{
                await setError(error)
                try await Auth.auth().currentUser?.delete()
                
                
            }
            
            
        }
    }
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            print(error)
            errorMsg = error.localizedDescription
            errorshow.toggle()
            isLoading = false
        })
    }
    
}

extension View{
    
    func closekeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func disableopacity(_ condititon : Bool)->some View{
        self
            .disabled(condititon)
            .opacity(condititon ? 0.6 : 1)
    }
    func hAlign(_ alignment: Alignment) ->some View{
        self
            .frame(maxWidth: .infinity,alignment: alignment)
        
    }
    func vAlign(_ alignment: Alignment) ->some View{
        self
        .frame(maxHeight: .infinity,alignment: alignment)

    }
    
    func border(_ width: CGFloat,_ color: Color) ->some View{
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color,lineWidth: width)
            }
    }
    
    func fillView(_ color: Color) ->some View{
        self
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}
