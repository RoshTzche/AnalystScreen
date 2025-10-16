import Foundation
import Combine

/// Un actor que gestiona y simula el estado en tiempo real de un partido de fútbol.
actor MatchSimulator {
    
    /// Publica los cambios en los datos del partido para que los observadores (como el ViewModel) puedan reaccionar.
    @Published private(set) var matchData: LiveMatchData

    private var simulationTimer: Timer?

    /// Inicializa el simulador con un estado de partido de ejemplo.
    init() {
        self.matchData = LiveMatchData.placeholder()
    }

    /// Inicia el ciclo de simulación del partido.
    func start() {
        // Nos aseguramos de no crear múltiples timers.
        guard simulationTimer == nil else { return }
        
        // Creamos un temporizador que llama a `updateMatchState` cada 5 segundos.
        simulationTimer = Timer(timeInterval: 5.0, repeats: true) { [weak self] _ in
            // Usamos Task para llamar a la función asíncrona del actor desde el timer.
            Task {
                await self?.updateMatchState()
            }
        }
        
        // Añadimos el timer al "run loop" principal para que se ejecute.
        if let timer = simulationTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    /// Detiene la simulación del partido.
    func stop() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }

    /// El núcleo de la simulación. Esta función modifica las estadísticas de forma aleatoria.
    private func updateMatchState() {
        // Avanza el tiempo del partido, hasta un máximo de 90 minutos.
        guard matchData.matchTime < 90 else {
            stop()
            return
        }
        matchData.matchTime += 5 // Cada tick son 5 minutos de partido

        // --- Lógica de Simulación de Eventos ---
        
        // 1. Simular cambio de posesión
        let possessionShift = Double.random(in: -0.08...0.08)
        matchData.homeStats.possession = max(0, min(1, matchData.homeStats.possession + possessionShift))
        matchData.awayStats.possession = 1.0 - matchData.homeStats.possession
        
        // 2. Simular pases
        matchData.homeStats.passes += Int.random(in: 15...40)
        matchData.awayStats.passes += Int.random(in: 15...40)
        
        // 3. Simular un tiro (más probable para el equipo con más posesión)
        if Double.random(in: 0...1) < (matchData.homeStats.possession * 0.7) { // 70% de probabilidad ponderada
            matchData.homeStats.shots += 1
            // Probabilidad de que el tiro vaya a puerta
            if Bool.random() {
                matchData.homeStats.shotsOnTarget += 1
            }
        }
        
        if Double.random(in: 0...1) < (matchData.awayStats.possession * 0.7) {
            matchData.awayStats.shots += 1
            if Bool.random() {
                matchData.awayStats.shotsOnTarget += 1
            }
        }
        
        // 4. Simular una falta
        if Int.random(in: 1...10) > 8 { // 20% de probabilidad
            if Bool.random() {
                matchData.homeStats.fouls += 1
            } else {
                matchData.awayStats.fouls += 1
            }
        }
    }
}
