//
//  AnalystViewModel.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import Foundation
import Combine

@MainActor
final class AnalystViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var isThinking: Bool = false

    private let service: LLMService
    private var hasGreeted = false

    init(service: LLMService = StubLLMService()) {
        self.service = service
    }

    func sendGreeting() async {
        guard !hasGreeted else { return }
        hasGreeted = true
        isThinking = true

        let systemPrompt = """
        Actúa como un analista amable y profesional. Da la bienvenida al usuario en español con un tono cercano y breve, indicando que analizarás los datos cuando estén disponibles.
        """

        do {
            let greeting = try await service.generateGreeting(prompt: systemPrompt)
            messages.append(Message(role: .assistant, text: greeting))
        } catch {
            messages.append(Message(role: .assistant, text: "Hola, soy tu analista. (No he podido generar el saludo en este momento.)"))
        }

        isThinking = false
    }
}
