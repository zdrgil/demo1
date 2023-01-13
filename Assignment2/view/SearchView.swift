//
//  SearchView.swift
//  Assignment2
//
//  Created by   Siu Chan on 13/1/2023.
//


import SwiftUI
import PhotosUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct SearchView: View {
    @State private var Gettingusers : [User] = []
    @State private var searchTxt : String = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
     
            List{
                ForEach(Gettingusers){ user in
                    NavigationLink {
                        Profilecontent(user: user)
                        
                    } label: {
                        Text(user.username)
                            .font(.callout)
                            .hAlign(.leading)
                    }

                }
                
            }
            .listStyle(.automatic)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Search")
            .searchable(text: $searchTxt)
            .onSubmit(of: .search, {
                Task{
                    await searchuser()
                }
            })
            .onChange(of: searchTxt, perform: { newValue in
                if newValue.isEmpty{
                    Gettingusers = []
                }
            })
       
        
    }
    func searchuser () async{
        do{
            let queryLowerCased = searchTxt.lowercased()
            let queryUpperCased = searchTxt.uppercased()
            let documnets = try await Firestore.firestore().collection("Users")
                .whereField("username", isGreaterThanOrEqualTo: queryUpperCased)
                .whereField("username", isLessThanOrEqualTo: "\(searchTxt)\u{f8ff}")
                .getDocuments()
            
            let users = try documnets.documents.compactMap { doc -> User? in try doc.data(as: User.self)
            }

            await MainActor.run(body: {
                Gettingusers = users
            })
        }catch{
            print(error.localizedDescription)
            
        }
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
