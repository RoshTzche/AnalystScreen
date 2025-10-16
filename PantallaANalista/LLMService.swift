//
//  LLMService.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import Foundation
import GoogleGenerativeAI

// El protocolo no cambia. ¡Esta es la belleza de una buena arquitectura!
protocol LLMService {
    func generateResponse(prompt: String) async throws -> String
}


// MARK: - Gemini LLM Service (Implementación Real)

final class GeminiLLMService: LLMService {
    private var model: GenerativeModel

    init() {
        // --- IMPORTANTE: Manejo de la Clave de API ---
        // Pega tu clave de API en el archivo APIKey.swift que crearemos a continuación.
        // NO escribas la clave directamente aquí para evitar subirla a Git.
        self.model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: APIKey.default)
    }
    
    // Esta función se comunicará con la API de Gemini.
    func generateResponse(prompt: String) async throws -> String {
        do {
            let response = try await model.generateContent(prompt)
            
            // Verificamos si el modelo nos dio una respuesta de texto.
            guard let text = response.text else {
                throw NSError(domain: "LLMServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "La respuesta no contenía texto."])
            }
            
            return text
        } catch {
            // Si hay un error, lo imprimimos para depuración y lo relanzamos.
            print("Error al generar contenido de Gemini: \(error.localizedDescription)")
            throw error
        }
    }
}


// MARK: - Stub LLM Service (Para Pruebas y Previews)

/// Dejamos nuestro Stub para poder hacer pruebas offline o desarrollar la UI sin gastar cuota de API.
struct StubLLMService: LLMService {
    func generateResponse(prompt: String) async throws -> String {
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8s
        
        if prompt.contains("bienvenida") {
            return "¡Hola! Soy tu analista virtual. Estoy listo para compartir insights del partido."
        } else {
            return "Esta es una respuesta simulada para tu pregunta: '\(prompt.prefix(50))...'"
        }
    }
}
