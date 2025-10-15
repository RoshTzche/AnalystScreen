//
//  AppColors.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import SwiftUI

enum AppColors {
    // Principal (puedes cambiar a Color("AppTint") más adelante)
    static let accent = Color.accentColor

    // Fondos semánticos
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)

    // Burbujas de chat
    static let bubbleUser = accent.opacity(0.12)
    static let bubbleAssistant = secondaryBackground

    // Separadores / líneas
    static let separator = Color(.separator)
}
