//
//  ChatView.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import SwiftUI

struct ChatView: View {

    let contextProvider: () -> String

    @StateObject private var viewModel: ChatViewModel

    private static let modelUri = "gpt://<FOLDER_ID>/yandexgpt/latest" // TODO: replace with your Yandex Cloud folder ID
    private static let apiKey = "<YANDEX_API_KEY>" // TODO: move to secure storage (Keychain / xcconfig)

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var layout: Layout {
        horizontalSizeClass == .regular ? .pad : .phone
    }

    private var metrics: Metrics {
        Metrics(layout: layout)
    }

    init(contextProvider: @escaping () -> String) {
        self.contextProvider = contextProvider

        let service = YandexGPTService(apiKey: Self.apiKey)
        _viewModel = StateObject(
            wrappedValue: ChatViewModel(
                gpt: service,
                modelUri: Self.modelUri,
                contextProvider: contextProvider
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messagesList

                Divider()

                quickActionsBar

                inputBar
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: Binding(get: {
                viewModel.errorText != nil
            }, set: {
                _ in viewModel.errorText = nil
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorText ?? "")
            }
        }
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: metrics.messagesSpacing) {
                    ForEach(viewModel.messages) { msg in
                        messageBubble(msg)
                            .id(msg.id)
                    }

                    if viewModel.isLoading {
                        HStack(spacing: metrics.thinkingSpacing) {
                            ProgressView()
                            Text("Thinking…")
                                .font(metrics.thinkingFont)
                        }
                        .padding(.top, metrics.thinkingTopPadding)
                    }
                }
                .padding(metrics.messagesPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: viewModel.messages) { _, _ in
                guard let last = viewModel.messages.last else { return }
                withAnimation {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    private func messageBubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.role == .assistant {
                bubble(text: msg.text, isUser: false)
                Spacer(minLength: metrics.bubbleSideSpacerMin)
            } else {
                Spacer(minLength: metrics.bubbleSideSpacerMin)
                bubble(text: msg.text, isUser: true)
            }
        }
    }

    private func bubble(text: String, isUser: Bool) -> some View {
        Text(text)
            .font(metrics.bubbleFont)
            .lineSpacing(metrics.bubbleLineSpacing)
            .padding(.vertical, metrics.bubbleVerticalPadding)
            .padding(.horizontal, metrics.bubbleHorizontalPadding)
            .background(isUser ? Color.blue.opacity(0.18) : Color.gray.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: metrics.bubbleCornerRadius, style: .continuous))
            .frame(maxWidth: metrics.bubbleMaxWidth, alignment: isUser ? .trailing : .leading)
    }

    private var quickActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: metrics.quickActionsSpacing) {
                ForEach(QuickAction.allCases) { action in
                    Button(action.rawValue) {
                        viewModel.runQuickAction(action)
                    }
                    .font(metrics.quickActionFont)
                    .buttonStyle(.bordered)
                    .controlSize(metrics.quickActionControlSize)
                    .disabled(viewModel.isLoading)
                }
            }
            .padding(.horizontal, metrics.quickActionsHorizontalPadding)
            .padding(.vertical, metrics.quickActionsVerticalPadding)
        }
    }

    private var inputBar: some View {
        HStack(spacing: metrics.inputSpacing) {
            TextField("Ask about this page…", text: $viewModel.inputText, axis: .vertical)
                .font(metrics.inputFont)
                .textFieldStyle(.roundedBorder)
                .lineLimit(metrics.inputLineLimit)
                .disabled(viewModel.isLoading)

            Button("Send") {
                viewModel.sendUserQuestion()
            }
            .font(metrics.sendButtonFont)
            .buttonStyle(.borderedProminent)
            .controlSize(metrics.sendButtonControlSize)
            .disabled(viewModel.isLoading || viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(metrics.inputBarPadding)
    }
}

private extension ChatView {
    enum Layout {
        case phone
        case pad
    }

    struct Metrics {
        let layout: Layout

        // MARK: - Messages list

        var messagesPadding: CGFloat {
            switch layout {
            case .phone: return 16
            case .pad: return 22
            }
        }

        var messagesSpacing: CGFloat {
            switch layout {
            case .phone: return 10
            case .pad: return 14
            }
        }

        // MARK: - Bubble

        var bubbleFont: Font {
            switch layout {
            case .phone: return .system(size: 16, weight: .regular)
            case .pad: return .system(size: 19, weight: .regular)
            }
        }

        var bubbleLineSpacing: CGFloat {
            switch layout {
            case .phone: return 2
            case .pad: return 3
            }
        }

        var bubbleVerticalPadding: CGFloat {
            switch layout {
            case .phone: return 10
            case .pad: return 14
            }
        }

        var bubbleHorizontalPadding: CGFloat {
            switch layout {
            case .phone: return 12
            case .pad: return 16
            }
        }

        var bubbleCornerRadius: CGFloat {
            switch layout {
            case .phone: return 14
            case .pad: return 18
            }
        }

        var bubbleSideSpacerMin: CGFloat {
            switch layout {
            case .phone: return 40
            case .pad: return 120
            }
        }

        var bubbleMaxWidth: CGFloat? {
            switch layout {
            case .phone: return 340
            case .pad: return 620
            }
        }

        // MARK: - Thinking

        var thinkingFont: Font {
            switch layout {
            case .phone: return .footnote
            case .pad: return .system(size: 16, weight: .regular)
            }
        }

        var thinkingSpacing: CGFloat {
            8
        }

        var thinkingTopPadding: CGFloat {
            switch layout {
            case .phone: return 6
            case .pad: return 10
            }
        }

        // MARK: - Quick actions

        var quickActionFont: Font {
            switch layout {
            case .phone: return .system(size: 15, weight: .semibold)
            case .pad: return .system(size: 18, weight: .semibold)
            }
        }

        var quickActionControlSize: ControlSize {
            switch layout {
            case .phone: return .regular
            case .pad: return .large
            }
        }

        var quickActionsSpacing: CGFloat {
            switch layout {
            case .phone: return 10
            case .pad: return 12
            }
        }

        var quickActionsHorizontalPadding: CGFloat {
            switch layout {
            case .phone: return 16
            case .pad: return 22
            }
        }

        var quickActionsVerticalPadding: CGFloat {
            switch layout {
            case .phone: return 10
            case .pad: return 14
            }
        }

        // MARK: - Input bar

        var inputBarPadding: CGFloat {
            switch layout {
            case .phone: return 16
            case .pad: return 22
            }
        }

        var inputSpacing: CGFloat {
            switch layout {
            case .phone: return 10
            case .pad: return 12
            }
        }

        var inputFont: Font {
            switch layout {
            case .phone: return .system(size: 16, weight: .regular)
            case .pad: return .system(size: 19, weight: .regular)
            }
        }

        var inputLineLimit: ClosedRange<Int> {
            switch layout {
            case .phone: return 1...3
            case .pad: return 1...4
            }
        }

        var sendButtonFont: Font {
            switch layout {
            case .phone: return .system(size: 16, weight: .semibold)
            case .pad: return .system(size: 19, weight: .semibold)
            }
        }

        var sendButtonControlSize: ControlSize {
            switch layout {
            case .phone: return .regular
            case .pad: return .extraLarge
            }
        }
    }
}
