//
//  mainview.swift
//  Assignment2
//
//  Created by   Siu Chan on 11/1/2023.
//

import SwiftUI

struct mainview: View {
    var body: some View {
     
        TabView{
                Postview()
                .tabItem {
                    Image(systemName: "house")
                    Text("Main")
                }
                profileview()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
            
        }
        .tint(.black)
        
    }
}

struct mainview_Previews: PreviewProvider {
    static var previews: some View {
        mainview()
    }
}




