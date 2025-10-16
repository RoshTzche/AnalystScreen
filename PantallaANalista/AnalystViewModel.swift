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

    // Ahora usamos el servicio real por defecto
    init(service: LLMService = GeminiLLMService()) {
        self.service = service
    }

    // Arranca la sesión: agrega una tarjeta de bienvenida
    func startAnalysisSession() async {
        guard !hasStarted else { return }
        hasStarted = true
        isThinking = true
        
        do {
            let greeting = try await service.generateResponse(prompt:
                """
                SYSTEM PROMPT: Eres 'Ojo de Halcón', un analista de fútbol IA de clase mundial.
                TASK: Da la bienvenida al usuario en español. Sé profesional, pero cercano. Menciona que estás listo para analizar el partido. Máximo 2 líneas.
                """
            )
            let card = AnalysisCard(
                title: "Bienvenida del Analista",
                frontText: greeting,
                backText: "Pregúntame cualquier cosa sobre el partido o presiona el botón 'Obtener Análisis' para recibir una actualización en vivo."
            )
            cards.append(card)
        } catch {
            let fallback = AnalysisCard(
                title: "Bienvenida",
                frontText: "¡Hola! Soy tu analista virtual 'Ojo de Halcón'.",
                backText: "No pude generar un saludo dinámico. Revisa tu API Key e intenta de nuevo."
            )
            cards.append(fallback)
        }
        isThinking = false
    }

    // Genera una respuesta a la pregunta del usuario
    func sendMessage(text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isThinking = true
        
        do {
            let response = try await service.generateResponse(prompt:
                """
                SYSTEM PROMPT: Eres 'Ojo de Halcón', un analista de fútbol IA de clase mundial. Analizas un partido en vivo.
                USER QUERY: "\(text)"
                TASK: Responde a la consulta del usuario en español. Sé conciso (máximo 3-4 líneas), profesional y ofrece un insight táctico o estadístico si es posible. No saludes.
                """
            )

            let detail = "Esta tarjeta se generó a partir de tu pregunta. El análisis se basa en los datos disponibles hasta el momento."
            let newCard = AnalysisCard(title: "Análisis de Consulta", frontText: response, backText: detail)
            cards.append(newCard)
        } catch {
            let errorCard = AnalysisCard(title: "Error de Conexión", frontText: "No pude generar una respuesta.", backText: "Revisa tu conexión a internet o la configuración de tu API Key.")
            cards.append(errorCard)
        }
        isThinking = false
    }
    
    // Obtiene una actualización en vivo predefinida al presionar el botón
    func getLiveUpdate() async {
        isThinking = true
        
        do {
            let response = try await service.generateResponse(prompt:
                """
                SYSTEM PROMPT: Eres 'Ojo de Halcón', un analista de fútbol IA de clase mundial. Analizas un partido en vivo.
                TASK: Proporciona una actualización interesante sobre el estado actual del partido. Puede ser una estadística clave, una observación táctica o un momento destacado reciente. Sé breve y directo.
                """
            )
            
            let detail = "Esta es una actualización automática del partido. Puedes solicitar más detalles sobre este evento."
            let newCard = AnalysisCard(title: "Actualización en Vivo", frontText: response, backText: detail)
            cards.append(newCard)
        } catch {
            let errorCard = AnalysisCard(title: "Error de Conexión", frontText: "No pude obtener la actualización.", backText: "Revisa tu conexión a internet o la configuración de tu API Key.")
            cards.append(errorCard)
        }
        isThinking = false
    }
}

