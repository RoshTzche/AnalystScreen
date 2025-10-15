//
//  AnalystView.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import SwiftUI

struct AnalystView: View {
    @StateObject private var viewModel = AnalystViewModel()
    // State para el texto que el usuario está escribiendo
    @State private var userInput: String = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            chatList
            Divider()
            inputBar // Añadimos la barra de entrada aquí
        }
        .background(AppColors.background) // Usamos un color semántico centralizado
        .task {
            await viewModel.startAnalysisSession()
        }
        .navigationBarHidden(true)
        .tint(AppColors.accent) // Configura el tint global dentro de esta vista
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
    
    private var chatList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .padding(.horizontal)
                    }

                    if viewModel.isThinking {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Analista pensando…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }

                    Color.clear.frame(height: 12)
                }
                .padding(.top, 12)
            }
            .onChange(of: viewModel.messages) { _, _ in
                if let last = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
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
    
    // Función para manejar el envío de mensajes
    private func sendMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        userInput = ""
        Task {
            await viewModel.sendMessage(text: text)
        }
    }
}


struct ChatBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer(minLength: 40)
            } else if message.role == .user { // Condición para el usuario
                Spacer(minLength: 40)
                bubble
            }
        }
        .id(message.id)
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(message.text)
                .font(.body)
                .foregroundStyle(.primary)
            Text(formattedDate(message.timestamp))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(message.role == .user ? AppColors.bubbleUser : AppColors.bubbleAssistant)
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview("AnalystView") {
    AnalystView()
}
