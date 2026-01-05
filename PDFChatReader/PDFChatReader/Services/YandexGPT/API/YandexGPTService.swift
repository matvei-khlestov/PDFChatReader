//
//  YandexGPTService.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation

final class YandexGPTService: YandexGPTServicing {
    
    // MARK: - Dependencies
    
    private let apiKey: String
    private let session: URLSession
    private let baseURLString: String
    
    private let requestBuilder: YandexGPTRequestBuilding
    private let responseValidator: HTTPResponseValidating
    private let responseDecoder: YandexGPTResponseDecoding
    
    // MARK: - Init
    
    init(
        apiKey: String,
        session: URLSession = YandexGPTService.makeSession(),
        baseURLString: String = "https://llm.api.cloud.yandex.net",
        requestBuilder: YandexGPTRequestBuilding = YandexGPTRequestBuilder(),
        responseValidator: HTTPResponseValidating = DefaultHTTPResponseValidator(),
        responseDecoder: YandexGPTResponseDecoding = YandexGPTCompletionResponseDecoder()
    ) {
        self.apiKey = apiKey
        self.session = session
        self.baseURLString = baseURLString
        self.requestBuilder = requestBuilder
        self.responseValidator = responseValidator
        self.responseDecoder = responseDecoder
    }
    
    // MARK: - Public API
    
    func complete(
        modelUri: String,
        messages: [ChatMessage],
        temperature: Double = 0.3,
        maxTokens: Int = 800
    ) async throws -> String {
        
        let request = try requestBuilder.makeCompletionRequest(
            baseURLString: baseURLString,
            apiKey: apiKey,
            modelUri: modelUri,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens
        )
        
        let (data, response) = try await session.data(for: request)
        
        try responseValidator.validate(data: data, response: response)
        
        return try responseDecoder.decodeCompletionText(from: data)
    }
}

// MARK: - Private helpers

private extension YandexGPTService {
    
    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }
}
