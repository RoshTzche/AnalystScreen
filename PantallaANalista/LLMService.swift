//
//  LLMService.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import Foundation
import GoogleGenerativeAI

protocol LLMService {
    func generateResponse(prompt: String) async throws -> String
}


// MARK: - Gemini LLM Service

final class GeminiLLMService: LLMService {
    private var model: GenerativeModel

    init() {
      
        self.model = GenerativeModel(name: "gemini-2.5-flash", apiKey: APIKey.default)
    }
    
    func generateResponse(prompt: String) async throws -> String {
        do {
            let response = try await model.generateContent(prompt)
            
            guard let text = response.text else {
                throw NSError(domain: "LLMServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "La respuesta no contenía texto."])
            }
            
            return text
        } catch {
            print("Error al generar contenido de Gemini: \(error.localizedDescription)")
            throw error
        }
    }
}


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
