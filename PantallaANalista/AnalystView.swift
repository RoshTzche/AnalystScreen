//
//  AnalystView.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import SwiftUI

struct AnalystView: View {
    @StateObject private var viewModel = AnalystViewModel()
    @State private var userInput: String = ""
    
    // State para saber qué tarjeta está mostrando el carrusel
    @State private var currentCardIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            
            // Reemplazamos el antiguo chatList por nuestro nuevo carrusel de tarjetas
            cardCarousel
            
            Divider()
            inputBar
        }
        .background(AppColors.background)
        .task {
            await viewModel.startAnalysisSession()
        }
        .navigationBarHidden(true)
        .tint(AppColors.accent)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "chart.xyaxis.line")
                    .foregroundStyle(AppColors.accent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Analista")
                    .font(.headline)
                Text("Asistente automático")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Card Carousel
    private var cardCarousel: some View {
        GeometryReader { _ in
            ZStack {
                // El TabView con estilo .page nos da el efecto de carrusel deslizable
                TabView(selection: $currentCardIndex) {
                    ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                        FlippableCardView(card: card)
                            .tag(index)
                            .padding(.horizontal, 20)
                            .padding(.vertical)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.cards)
                
                // Indicadores de navegación y paginación
                if !viewModel.cards.isEmpty {
                    VStack {
                        Spacer()
                        
                        // Paginador
                        HStack(spacing: 8) {
                            ForEach(0..<viewModel.cards.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentCardIndex ? AppColors.accent : Color.secondary.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        // Indicador de "Siguiente Tarjeta"
                        if currentCardIndex < viewModel.cards.count - 1 {
                            Button(action: {
                                withAnimation {
                                    currentCardIndex += 1
                                }
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(AppColors.accent.opacity(0.8))
                                    .background(.ultraThinMaterial, in: Circle())
                                    .shadow(radius: 5)
                            }
                            .padding(.top, 10)
                        } else {
                            // Espacio reservado para mantener el paginador alineado
                            Color.clear.frame(height: 44)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Pregúntale al analista...", text: $userInput, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundColor(userInput.isEmpty ? .secondary : AppColors.accent)
            }
            .disabled(userInput.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
    
    private func sendMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        Task {
            // Guardamos el índice actual antes de enviar
            let previousCardCount = viewModel.cards.count
            await viewModel.sendMessage(text: text)
            // Cuando la nueva tarjeta se añade, nos desplazamos a ella
            if viewModel.cards.count > previousCardCount {
                withAnimation {
                    currentCardIndex = viewModel.cards.count - 1
                }
            }
        }
        userInput = ""
    }
}


// MARK: - Flippable Card View
struct FlippableCardView: View {
    let card: AnalysisCard
    @State private var isFlipped = false
    @State private var stats: MatchStats?

    var body: some View {
        ZStack {
            // Back: estadísticas del partido cuando se voltea
            StatsPanel(stats: stats ?? MatchStats.placeholder)
                .opacity(isFlipped ? 1.0 : 0.0)
                // Contra-rotación para evitar espejo en el reverso
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

            // Front: contenido normal de la tarjeta
            CardFace(text: card.frontText, title: card.title, backgroundColor: AppColors.background)
                .opacity(isFlipped ? 0.0 : 1.0)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isFlipped.toggle()
                if isFlipped && stats == nil {
                    stats = MatchStats.generateMock()
                }
            }
        }
        // Rotación del contenedor: controla el flip
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
    }
}


// MARK: - Card Face
// Una vista genérica para la cara de una tarjeta
struct CardFace: View {
    let text: String
    let title: String?
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title, !title.isEmpty {
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.separator, lineWidth: 1)
        )
    }
}


// MARK: - Stats Model + Panel
private struct MatchStats: Hashable {
    let minute: Int
    let pointsToQualify: Int
    let timeRemaining: String
    let extraTimePossible: Bool
    let missedChances: Int
    let shotsOnTarget: Int
    let possessionHome: Int
    let possessionAway: Int
    let expectedGoals: Double
    
    static let placeholder = MatchStats(
        minute: 0,
        pointsToQualify: 0,
        timeRemaining: "--:--",
        extraTimePossible: false,
        missedChances: 0,
        shotsOnTarget: 0,
        possessionHome: 50,
        possessionAway: 50,
        expectedGoals: 0.0
    )
    
    static func generateMock() -> MatchStats {
        let minute = Int.random(in: 5...120)
        let remaining = max(0, 90 - minute)
        let extra = minute >= 85 && Bool.random()
        let missed = Int.random(in: 0...6)
        let onTarget = Int.random(in: 0...10)
        let homePoss = Int.random(in: 35...65)
        let awayPoss = 100 - homePoss
        let xg = Double.random(in: 0.2...3.2)
        
        // Puntos para clasificar (ejemplo ficticio)
        let pointsNeed = Int.random(in: 1...3)
        
        return MatchStats(
            minute: minute,
            pointsToQualify: pointsNeed,
            timeRemaining: String(format: "%02d:%02d", remaining / 1, Int.random(in: 0...59)),
            extraTimePossible: extra,
            missedChances: missed,
            shotsOnTarget: onTarget,
            possessionHome: homePoss,
            possessionAway: awayPoss,
            expectedGoals: (xg * 10).rounded() / 10.0
        )
    }
}

private struct StatsPanel: View {
    let stats: MatchStats
    
    var body: some View {
        VStack(spacing: 16) {
            header
            Divider().opacity(0.4)
            grid
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.secondaryBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.separator, lineWidth: 1)
        )
    }
    
    private var header: some View {
        HStack {
            Label("Estadísticas del partido", systemImage: "sportscourt")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Badge(text: "Min \(stats.minute)")
        }
    }
    
    private var grid: some View {
        VStack(spacing: 14) {
            statRow(
                icon: "flag.checkered",
                title: "Puntos para clasificar",
                value: "\(stats.pointsToQualify)"
            )
            statRow(
                icon: "timer",
                title: "Tiempo restante",
                value: stats.timeRemaining
            )
            statRow(
                icon: stats.extraTimePossible ? "clock.badge.exclamationmark" : "clock",
                title: "Posible tiempo extra",
                value: stats.extraTimePossible ? "Sí" : "No"
            )
            statRow(
                icon: "soccerball",
                title: "Oportunidades desaprovechadas",
                value: "\(stats.missedChances)"
            )
            statRow(
                icon: "scope",
                title: "Tiros a puerta",
                value: "\(stats.shotsOnTarget)"
            )
            possessionRow(home: stats.possessionHome, away: stats.possessionAway)
            statRow(
                icon: "chart.bar",
                title: "xG (esperados)",
                value: String(format: "%.1f", stats.expectedGoals)
            )
        }
    }
    
    private func statRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accent)
                .frame(width: 20)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
    
    private func possessionRow(home: Int, away: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "circle.grid.cross")
                    .foregroundStyle(AppColors.accent)
                    .frame(width: 20)
                Text("Posesión")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(home)% - \(away)%")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.2)).frame(height: 8)
                GeometryReader { geo in
                    Capsule()
                        .fill(AppColors.accent)
                        .frame(width: geo.size.width * CGFloat(home) / 100.0, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

private struct Badge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
    }
}


#Preview("AnalystView") {
    AnalystView()
}
