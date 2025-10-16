import SwiftUI

// MARK: - Modelos de Datos del Partido

/// Describe a un solo jugador con sus datos básicos.
struct Player: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let number: Int
    let position: String // Ej: "POR", "DEF", "MED", "DEL"
}

/// Describe un equipo, su formación y su plantilla.
struct Team: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let formation: String // Ej: "4-3-3", "4-4-2"
    let players: [Player]
    let logoColor: Color // Color primario para la UI
}

/// Contiene el conjunto de estadísticas cuantificables de un equipo en un momento dado.
struct MatchStats: Hashable {
    var possession: Double = 0.5
    var shots: Int = 0
    var shotsOnTarget: Int = 0
    var passes: Int = 0
    var passAccuracy: Double = 0.0
    var fouls: Int = 0
    var yellowCards: Int = 0
    var redCards: Int = 0
}

/// La fuente de verdad que representa el estado completo y en vivo del partido.
struct LiveMatchData {
    var homeTeam: Team
    var awayTeam: Team
    var homeStats: MatchStats
    var awayStats: MatchStats
    var matchTime: Int // Minuto actual del partido
    
    /// Proporciona un estado inicial por defecto para las Previews y el arranque.
    static func placeholder() -> LiveMatchData {
        LiveMatchData(
            homeTeam: Team(
                name: "Real Cósmicos",
                formation: "4-3-3",
                players: [
                    Player(name: "Galileo", number: 1, position: "POR"),
                    Player(name: "Kepler", number: 4, position: "DEF"),
                    Player(name: "Newton", number: 5, position: "DEF"),
                    Player(name: "Copérnico", number: 8, position: "MED"),
                    Player(name: "Einstein", number: 10, position: "DEL")
                ],
                logoColor: .cyan
            ),
            awayTeam: Team(
                name: "Atlético Nebulosa",
                formation: "4-4-2",
                players: [
                    Player(name: "Hubble", number: 1, position: "POR"),
                    Player(name: "Ptolomeo", number: 3, position: "DEF"),
                    Player(name: "Sagan", number: 6, position: "MED"),
                    Player(name: "Tyson", number: 9, position: "DEL"),
                    Player(name: "Hawking", number: 11, position: "DEL")
                ],
                logoColor: .purple
            ),
            homeStats: MatchStats(),
            awayStats: MatchStats(),
            matchTime: 0
        )
    }
}
