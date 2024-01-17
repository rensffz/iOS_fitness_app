//
//  Customize.swift
//  project
//
//  Created by Анастасия Сергеева on 01.01.2024.
//

import SwiftUI

struct RadioButton: View {
    var text: String
    var isSelected: Bool
    var callback: () -> ()

    var body: some View {
        Button(action: {
            callback()
        }) {
            HStack {
                Rectangle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? Color(hex: "#007351") : .white)
                    .cornerRadius(5)
                Text(text)
            }
            .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

extension View {
    @ViewBuilder
    func customText(_ text: String) -> some View {
        Text(text)
            .font(Font.custom("Comfortaa", size: 20))
    }
}
