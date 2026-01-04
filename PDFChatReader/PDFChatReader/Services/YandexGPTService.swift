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
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let baseURLString: String

    // MARK: - Init

    init(
        apiKey: String,
        session: URLSession = YandexGPTService.makeSession(),
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder(),
        baseURLString: String = "https://llm.api.cloud.yandex.net"
    ) {
        self.apiKey = apiKey
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
        self.baseURLString = baseURLString
    }

    // MARK: - Public API

    func complete(
        modelUri: String,
        messages: [ChatMessage],
        temperature: Double = 0.3,
        maxTokens: Int = 800
    ) async throws -> String {

        guard let url = URL(
            string: "\(baseURLString)/foundationModels/v1/completion"
        ) else {
            throw ServiceError.badURL
        }

        let dtoMessages: [YandexGPTCompletionRequest.Message] = messages.map {
            .init(
                role: $0.role.rawValue,
                text: $0.text
            )
        }

        let body = YandexGPTCompletionRequest(
            modelUri: modelUri,
            completionOptions: .init(
                stream: false,
                temperature: temperature,
                maxTokens: maxTokens
            ),
            messages: dtoMessages
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ServiceError.httpError(
                statusCode: -1,
                body: "No HTTP response."
            )
        }

        guard (200...299).contains(http.statusCode) else {
            let bodyString = String(data: data, encoding: .utf8) ?? ""
            let trimmed = bodyString.trimmingCharacters(in: .whitespacesAndNewlines)
            let shortBody = String(trimmed.prefix(600))
            throw ServiceError.httpError(
                statusCode: http.statusCode,
                body: shortBody
            )
        }

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

// MARK: - Private helpers

private extension YandexGPTService {

    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }
}
