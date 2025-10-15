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
    // Tarjetas del carrusel
    @Published private(set) var cards: [AnalysisCard] = []
    // Estado de pensamiento/cálculo
    @Published var isThinking: Bool = false

    private let service: LLMService
    private var hasStarted = false

    init(service: LLMService = StubLLMService()) {
        self.service = service
    }

    // Arranca la sesión: agrega una tarjeta de bienvenida después de un pequeño delay
    func startAnalysisSession() async {
        guard !hasStarted else { return }
        hasStarted = true

        isThinking = true
        do {
            let greeting = try await service.generateGreeting(prompt:
                """
                Actúa como un analista amable y profesional. Da la bienvenida al usuario en español con un tono cercano y breve, en máximo 2 líneas.
                """
            )
            let card = AnalysisCard(
                title: "Bienvenida",
                frontText: greeting,
                backText: "Toca para ver más detalles o envía una pregunta abajo para generar nuevas tarjetas."
            )
            cards.append(card)
        } catch {
            let fallback = AnalysisCard(
                title: "Bienvenida",
                frontText: "¡Hola! Soy tu analista virtual. Listo para revisar tus datos y compartir insights.",
                backText: "No pude generar un saludo dinámico ahora mismo. Intenta enviar una pregunta para continuar."
            )
            cards.append(fallback)
        }
        isThinking = false
    }

    // Envía el texto del usuario y genera una nueva tarjeta como respuesta
    func sendMessage(text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isThinking = true

        // Opcional: podrías insertar una tarjeta "pendiente" mientras se genera la respuesta

        do {
            // Reutilizamos generateGreeting como generador de contenido por ahora
            let response = try await service.generateGreeting(prompt:
                """
                Responde en español, breve y claro (máximo 3 líneas), al siguiente input del usuario, con tono profesional y cercano. No saludes:
                "\(text)"
                """
            )

            // Para el reverso, podríamos dar una explicación corta o un detalle adicional
            let detail = """
            Detalle adicional:
            • Este contenido se generó a partir de tu mensaje.
            • Toca la tarjeta para voltearla de nuevo.
            """

            let newCard = AnalysisCard(
                title: "Respuesta",
                frontText: response,
                backText: detail
            )
            cards.append(newCard)
        } catch {
            let errorCard = AnalysisCard(
                title: "Error",
                frontText: "No pude generar una respuesta ahora mismo.",
                backText: "Revisa tu conexión o inténtalo nuevamente."
            )
            cards.append(errorCard)
        }

        isThinking = false
    }
}
