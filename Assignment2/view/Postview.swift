//
//  Postview.swift
//  Assignment2
//
//  Created by   Siu Chan on 12/1/2023.
//

import SwiftUI

struct Postview: View {
    @State private var currentPosts:[Post] = []
    @State private var createNewPost : Bool = false
    var body: some View {
        
        NavigationStack{
            ReusePostView(posts: $currentPosts)
            .hAlign(.center).vAlign(.center)
                .overlay(alignment: .bottomTrailing){
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.blue,in: Circle())
                    }
                    .padding(15)

                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchView()
                        } label: {
                           Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                            
                        }

                    }
                })
                .navigationTitle("Posts")
        }
 
            .fullScreenCover(isPresented: $createNewPost) {
                UserPost { post in
                    currentPosts.insert(post, at: 0)
                }
            }
        
           
            }
        
    }


struct Postview_Previews: PreviewProvider {
    static var previews: some View {
        Postview()
    }
}
