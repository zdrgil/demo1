//
//  Assignment2App.swift
//  Assignment2
//
//  Created by   Siu Chan on 9/1/2023.
//

import SwiftUI
import Firebase

@main
struct Assignment2App: App {
    init(){
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
               
        }
    }
}
