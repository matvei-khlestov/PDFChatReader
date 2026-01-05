//
//  AssistantMessageMenu.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import SwiftUI

struct AssistantMessageMenu: View {
    
    let isLoading: Bool
    let message: ChatMessage
    let onAction: (ChatViewModel.AssistantAction, ChatMessage) -> Void
    
    var body: some View {
        Button {
            onAction(.copy, message)
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
        
        ShareLink(item: message.text) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        
        Button {
            onAction(.regenerate, message)
        } label: {
            Label("Regenerate", systemImage: "arrow.clockwise")
        }
        .disabled(isLoading || message.request == nil)
        
        Button {
            onAction(.explainSimpler, message)
        } label: {
            Label("Explain simpler", systemImage: "wand.and.stars")
        }
        .disabled(isLoading || message.request == nil)
    }
}
