//
//  YandexGPTService.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 03.01.2026.
//

import Foundation

protocol YandexGPTServicing {
    func complete(
        modelUri: String,
        messages: [YandexGPTCompletionRequest.Message],
        temperature: Double,
        maxTokens: Int
    ) async throws -> String
}

final class YandexGPTService: YandexGPTServicing {
    enum ServiceError: Error {
        case badURL
        case badResponse
        case emptyResult
    }

    private let apiKey: String
    private let session: URLSession
    private let baseURLString = "https://llm.api.cloud.yandex.net"

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func complete(
        modelUri: String,
        messages: [YandexGPTCompletionRequest.Message],
        temperature: Double = 0.3,
        maxTokens: Int = 800
    ) async throws -> String {
        guard let url = URL(string: "\(baseURLString)/foundationModels/v1/completion") else {
            throw ServiceError.badURL
        }

        let body = YandexGPTCompletionRequest(
            modelUri: modelUri,
            completionOptions: .init(stream: false, temperature: temperature, maxTokens: maxTokens),
            messages: messages
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Вариант A "по докам" может требовать IAM токен.
        // Если у тебя включен Api-Key, используй так:
        request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Authorization")

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ServiceError.badResponse
        }

        let decoded = try JSONDecoder().decode(YandexGPTCompletionResponse.self, from: data)
        let text = decoded.result?.alternatives?.first?.message?.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let text, !text.isEmpty else {
            throw ServiceError.emptyResult
        }

        return text
    }
}
