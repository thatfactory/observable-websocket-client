//
//  ObservableWebSocketService.swift
//
//
//  Created by Fernando Fernandes on 02.01.24.
//

import Foundation
import Toolbox

public final class ObservableWebSocketService: ObservableObject, @unchecked Sendable {

    @Published public var message: URLSessionWebSocketTask.Message?

    @Published public var codableError: CodableError?

    public var session = URLSession(configuration: .default)

    private let websocketURL: URL

    private var webSocketTask: URLSessionWebSocketTask?

    // MARK: - Lifecycle

    public init(url: URL) {
        self.websocketURL = url
        initializeWebSocket()
        receiveMessage()
    }
}

// MARK: - Interface

public extension ObservableWebSocketService {

    func send(message: String) {
        let wsMessage = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(wsMessage) { [weak self] error in
            guard let self, let error else { return }

            Task { @MainActor in
                self.codableError = .init(error)
            }
        }
    }

    func close(with closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure,
               reason: String? = nil) {
        webSocketTask?.cancel(with: closeCode, reason: reason?.data(using: .utf8))
    }
}

// MARK: - Private

private extension ObservableWebSocketService {

    func initializeWebSocket() {
        webSocketTask = session.webSocketTask(with: websocketURL)
        webSocketTask?.resume()
    }

    func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success(let message):
                    self.message = message
                    // Listen for the next message.
                    self.receiveMessage()

                case .failure(let error):
                    self.codableError = .init(error)
                }
            }
        }
    }
}
