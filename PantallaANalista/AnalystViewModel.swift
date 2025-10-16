// En: AnalystViewModel.swift

import Foundation
import Combine

@MainActor
final class AnalystViewModel: ObservableObject {
    @Published private(set) var cards: [AnalysisCard] = []
    @Published var isThinking: Bool = false
    @Published private(set) var liveMatchData: LiveMatchData

    private let service: LLMService
    private let matchSimulator = MatchSimulator()
    private var cancellables = Set<AnyCancellable>()

    init(service: LLMService = GeminiLLMService()) {
        self.service = service
        self.liveMatchData = LiveMatchData.placeholder()
        Task { await setupSimulatorSubscription() }
    }

    private func setupSimulatorSubscription() async {
        await matchSimulator.$matchData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMatchData in self?.liveMatchData = newMatchData }
            .store(in: &cancellables)
    }

    // --- FUNCIONES DE INTERACCIÓN (AHORA COMPLETAS Y FUNCIONALES) ---

    func startAnalysisSession() async {
        guard cards.isEmpty else { return }
        await matchSimulator.start()
        let card = AnalysisCard(
            title: "Bienvenida del Analista",
            frontText: "¡Bienvenido/a! Soy Ojo de Halcón. El partido está por comenzar. Gira esta tarjeta para ver las estadísticas en vivo.",
            backText: "Puedes interactuar con las estadísticas para obtener análisis detallados."
        )
        cards.append(card)
    }
    
    // ¡LÓGICA RESTAURADA Y MEJORADA!
    func sendMessage(text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isThinking = true
        let currentData = self.liveMatchData
        
        let prompt = """
        SYSTEM PROMPT: Eres 'Ojo de Halcón', un analista de fútbol IA.
        CONTEXTO: Minuto \(currentData.matchTime), \(currentData.homeTeam.name) vs \(currentData.awayTeam.name).
        USER QUERY: "\(text)"
        TASK: Responde a la consulta del usuario en español. Sé conciso (máximo 3 líneas), profesional y ofrece un insight táctico o estadístico si es posible. No saludes.
        """
        do {
            let response = try await service.generateResponse(prompt: prompt)
            cards.append(AnalysisCard(title: "Análisis de Consulta", frontText: response, backText: "Análisis del minuto \(currentData.matchTime)."))
        } catch {
            cards.append(AnalysisCard(title: "Error de Conexión", frontText: "No pude generar una respuesta.", backText: "Revisa tu conexión o la API Key."))
        }
        isThinking = false
    }
    
    func getLiveUpdate() async {
        isThinking = true
        let currentData = self.liveMatchData

        let prompt = """
        SYSTEM PROMPT: Eres 'Ojo de Halcón', un analista de fútbol IA.
        CONTEXTO: Minuto \(currentData.matchTime), \(currentData.homeTeam.name) vs \(currentData.awayTeam.name). Posesión: \(Int(currentData.homeStats.possession * 100))% / \(Int(currentData.awayStats.possession * 100))%.
        TASK: Proporciona una actualización interesante sobre el estado actual del partido. Puede ser una estadística clave, una observación táctica o un momento destacado reciente. Sé breve y directo.
        """
        do {
            let response = try await service.generateResponse(prompt: prompt)
            cards.append(AnalysisCard(title: "Actualización en Vivo", frontText: response, backText: "Actualización del minuto \(currentData.matchTime)."))
        } catch {
            cards.append(AnalysisCard(title: "Error de Conexión", frontText: "No pude obtener la actualización.", backText: "Revisa tu conexión o la API Key."))
        }
        isThinking = false
    }

    func explainStat(_ statName: String) async {
        isThinking = true
        let currentData = self.liveMatchData
        let prompt = """
        SYSTEM PROMPT: Eres 'Ojo de Halcón', un analista de fútbol IA.
        CONTEXTO: Minuto \(currentData.matchTime), \(currentData.homeTeam.name) vs \(currentData.awayTeam.name). Posesión: \(Int(currentData.homeStats.possession * 100))%/\(Int(currentData.awayStats.possession * 100))%. Tiros: \(currentData.homeStats.shots)/\(currentData.awayStats.shots).
        USER QUERY: Explica la estadística de '\(statName)'.
        TASK: En español, explica qué significa esta estadística en el contexto actual del partido. Sé conciso (2-3 líneas) y ofrece un insight táctico. No saludes.
        """
        do {
            let response = try await service.generateResponse(prompt: prompt)
            cards.append(AnalysisCard(title: "Análisis de: \(statName)", frontText: response, backText: "Análisis del minuto \(currentData.matchTime)."))
        } catch {
            cards.append(AnalysisCard(title: "Error de Análisis", frontText: "No pude analizar la estadística.", backText: "Hubo un problema de conexión."))
        }
        isThinking = false
    }
}
