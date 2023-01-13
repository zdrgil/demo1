//
//  ReusePostView.swift
//  Assignment2
//
//  Created by   Siu Chan on 12/1/2023.
//


import SwiftUI
import PhotosUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ReusePostView: View {
    var basedUID : Bool = false
    var uid : String = ""
    @Binding var posts:[Post]
    @State private var isGeting : Bool = false
    @State private var paginationdoc : QueryDocumentSnapshot?
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            LazyVStack{
                if isGeting{
                    ProgressView()
                        .padding(.top,30)
                    
                    
                }else{
                    if posts.isEmpty{
                        Text("0 post found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top,30)
                        
                    }else{
                        Posts()
                        
                    }
                }
            }
            .padding(15)
            
        }
        .refreshable {
            guard !basedUID else{return}
            isGeting = true
            posts = []
            paginationdoc = nil
            await getPosts()
        }
        .task {
            guard posts.isEmpty else{return}
            await getPosts()
        }
    }
    
    @ViewBuilder
    func Posts()->some View{
        ForEach(posts){ post in
            CardView(post: post) { updatedpost in
                
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedpost.id
                }){
                    
                    posts[index].likedIDs = updatedpost.likedIDs
                    posts[index].dislikeIDS = updatedpost.dislikeIDS
                    
                }
            } onDelete: {
                withAnimation(.easeInOut(duration: 0.25)){
                    posts.removeAll{post.id == $0.id }
                }
                
            }
            .onAppear{
                if post.id == posts.last?.id && paginationdoc != nil {
                    Task{
                        await getPosts()
                    }
                }
            }
            
            Divider()
                .padding(.horizontal,-15)

           
        }
        
    }
    
    
    func getPosts() async {
        do{
            var query: Query!
            if let paginationdoc{
                query = Firestore.firestore().collection("Post")
                    .order(by: "publishedDate",descending: true)
                    .start(afterDocument: paginationdoc)
                    .limit(to: 10)

            }else{
                query = Firestore.firestore().collection("Post")
                    .order(by: "publishedDate",descending: true)
                    .limit(to: 10)
            }
            if basedUID {
                query = query.whereField("userUID", isEqualTo: uid)
            }
        
            let docum    = try await query.getDocuments()
            let getingposts = docum.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
                
            }
            await MainActor.run(body: {
                posts.append(contentsOf: getingposts)
                paginationdoc = docum.documents.last
                isGeting = false
            })
            
        }catch{
            
            print(error.localizedDescription)
            
        }
    }
}

struct ReusePostView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
