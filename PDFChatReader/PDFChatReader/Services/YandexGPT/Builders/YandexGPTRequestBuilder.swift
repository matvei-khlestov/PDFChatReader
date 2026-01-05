//
//  YandexGPTRequestBuilder.swift
//  PDFChatReader
//
//  Created by Matvei Khlestov on 05.01.2026.
//

import Foundation

struct YandexGPTRequestBuilder: YandexGPTRequestBuilding {

    // MARK: - Dependencies

    private let encoder: JSONEncoder

    // MARK: - Init

    init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    // MARK: - Public

    func makeCompletionRequest(
        baseURLString: String,
        apiKey: String,
        modelUri: String,
        messages: [ChatMessage],
        temperature: Double,
        maxTokens: Int
    ) throws -> URLRequest {

        guard let url = URL(
            string: "\(baseURLString)/foundationModels/v1/completion"
        ) else {
            throw ServiceError.badURL
        }

        let dtoMessages: [YandexGPTCompletionRequest.Message] = messages.map {
            .init(role: $0.role.rawValue, text: $0.text)
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

        return request
    }
}
