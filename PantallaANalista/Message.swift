//
//  Message.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import Foundation

enum MessageRole: String, Codable {
    case assistant
    case system
    case user
}

struct Message: Identifiable, Hashable, Codable {
    let id: UUID
    let role: MessageRole
    let text: String
    let timestamp: Date

    init(id: UUID = UUID(), role: MessageRole, text: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}
