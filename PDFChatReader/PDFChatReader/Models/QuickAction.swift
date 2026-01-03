//
//  QuickAction.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation

enum QuickAction: String, CaseIterable, Identifiable {
    case summarize = "Summarize"
    case explain = "Explain"
    case keyPoints = "Key points"

    var id: String { rawValue }
}
