//
//  PDFFileImporter.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

struct PDFFileImporter: PDFImporting {

    func importPDF(from url: URL) throws -> URL {
        try copyToSandboxReplacingIfNeeded(url)
    }
}

// MARK: - Private

private extension PDFFileImporter {

    func copyToSandboxReplacingIfNeeded(_ url: URL) throws -> URL {
        let fileManager = FileManager.default

        let documentsDirectory = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let pdfFolder = documentsDirectory.appendingPathComponent(
            "ImportedPDFs",
            isDirectory: true
        )

        if !fileManager.fileExists(atPath: pdfFolder.path) {
            try fileManager.createDirectory(
                at: pdfFolder,
                withIntermediateDirectories: true
            )
        }

        let fileName = url.lastPathComponent.isEmpty ? "document.pdf" : url.lastPathComponent
        let destinationURL = pdfFolder.appendingPathComponent(fileName)

        let needsAccess = url.startAccessingSecurityScopedResource()
        defer {
            if needsAccess { url.stopAccessingSecurityScopedResource() }
        }

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }

        try fileManager.copyItem(at: url, to: destinationURL)
        return destinationURL
    }
}
