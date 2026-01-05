//
//  YandexGPTCompletionResponseDecoder.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

struct YandexGPTCompletionResponseDecoder: YandexGPTResponseDecoding {
    
    // MARK: - Dependencies
    
    private let decoder: JSONDecoder
    
    // MARK: - Init
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    // MARK: - Public
    
    func decodeCompletionText(from data: Data) throws -> String {
        let decoded: YandexGPTCompletionResponse
        do {
            decoded = try decoder.decode(
                YandexGPTCompletionResponse.self,
                from: data
            )
        } catch {
            throw ServiceError.decodingFailed
        }
        
        let text = decoded.result?
            .alternatives?
            .first?
            .message?
            .text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let text, !text.isEmpty else {
            throw ServiceError.emptyResult
        }
        
        return text
    }
}
