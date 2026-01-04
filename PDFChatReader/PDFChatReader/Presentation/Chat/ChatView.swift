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
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var layout: Layout {
        horizontalSizeClass == .regular ? .pad : .phone
    }
    
    private var metrics: Metrics {
        Metrics(layout: layout)
    }
    
    init(
        gpt: YandexGPTServicing,
        modelUri: String,
        contextProvider: @escaping () -> String
    ) {
        self.contextProvider = contextProvider
        _viewModel = StateObject(
            wrappedValue: ChatViewModel(
                gpt: gpt,
                modelUri: modelUri,
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
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorText != nil },
                    set: { _ in viewModel.errorText = nil }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorText ?? "")
            }
        }
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(
                    alignment: .leading,
                    spacing: metrics.messagesSpacing
                ) {
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
            .background(
                isUser
                ? Color.blue.opacity(0.18)
                : Color.gray.opacity(0.18)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: metrics.bubbleCornerRadius,
                    style: .continuous
                )
            )
            .frame(
                maxWidth: metrics.bubbleMaxWidth,
                alignment: isUser ? .trailing : .leading
            )
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
            TextField(
                "Ask about this page…",
                text: $viewModel.inputText,
                axis: .vertical
            )
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
            .disabled(
                viewModel.isLoading ||
                viewModel.inputText
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            )
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
            layout == .pad ? 22 : 16
        }
        
        var messagesSpacing: CGFloat {
            layout == .pad ? 14 : 10
        }
        
        // MARK: - Bubble
        
        var bubbleFont: Font {
            layout == .pad
            ? .system(size: 19, weight: .regular)
            : .system(size: 16, weight: .regular)
        }
        
        var bubbleLineSpacing: CGFloat {
            layout == .pad ? 3 : 2
        }
        
        var bubbleVerticalPadding: CGFloat {
            layout == .pad ? 14 : 10
        }
        
        var bubbleHorizontalPadding: CGFloat {
            layout == .pad ? 16 : 12
        }
        
        var bubbleCornerRadius: CGFloat {
            layout == .pad ? 18 : 14
        }
        
        var bubbleSideSpacerMin: CGFloat {
            layout == .pad ? 120 : 40
        }
        
        var bubbleMaxWidth: CGFloat? {
            layout == .pad ? 620 : 340
        }
        
        // MARK: - Thinking
        
        var thinkingFont: Font {
            layout == .pad
            ? .system(size: 16, weight: .regular)
            : .footnote
        }
        
        var thinkingSpacing: CGFloat { 8 }
        
        var thinkingTopPadding: CGFloat {
            layout == .pad ? 10 : 6
        }
        
        // MARK: - Quick actions
        
        var quickActionFont: Font {
            layout == .pad
            ? .system(size: 18, weight: .semibold)
            : .system(size: 15, weight: .semibold)
        }
        
        var quickActionControlSize: ControlSize {
            layout == .pad ? .large : .regular
        }
        
        var quickActionsSpacing: CGFloat {
            layout == .pad ? 12 : 10
        }
        
        var quickActionsHorizontalPadding: CGFloat {
            layout == .pad ? 22 : 16
        }
        
        var quickActionsVerticalPadding: CGFloat {
            layout == .pad ? 14 : 10
        }
        
        // MARK: - Input bar
        
        var inputBarPadding: CGFloat {
            layout == .pad ? 22 : 16
        }
        
        var inputSpacing: CGFloat {
            layout == .pad ? 12 : 10
        }
        
        var inputFont: Font {
            layout == .pad
            ? .system(size: 19, weight: .regular)
            : .system(size: 16, weight: .regular)
        }
        
        var inputLineLimit: ClosedRange<Int> {
            layout == .pad ? 1...4 : 1...3
        }
        
        var sendButtonFont: Font {
            layout == .pad
            ? .system(size: 19, weight: .semibold)
            : .system(size: 16, weight: .semibold)
        }
        
        var sendButtonControlSize: ControlSize {
            layout == .pad ? .extraLarge : .regular
        }
    }
}
