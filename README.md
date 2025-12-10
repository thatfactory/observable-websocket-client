[![swift-version](https://img.shields.io/badge/swift-6.2-ea7a50.svg?logo=swift&logoColor=white)](https://developer.apple.com/swift/)
[![xcode-version](https://img.shields.io/badge/xcode-26.2-50ace8.svg?logo=xcode&logoColor=white)](https://developer.apple.com/xcode/)
[![spm-ready](https://img.shields.io/badge/spm-ready-b68f6a.svg?logo=gitlfs&logoColor=white)](https://developer.apple.com/documentation/xcode/swift-packages)
[![platforms](https://img.shields.io/badge/platforms-iOS%2017+%20%7C%20macOS%2014+%20-lightgrey.svg?logo=apple&logoColor=white)](https://en.wikipedia.org/wiki/List_of_Apple_operating_systems)
[![license](https://img.shields.io/badge/license-MIT-67ac5b.svg?logo=googledocs&logoColor=white)](https://en.wikipedia.org/wiki/MIT_License)
[![release](https://github.com/thatfactory/observable-websocket-client/actions/workflows/release.yml/badge.svg)](https://github.com/thatfactory/observable-websocket-client/actions/workflows/release.yml)

# ObservableWebSocketClient ⚡
A Swift package that establishes [WebSocket connections](https://en.wikipedia.org/wiki/WebSocket) and publishes received messages and errors from an [Observable Object](https://developer.apple.com/documentation/combine/observableobject).

## Usage

### Initialization

```swift
let websocketURL = URL(string: "wss://websocket-endpoint.com")!
let wsClient = ObservableWebSocketClient(websocketURL: websocketURL)

/*
 A `URLSessionWebSocketTask` is created and resumed just after the
 client initialization. Nothing else is required at this point.
 */
```

### Observation

#### Connection

```swift
wsClient
    .$isConnected
    .sink { isConnected in
        print("isConnected: \(isConnected)")
    }
    .store(in: &cancellables)
```

#### Messages

```swift
wsClient
    .$codableMessage
    .compactMap{ $0 }
    .sink { codableMessage in
        print("Message: \(codableMessage.messageAsString())")
        // codableMessage.message returns the original `URLSessionWebSocketTask.Message`
    }
    .store(in: &cancellables)
```

#### Errors

```swift
wsClient
    .$codableError
    .compactMap{ $0 }
    .sink { codableError in
        print("Error: \(codableError.description)")
    }
    .store(in: &cancellables)
```

### Ping/Pong 🏓

#### Ping Message
Passing in a `pingTimerInterval` during the client initialization will cause a timer to continuously send the given `pingMessage` to the WS server, keeping the connection alive:

```swift
let websocketURL = URL(string: "wss://endpoint.com")!
let wsClient = ObservableWebSocketClient(
    websocketURL: websocketURL,
    pingTimerInterval: 18, // Every 18 seconds
    pingMessage: "{\"type\": \"ping\"}" // The format is defined by the WS server
)
```

#### Ping Message with Generated ID
To generate a unique ID for the ping-type message, use the closure in `pingMessageWithGenerateId`. The closure takes a `String` (the generated unique ID), returns a modified version of the message incorporating the ID, and sends it to the WS server. As in the above, these steps are repeated continuously using the interval indicated in the `pingTimerInterval`, generating unique IDs each time to keep the connection alive:

```swift
let websocketURL = URL(string: "wss://endpoint.com")!
let wsClient = ObservableWebSocketClient(
    websocketURL: websocketURL,
    pingTimerInterval: 18, // Every 18 seconds
    pingMessageWithGeneratedId: { generatedId in
        "{\"id\": \"\(generatedId)\", \"type\": \"ping\"}"  // The format is defined by the WS server
    }
)
```

### Sending messages
After the client is initialized and a connection is established, messages can be sent via the `ObservableWebSocketClient.sendMessage(_:)` API:

```swift
wsClient.sendMessage("A String WebSocket message")
```

## Demo
In this demo app, the `ObservableWebSocketClient` connects to a [Kucoin WebSocket server](https://www.kucoin.com/docs/websocket/introduction) and sends `ping` messages every `pingTimerInterval` to keep the connection alive. The server responds with `welcome` and `pong` messages:

https://github.com/thatfactory/observable-websocket-client/assets/664951/2c8897e4-6d25-413b-9f12-d61b32ebbf0d

## Integration
### Xcode
Use Xcode's [built-in support for SPM](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

*or...*

### Package.swift
In your `Package.swift`, add `ObservableWebSocketClient` as a dependency:

```swift
dependencies: [
    .package(
        url: "https://github.com/thatfactory/observable-websocket-client",
        from: "0.1.0"
    )
]
```

Associate the dependency with your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(
                name: "ObservableWebSocketClient",
                package: "observable-websocket-client"
            )
        ]
    )
]
```

Run: `swift build`

