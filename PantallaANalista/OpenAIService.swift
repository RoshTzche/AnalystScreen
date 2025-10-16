//
//  OpenAIService.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import Foundation

struct OpenAIService: LLMService {
    func generateResponse(prompt: String) async throws -> String {
        <#code#>
    }
    
    let apiKey: String
    let model: String
    var baseURL: URL = URL(string: "https://api.openai.com/v1/chat/completions")!

    init(apiKey: String, model: String = "gpt-4o-mini") {
        self.apiKey = apiKey
        self.model = model
    }

    func generateGreeting(prompt: String) async throws -> String {
        // Simple Chat Completions request with a single user message
        let requestBody = ChatRequest(
            model: model,
            messages: [
                .init(role: "user", content: prompt)
            ],
            temperature: 0.7
        )

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "OpenAIService", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "HTTP error. Body: \(body)"])
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        if let text = decoded.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            return text
        } else {
            throw NSError(domain: "OpenAIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
        }
    }
}

// MARK: - DTOs

private struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double?
    // Add other params if needed (max_tokens, top_p, etc.)

    struct ChatMessage: Encodable {
        let role: String
        let content: String?
    }
}

private struct ChatResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let index: Int
        let message: Message
    }

    struct Message: Decodable {
        let role: String
        let content: String?
    }
}
