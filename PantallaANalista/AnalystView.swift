import SwiftUI

// MARK: - VISTA PRINCIPAL (TU LÓGICA ORIGINAL CON NUEVA APARIENCIA)
struct AnalystView: View {
    @StateObject private var viewModel = AnalystViewModel()
    @State private var selectedCardIndex = 0
    @State private var userInput: String = "" // Movido aquí para que sea accesible

    var body: some View {
        ZStack {
            // --- CAMBIO VISUAL 1: Fondo dinámico ---
            AuroraBackground()

            VStack(spacing: 0) {
                header
                cardCarousel // Sin cambios en la lógica
                pageControl
            }
        }
        .safeAreaInset(edge: .bottom, content: floatingInputArea)
        .task {
            await viewModel.startAnalysisSession()
        }
        .navigationBarHidden(true)
    }

    // --- SUBVISTAS (LÓGICA ORIGINAL, APARIENCIA RETOCADA) ---

    private var header: some View {
        HStack(spacing: 16) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .padding(10)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Ojo de Halcón")
                    .font(.headline).bold()
                    .foregroundStyle(.white)
                Text("Analista en Tiempo Real")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding()
    }
    
    // --- TU CAROUSEL ORIGINAL (SIN CAMBIOS DE LÓGICA) ---
    private var cardCarousel: some View {
        TabView(selection: $selectedCardIndex) {
            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                // La tarjeta Flippable usará la nueva CardSideView automáticamente
                FlippableCardView(card: card)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var pageControl: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.cards.count, id: \.self) { index in
                Circle()
                    .fill(index == selectedCardIndex ? .white : .white.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == selectedCardIndex ? 1.2 : 1.0)
            }
        }
        .padding(.bottom, 120) // Espacio para el input flotante
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCardIndex)
    }
    
    private func floatingInputArea() -> some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.getLiveUpdate()
                    withAnimation { selectedCardIndex = viewModel.cards.count - 1 }
                }
            }) {
                Label("Obtener Análisis", systemImage: "sparkles")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15), in: Capsule())
            }
            .disabled(viewModel.isThinking)
            .opacity(viewModel.isThinking ? 0.5 : 1.0)

            HStack(spacing: 12) {
                TextField("", text: $userInput, prompt: Text("Pregúntale a Ojo de Halcón...").foregroundStyle(.white.opacity(0.6)), axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .foregroundStyle(.white)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(userInput.isEmpty ? .gray.opacity(0.5) : Color.cyan)
                }
                .disabled(userInput.isEmpty || viewModel.isThinking)
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
            .background(.black.opacity(0.2), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private func sendMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        userInput = ""
        Task {
            await viewModel.sendMessage(text: text)
            withAnimation { selectedCardIndex = viewModel.cards.count - 1 }
        }
    }
}


// MARK: - TARJETAS (LÓGICA ORIGINAL, APARIENCIA MODIFICADA)

struct FlippableCardView: View {
    let card: AnalysisCard
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            // Utiliza la nueva CardSideView
            CardSideView(title: card.title ?? "Análisis", text: card.frontText)
                .opacity(isFlipped ? 0 : 1)
            
            // Utiliza la nueva CardSideView
            CardSideView(title: "Detalles Adicionales", text: card.backText)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
        .padding(.horizontal, 24)
    }
}

struct CardSideView: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.footnote).bold().textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Image(systemName: "arrow.2.circlepath")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.body.weight(.bold))
            }
            
            Text(text)
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(.white)
                .lineSpacing(6)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            Color.black.opacity(0.2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.cyan, .purple, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct AuroraBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Circle()
                .fill(Color.cyan.gradient)
                .frame(width: 300, height: 300)
                .blur(radius: 120)
                .offset(x: animate ? 100 : -100, y: animate ? -50: -150)
            
            Circle()
                .fill(Color.purple.gradient)
                .frame(width: 300, height: 300)
                .blur(radius: 150)
                .offset(x: animate ? -100 : 100, y: animate ? 150 : 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}


// MARK: - PREVIEW
#Preview {
    AnalystView()
}
