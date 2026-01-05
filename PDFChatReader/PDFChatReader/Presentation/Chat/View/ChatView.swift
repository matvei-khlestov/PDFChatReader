//
//  ChatView.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import SwiftUI

struct ChatView: View {
    
    // MARK: - State
    
    @StateObject private var viewModel: ChatViewModel
    
    // MARK: - Init
    
    init(
        viewModel: ChatViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messagesList
                
                Divider()
                
                scopePicker
                
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
    
    // MARK: - Messages List
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(
                    alignment: .leading,
                    spacing: Metrics.messagesSpacing
                ) {
                    ForEach(viewModel.messages) { msg in
                        messageBubble(msg)
                            .id(msg.id)
                    }
                    
                    if viewModel.isLoading {
                        HStack(spacing: Metrics.thinkingSpacing) {
                            ProgressView()
                            Text("Thinking…")
                                .font(Metrics.thinkingFont)
                        }
                        .padding(.top, Metrics.thinkingTopPadding)
                    }
                }
                .padding(Metrics.messagesPadding)
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
    
    // MARK: - Message Bubble
    
    private func messageBubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.role == .assistant {
                bubble(text: msg.text, isUser: false, message: msg)
                Spacer(minLength: Metrics.bubbleSideSpacerMin)
            } else {
                Spacer(minLength: Metrics.bubbleSideSpacerMin)
                bubble(text: msg.text, isUser: true, message: msg)
            }
        }
    }
    
    // MARK: - Bubble Content
    
    @ViewBuilder
    private func bubble(
        text: String,
        isUser: Bool,
        message: ChatMessage
    ) -> some View {
        let base = bubbleBase(text: text, isUser: isUser)
        
        if message.role == .assistant {
            base.contextMenu {
                AssistantMessageMenu(
                    isLoading: viewModel.isLoading,
                    message: message,
                    onAction: { action, message in
                        viewModel.handleAssistantAction(action, message: message)
                    }
                )
            }
        } else {
            base
        }
    }
    
    private func bubbleBase(
        text: String,
        isUser: Bool
    ) -> some View {
        Text(text)
            .font(Metrics.bubbleFont)
            .lineSpacing(Metrics.bubbleLineSpacing)
            .padding(.vertical, Metrics.bubbleVerticalPadding)
            .padding(.horizontal, Metrics.bubbleHorizontalPadding)
            .background(
                isUser
                ? Color.blue.opacity(0.18)
                : Color.gray.opacity(0.18)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Metrics.bubbleCornerRadius,
                    style: .continuous
                )
            )
            .frame(
                maxWidth: Metrics.bubbleMaxWidth,
                alignment: isUser ? .trailing : .leading
            )
    }
    
    // MARK: - Scope Picker
    
    private var scopePicker: some View {
        Picker("", selection: $viewModel.scope) {
            ForEach(ChatScope.allCases) { scope in
                Text(scope.rawValue).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .disabled(viewModel.isLoading)
        .onChange(of: viewModel.scope) { _, newValue in
            viewModel.updateScope(newValue)
        }
        .padding(.horizontal, Metrics.scopeHorizontalPadding)
        .padding(.vertical, Metrics.scopeVerticalPadding)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Metrics.quickActionsSpacing) {
                ForEach(QuickAction.allCases) { action in
                    Button(action.rawValue) {
                        viewModel.runQuickAction(action)
                    }
                    .font(Metrics.quickActionFont)
                    .buttonStyle(.bordered)
                    .controlSize(Metrics.quickActionControlSize)
                    .disabled(viewModel.isLoading)
                }
            }
            .padding(.horizontal, Metrics.quickActionsHorizontalPadding)
            .padding(.vertical, Metrics.quickActionsVerticalPadding)
        }
    }
    
    // MARK: - Input
    
    private var inputBar: some View {
        HStack(spacing: Metrics.inputSpacing) {
            TextField(
                viewModel.scope == .page
                ? "Ask about this page…"
                : "Ask about this document…",
                text: $viewModel.inputText,
                axis: .vertical
            )
            .font(Metrics.inputFont)
            .textFieldStyle(.roundedBorder)
            .lineLimit(Metrics.inputLineLimit)
            .disabled(viewModel.isLoading)
            
            Button("Send") {
                viewModel.sendUserQuestion()
            }
            .font(Metrics.sendButtonFont)
            .buttonStyle(.borderedProminent)
            .controlSize(Metrics.sendButtonControlSize)
            .disabled(
                viewModel.isLoading ||
                viewModel.inputText
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            )
        }
        .padding(Metrics.inputBarPadding)
    }
}

// MARK: - Metrics

private enum Metrics {
    
    // MARK: - Messages list
    
    static let messagesPadding: CGFloat = 16
    static let messagesSpacing: CGFloat = 10
    
    // MARK: - Bubble
    
    static let bubbleFont: Font = .system(size: 16, weight: .regular)
    static let bubbleLineSpacing: CGFloat = 2
    static let bubbleVerticalPadding: CGFloat = 10
    static let bubbleHorizontalPadding: CGFloat = 12
    static let bubbleCornerRadius: CGFloat = 14
    static let bubbleSideSpacerMin: CGFloat = 40
    static let bubbleMaxWidth: CGFloat? = 340
    
    // MARK: - Thinking
    
    static let thinkingFont: Font = .footnote
    static let thinkingSpacing: CGFloat = 8
    static let thinkingTopPadding: CGFloat = 6
    
    // MARK: - Scope picker
    
    static let scopeHorizontalPadding: CGFloat = 16
    static let scopeVerticalPadding: CGFloat = 10
    
    // MARK: - Quick actions
    
    static let quickActionFont: Font = .system(size: 15, weight: .semibold)
    static let quickActionControlSize: ControlSize = .regular
    static let quickActionsSpacing: CGFloat = 10
    static let quickActionsHorizontalPadding: CGFloat = 16
    static let quickActionsVerticalPadding: CGFloat = 10
    
    // MARK: - Input bar
    
    static let inputBarPadding: CGFloat = 16
    static let inputSpacing: CGFloat = 10
    static let inputFont: Font = .system(size: 16, weight: .regular)
    static let inputLineLimit: ClosedRange<Int> = 1...3
    static let sendButtonFont: Font = .system(size: 16, weight: .semibold)
    static let sendButtonControlSize: ControlSize = .regular
}
