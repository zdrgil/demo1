//
//  Profilecontent.swift
//  Assignment2
//
//  Created by   Siu Chan on 11/1/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct Profilecontent: View {
    @State private var GettingPost: [Post] = []
    var user: User
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            LazyVStack{
                HStack(spacing:12){
                    WebImage(url: user.userProfileURL).placeholder{
                        Image("NullProfile")
                            .resizable()
                    }
                    .resizable()
                    
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100 , height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6){
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                    }
                    .hAlign(.leading)
                }
                
                Text("Posts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical,15)
                
                ReusePostView(basedUID: true, uid : user.userUID,posts: $GettingPost)
                
            }
            .padding(15)
        }
    }
}


