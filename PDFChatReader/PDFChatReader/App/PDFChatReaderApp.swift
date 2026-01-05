//
//  PDFChatReaderApp.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import SwiftUI

@main
struct PDFChatReaderApp: App {

    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            PDFReaderView(
                viewModel: container.makePDFReaderViewModel(),
                makeChatView: { contextProvider in
                    container.makeChatView(contextProvider: contextProvider)
                }
            )
        }
    }
}
