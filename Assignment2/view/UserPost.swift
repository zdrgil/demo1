//
//  UserPost.swift
//  Assignment2
//
//  Created by   Siu Chan on 11/1/2023.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct UserPost: View {
    var onPost: (Post)->()
    @State  private var postText : String = ""
    @State  private var postImageData : Data?
    @AppStorage("user_profile_url")  private var profileURL : URL?
    @AppStorage("user_name") private var usernamestored : String = ""
    @AppStorage("user_UID") private var userUID : String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var errmsg : String = ""
    @State private var errshow : Bool = false
    @State private var isLoading : Bool = false
    @State var showpicker : Bool = false
    @State var photoitem : PhotosPickerItem?
    @FocusState private var showkeyboard : Bool


    var body: some View {
        VStack{
            HStack{
                Menu {
                    Button("Cancel",role: .destructive){
                        dismiss()
                    }
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(.black)
                    
                }
                .hAlign(.leading)
                Button(action:{createPost()}){
                    Text("Post")
                                            .font(.callout)
                                            .foregroundColor(.white)
                                            .padding(.horizontal,20)
                                            .padding(.vertical,6)
                                            .background(.black,in: Capsule())
                
                
                                    }
                .disableopacity(postText == "" )
                

            }
            .padding(.horizontal,15)
                       .padding(.vertical,10)
                       .background{
                           Rectangle()
                               .fill(.gray.opacity(0.05))
                               .ignoresSafeArea()
                       }
            ScrollView(.vertical,showsIndicators: false){
                VStack(spacing: 15){
                    TextField("GUqing", text: $postText,axis: .vertical)
                    
                        .focused($showkeyboard)
                    
                    if let postImageData , let image = UIImage(data: postImageData){
                        GeometryReader{
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width,height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                                .overlay(alignment: .topTrailing){
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)){
                                            self.postImageData = nil
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }

                                }
                        }
                        .clipped()
                        .frame(height: 220)
                        
                    }
                }
                .padding(15)
            }
            Divider()
            HStack{
                Button {
                    showpicker.toggle()
                    
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                        .foregroundColor(.black)
                    
                }
                .hAlign(.leading)
                Button("Done"){
                    showkeyboard = false
                    
                }
                
                
            }
            .foregroundColor(.black)
            .padding(.horizontal,15)
            .padding(.vertical,10)
            
        }
        .vAlign(.top)
        .photosPicker(isPresented: $showpicker, selection: $photoitem)
        .onChange(of: photoitem) { newValue in
            if let newValue{
                Task{
                    do{
                        
                            if let imageData2 = try await newValue.loadTransferable(type: Data.self),let image = UIImage(data: imageData2), let
                                    compressedImageData = image.jpegData(compressionQuality: 0.5){
                                        await MainActor.run(body: {
                                            postImageData = compressedImageData
                                            photoitem = nil
                                        })
                                    }
                        
                    }catch{
                        await setError(error)
                        
                    }
                 
                  
             
                }
            }
        }
        .alert(errmsg,isPresented: $errshow, actions: {})
        .overlay {
            Loginstatus(show: $isLoading)
        }
    }
    
    func createPost() {
        isLoading = true
        showkeyboard = false
        Task{
            do{
                guard let profileURL = profileURL else{return}
                let imageRefID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageRefID)
                if let postImageData {
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let downURL = try await storageRef.downloadURL()
                    let post = Post(text: postText, imageURL: downURL,imageReferenceID: imageRefID,userName: usernamestored, userUID: userUID, userProfileURL: profileURL)
                    try await createDt(post)
                    
                    
                    
                }else {
                    let post = Post(text: postText, userName: usernamestored, userUID: userUID, userProfileURL: profileURL)
                    try await createDt(post)
                    
                }
                
            }catch{
                await setError(error)
            }
        }
        
    }
    
    func createDt(_ post:Post)async throws{
        
        let doc = Firestore.firestore().collection("Post").document()
    let _ = try doc.setData(from: post,completion: { error in
            if error == nil{
                var updatedPost = post
                isLoading = false
                onPost(updatedPost)
                dismiss()
            }
        })
    }
    
    
    func setError(_ error: Error)async{
        await MainActor.run(body: {
            print(error)
            errmsg = error.localizedDescription
            errshow.toggle()
            isLoading = false
        })
    }
}

struct UserPost_Previews: PreviewProvider {
    static var previews: some View {
        UserPost{
            _ in
        }
    }
}
