//
//  ContentView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(.welcomeScreenShowStatus) var isWelcomeScreenShown = false
    
    var body: some View {
        ZStack {
            if isWelcomeScreenShown {
                MainView()
                    .transition(.opacity)
                
            } else {
                WelcomeView()
                    .transition(.opacity)
            }
        }
        .animation(.snappy, value: isWelcomeScreenShown)
    }
}

#Preview {
    ContentView()
}
