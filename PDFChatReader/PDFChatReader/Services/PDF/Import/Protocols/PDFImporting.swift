//
//  PDFImporting.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

protocol PDFImporting {
    func importPDF(from url: URL) throws -> URL
}
