// En: AnalystView.swift

import SwiftUI

// MARK: - VISTA PRINCIPAL
struct AnalystView: View {
    @StateObject private var viewModel = AnalystViewModel()
    @State private var selectedCardIndex = 0
    @State private var userInput: String = ""
    @State private var isShowingStats = false

    var body: some View {
        ZStack {
            AuroraBackground()
            VStack(spacing: 0) {
                header
                cardCarousel
                pageControl
            }
            .safeAreaInset(edge: .bottom, content: floatingInputArea)
            
            if isShowingStats {
                StatsModalView(viewModel: viewModel, isPresented: $isShowingStats)
            }
        }
        .task {
            if viewModel.cards.isEmpty { await viewModel.startAnalysisSession() }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.cards.count) {
            withAnimation { selectedCardIndex = viewModel.cards.count - 1 }
        }
    }
    
    // --- SUBVISTAS ---
    private var header: some View {
        HStack(spacing: 16) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.title2.weight(.bold)).foregroundStyle(.white).padding(10)
                .background(Color.white.opacity(0.1)).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Ojo de Halcón").font(.headline).bold().foregroundStyle(.white)
                Text("Analista en Tiempo Real").font(.footnote).foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isShowingStats = true
                }
            }) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title2).foregroundStyle(.white).padding(10).contentShape(Rectangle())
            }
        }.padding()
    }

    private var cardCarousel: some View {
        TabView(selection: $selectedCardIndex) {
            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                FlippableCardView(card: card).tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var pageControl: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.cards.count, id: \.self) { index in
                Circle()
                    .fill(index == selectedCardIndex ? .white : .white.opacity(0.4))
                    .frame(width: 8, height: 8).scaleEffect(index == selectedCardIndex ? 1.2 : 1.0)
            }
        }
        .padding(.bottom, 120)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCardIndex)
    }
    
    private func floatingInputArea() -> some View {
        VStack(spacing: 12) {
            Button(action: { Task { await viewModel.getLiveUpdate() } }) {
                Label("Obtener Análisis", systemImage: "sparkles").font(.footnote.weight(.bold)).foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.white.opacity(0.15), in: Capsule())
            }
            .disabled(viewModel.isThinking).opacity(viewModel.isThinking ? 0.5 : 1.0)
            HStack(spacing: 12) {
                TextField("", text: $userInput, prompt: Text("Pregúntale a Ojo de Halcón...").foregroundStyle(.white.opacity(0.6)), axis: .vertical)
                    .textFieldStyle(.plain).lineLimit(1...5).foregroundStyle(.white)
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill").font(.title)
                        .foregroundStyle(userInput.isEmpty ? .gray.opacity(0.5) : Color.cyan)
                }
                .disabled(userInput.isEmpty || viewModel.isThinking)
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
            .background(.black.opacity(0.2), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
        .padding(.horizontal).padding(.top)
    }
    
    private func sendMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let tempText = userInput
        userInput = ""
        Task { await viewModel.sendMessage(text: tempText) }
    }
}

// MARK: - TARJETA Y COMPONENTES
struct FlippableCardView: View {
    let card: AnalysisCard
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            CardSideView(title: card.title ?? "Análisis", text: card.frontText)
                .opacity(isFlipped ? 0 : 1)
            CardSideView(title: "Detalles Adicionales", text: card.backText)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)).opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isFlipped.toggle() } }
        .padding(.horizontal, 24)
    }
}

struct CardSideView: View {
    let title: String, text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title).font(.footnote).bold().textCase(.uppercase).foregroundStyle(.white.opacity(0.8))
                Spacer()
                Image(systemName: "arrow.2.circlepath").font(.body.weight(.bold)).foregroundStyle(.white.opacity(0.8))
            }
            Text(text).font(.title2).fontWeight(.bold).foregroundStyle(.white).lineSpacing(6)
            Spacer()
        }
        .padding(24).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(LinearGradient(colors: [.cyan, .purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
        .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - VISTA MODAL Y ESTADÍSTICAS
struct StatsModalView: View {
    @ObservedObject var viewModel: AnalystViewModel
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea().onTapGesture { close() }
            VStack(spacing: 0) {
                HStack {
                    Text("Estadísticas en Vivo").font(.title3).bold().foregroundStyle(.white)
                    Spacer()
                    Button(action: close) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title).foregroundStyle(.gray.opacity(0.8), .white.opacity(0.1))
                    }
                }
                .padding([.horizontal, .top]).padding(.bottom, 8)
                StatsView(matchData: viewModel.liveMatchData) { statName in
                    Task { await viewModel.explainStat(statName) }
                    close()
                }
                Spacer(minLength: 0)
            }
            .frame(maxHeight: 450)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            .padding(32)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private func close() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

struct StatButton: View {
    let title: String, value: String, action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title).font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.7))
                Text(value).font(.title3).fontWeight(.bold).foregroundStyle(.white).minimumScaleFactor(0.8)
            }
            .padding(.vertical, 12).frame(maxWidth: .infinity)
            .background(.white.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct StatsView: View {
    let matchData: LiveMatchData
    let onStatTapped: (String) -> Void
    var body: some View {
        VStack {
            HStack {
                Text(matchData.homeTeam.name).bold().foregroundStyle(matchData.homeTeam.logoColor)
                Spacer(); Text("vs").foregroundStyle(.white.opacity(0.7)); Spacer()
                Text(matchData.awayTeam.name).bold().foregroundStyle(matchData.awayTeam.logoColor)
            }.padding([.horizontal, .bottom], 4)
            Text("Minuto: \(matchData.matchTime)").font(.subheadline.weight(.semibold)).padding(.bottom, 8)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatButton(title: "Posesión", value: "\(Int(matchData.homeStats.possession*100))%/\(Int(matchData.awayStats.possession*100))%") { onStatTapped("la Posesión") }
                StatButton(title: "Tiros", value: "\(matchData.homeStats.shots)/\(matchData.awayStats.shots)") { onStatTapped("los Tiros a Puerta") }
                StatButton(title: "Pases", value: "\(matchData.homeStats.passes)/\(matchData.awayStats.passes)") { onStatTapped("la cantidad de Pases") }
                StatButton(title: "Faltas", value: "\(matchData.homeStats.fouls)/\(matchData.awayStats.fouls)") { onStatTapped("las Faltas cometidas") }
            }
        }.padding(.horizontal)
    }
}

struct AuroraBackground: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Circle().fill(Color.cyan.gradient).frame(width: 300, height: 300).blur(radius: 120).offset(x: animate ? 100 : -100, y: animate ? -50: -150)
            Circle().fill(Color.purple.gradient).frame(width: 300, height: 300).blur(radius: 150).offset(x: animate ? -100 : 100, y: animate ? 150 : 50)
        }.onAppear { withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) { animate.toggle() } }
    }
}

// MARK: - PREVIEW
#Preview {
    AnalystView()
}
