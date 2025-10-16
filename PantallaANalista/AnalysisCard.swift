//
//  AnalysisCard.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import Foundation

struct AnalysisCard: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    let title: String?
    let frontText: String
    let backText: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        title: String? = nil,
        frontText: String,
        backText: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.frontText = frontText
        self.backText = backText
        self.timestamp = timestamp
    }
}

