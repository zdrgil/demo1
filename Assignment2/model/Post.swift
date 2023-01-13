//
//  Post.swift
//  Assignment2
//
//  Created by   Siu Chan on 11/1/2023.
//

import Foundation
import FirebaseFirestoreSwift


struct Post: Identifiable,Codable,Equatable,Hashable {
    @DocumentID var id: String?
    
    var text : String
    var imageURL : URL?
    var imageReferenceID: String = ""
    var publishedDate : Date = Date()
    var likedIDs : [String] = []
    var dislikeIDS : [String] = []
    
    var userName : String
    var userUID : String
    var userProfileURL : URL
    
    enum CodingKeys: CodingKey {
        case id
        
        case text
        case imageURL
        case imageReferenceID
        case publishedDate
        case likedIDs
        case dislikeIDS
        
        case userName
        case userUID
        case userProfileURL

    }
}
