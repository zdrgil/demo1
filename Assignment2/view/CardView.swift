//
//  CardView.swift
//  Assignment2
//
//  Created by   Siu Chan on 12/1/2023.
//


import SDWebImageSwiftUI
import SwiftUI
import PhotosUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct CardView: View {
    var post : Post
    var onUpdate : (Post) ->()
    var onDelete : () -> ()
    
    @AppStorage("user_UID") var userUID : String = ""
    @State private var docListner : ListenerRegistration?
    
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35,height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6){
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date:.numeric,time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical,8)
                
                if let postimageURL = post.imageURL
                {
                    GeometryReader{
                        let size = $0.size
                        WebImage(url: postimageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width,height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                                       
                    }
                                .frame(height: 200)
                }
                    PostInterraction()
                    
            }
            
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing,content: {
            if post.userUID == userUID {
                Menu {
                    Button("Delete",role:.destructive, action: deletePost)
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x:8)

            }
        })
        .onAppear{
            if docListner == nil {
                guard let postid = post.id else{return}
                docListner = Firestore.firestore().collection("Post").document(postid).addSnapshotListener({ snapshot, error in
                    if let snapshot{
                        if snapshot.exists{
                            if let updatedpost =  try? snapshot.data(as:Post.self){
                                
                                onUpdate(updatedpost)
                                
                            
                                
                            }
                        }else{
                            onDelete()
                        }
                    }
                })
            }
        }
        
        .onDisappear{
            if let docListner{
                
                docListner.remove()
                self.docListner = nil
            }
        }
    }
    
    @ViewBuilder
    func PostInterraction ()-> some View {
        HStack(spacing: 6) {
            Button(action: likePost){
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill":"hand.thumbsup")
            }
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            
            
            Button (action: dislikePost){
                Image(systemName: post.dislikeIDS.contains(userUID) ? "hand.thumbsdown.fill":"hand.thumbsdown")
            }
            .padding(.leading,25)
            
            
            Text("\(post.dislikeIDS.count)")
                .font(.caption)
                .foregroundColor(.gray)
            

        }
        .foregroundColor(.blue)
        .padding(.vertical,8)
        
        
    }
    
    
    func likePost() {
        Task{
            guard let postID = post.id else{return}
            if post.likedIDs.contains(userUID){
                
                try await Firestore.firestore().collection("Post").document(postID).updateData(["likedIDs" : FieldValue.arrayRemove([userUID])])
                
            }else{
                try await Firestore.firestore().collection("Post").document(postID).updateData(["likedIDs" : FieldValue.arrayUnion([userUID]),
                "dislikeIDS" : FieldValue.arrayRemove([userUID])
                                                                                     ])
                

            }
        }
    }
    
    
    
    func dislikePost() {
        Task{
            guard let postID = post.id else{return}
            if post.dislikeIDS.contains(userUID){
                
                try await Firestore.firestore().collection("Post").document(postID).updateData(["dislikeIDS" : FieldValue.arrayRemove([userUID])])
                
            }else{
                try await Firestore.firestore().collection("Post").document(postID).updateData(["likedIDs" : FieldValue.arrayRemove([userUID]),
                "dislikeIDS" : FieldValue.arrayUnion([userUID])
                                                                                     ])
                

            }
        }
        
        
  
    }
    
    func deletePost () {
        Task{
            do{
                if post.imageReferenceID != ""{
                  try await   Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                guard let postid = post.id else{return}
                try await Firestore.firestore().collection("Post").document(postid).delete()
            }catch{
                print(error.localizedDescription)
                
            }
            
        }
        
    }
}


