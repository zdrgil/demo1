//
//  User.swift
//  Assignment2
//
//  Created by   Siu Chan on 9/1/2023.
//

import FirebaseFirestoreSwift
import Foundation

struct User : Identifiable,Codable {
    @DocumentID var id: String?
    var username : String
    var userUID : String
    var userEmail : String
    var userProfileURL : URL
    
    
    enum CodingKeys : CodingKey{
        case id
        case username
        case userUID
        case userEmail
        case userProfileURL
        
    }
}
