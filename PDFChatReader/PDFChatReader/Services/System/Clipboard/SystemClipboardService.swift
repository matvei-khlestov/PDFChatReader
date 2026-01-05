//
//  SystemClipboardService.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import UIKit

struct SystemClipboardService: ClipboardServicing {
    func copy(_ string: String) {
        UIPasteboard.general.string = string
    }
}
