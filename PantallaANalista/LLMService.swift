//
//  LLMService.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import Foundation

protocol LLMService {
    func generateGreeting(prompt: String) async throws -> String
}

/// Implementación inicial sin dependencias externas.
/// Simula latencia y devuelve un saludo.
struct StubLLMService: LLMService {
    func generateGreeting(prompt: String) async throws -> String {
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8s
        return "¡Hola! Soy tu analista virtual. Estoy listo para revisar tus datos y compartir insights cuando estén disponibles."
    }
}
