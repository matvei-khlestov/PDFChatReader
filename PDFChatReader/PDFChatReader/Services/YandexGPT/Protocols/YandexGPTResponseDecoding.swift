//
//  YandexGPTResponseDecoding.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

protocol YandexGPTResponseDecoding {
    func decodeCompletionText(from data: Data) throws -> String
}
