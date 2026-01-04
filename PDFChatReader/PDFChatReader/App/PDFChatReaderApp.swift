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
            PDFReaderView(container: container)
                .environmentObject(container)
        }
    }
}
