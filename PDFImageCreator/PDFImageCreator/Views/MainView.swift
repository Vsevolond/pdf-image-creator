//
//  MainView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI

struct MainView: View {
    
    @State private var galleryPresented = false
    @State private var documentsPresented = false
    
    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Сохраненное")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Menu {
                    Button {
                        galleryPresented.toggle()
                        
                    } label: {
                        Label("Из галереи", systemImage: galleryIcon)
                    }
                    
                    Button {
                        documentsPresented.toggle()
                        
                    } label: {
                        Label("Из файлов", systemImage: documentsIcon)
                    }


                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.indigo)
                }
            }
        }
        .sheet(isPresented: $galleryPresented) {
            GalleryImagePicker(isPresented: $galleryPresented) { results in
                
            }
        }
        .sheet(isPresented: $documentsPresented) {
            DocumentImagePicker(isPresented: $documentsPresented) { results in
                
            }
        }
    }
}

private let galleryIcon = "photo"
private let documentsIcon = "folder"

#Preview {
    MainView()
}
