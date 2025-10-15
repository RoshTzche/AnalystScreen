//
//  AnalystView.swift
//  PantallaANalista
//
//  Created by Rosh on 15/10/25.
//

import SwiftUI

struct AnalystView: View {
    @StateObject private var viewModel = AnalystViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            chatList
        }
        .background(.background)
        .task {
            await viewModel.sendGreeting()
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "chart.xyaxis.line")
                    .foregroundStyle(.accent)
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
}

struct ChatBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer(minLength: 40)
            } else {
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
                .fill(.ultraThinMaterial)
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
