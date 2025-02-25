//
//  WelcomeView.swift
//  PDFImageCreator
//
//  Created by Всеволод Донченко on 20.02.2025.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage(.welcomeScreenShowStatus) var isWelcomeScreenShown = false
    
    var body: some View {
        VStack {
            Image(.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80)
                .clipShape(.rect(cornerRadius: 20))
            
            Text("Добро пожаловать в")
                .font(.title)
                .bold()
            
            Text("PDFImageCreator")
                .font(.title2)
                .bold()
                .foregroundStyle(.indigo)
            
            List {
                CapabilityView(
                    icon: convertIcon,
                    color: .green,
                    title: "Конвертируйте",
                    description: convertText
                )
                
                CapabilityView(
                    icon: mergeIcon,
                    color: .red,
                    title: "Объединяйте",
                    description: mergeText
                )
                
                CapabilityView(
                    icon: saveIcon,
                    color: .yellow,
                    title: "Сохраняйте",
                    description: saveText
                )
                
                CapabilityView(
                    icon: shareIcon,
                    color: .blue,
                    title: "Делитесь",
                    description: shareText
                )
            }
            .listStyle(.plain)
            .padding(.top)
            
            Button {
                isWelcomeScreenShown = true
                
            } label: {
                Text("Приступить")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.indigo)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(.horizontal, 40)
            }
            .padding(.bottom)
        }
    }
    
    private func CapabilityView(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
        .listRowSeparator(.hidden)
    }
}

private let convertIcon = "arrow.trianglehead.2.clockwise.rotate.90"
private let mergeIcon = "square.2.layers.3d"
private let saveIcon = "tray.and.arrow.down"
private let shareIcon = "square.and.arrow.up"

private let convertText = "Преобразование изображений из галереи или файловой системы в PDF-документ. Поддерживает обработку нескольких изображений за раз."
private let mergeText = "Слияние нескольких PDF-документов в один файл. Удобно для создания единого документа из разных источников."
private let saveText = "Сохранение готового PDF-документа на устройство. Можно выбрать папку или добавить файл в Загрузки."
private let shareText = "Быстрая отправка созданного PDF через мессенджеры, почту или другие приложения."

#Preview {
    WelcomeView()
}
