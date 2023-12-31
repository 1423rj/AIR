//
//  ContentView.swift
//  AIR
//
//  Created by Riley Pederson on 20/9/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: UserSettings
    var body: some View {
        NavigationView {
            TabView {
                HomePageView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                
                ProgramView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Program")
                    }
                
                ProgressView(oneRM: settings.oneRM)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Progress")
                    }
                
            }
            .navigationBarTitle("AIR", displayMode: .large)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
    }
}
