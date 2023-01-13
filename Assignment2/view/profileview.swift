//
//  profileview.swift
//  Assignment2
//
//  Created by   Siu Chan on 11/1/2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct profileview: View {
    @State private var userprofile:User?
    @AppStorage("log_status") var logStatus : Bool = false
    @State var errmsg : String = ""
    @State var errshow : Bool = false
    @State var isLoading : Bool = false
    var body: some View {
        NavigationStack{
            VStack{
                if let userprofile{
                    Profilecontent(user: userprofile)
                        .refreshable {
                            self.userprofile = nil
                            await fetchuser()
                        }
                    
                }else{
                    ProgressView()
                }
            }
          
           
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        Button("Logout") {
                            logout()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
            .overlay{
                Loginstatus(show: $isLoading)
                
            }
            .alert(errmsg, isPresented: $errshow) {
                
            }
            .task {
                if userprofile != nil{return}
                await fetchuser()
            }
        }
        
        
      
    }
    
    func fetchuser() async{
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        guard let user =  try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else {return}
        await MainActor.run(body: {
            userprofile = user
        })
        
        
    }
    
    func logout(){
        isLoading = true
        try? Auth.auth().signOut()
        logStatus = false
         
    }
    
    
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            errmsg = error.localizedDescription
            errshow.toggle()
            isLoading = false
        })
    }
}

struct profileview_Previews: PreviewProvider {
    static var previews: some View {
        profileview()
    }
}
