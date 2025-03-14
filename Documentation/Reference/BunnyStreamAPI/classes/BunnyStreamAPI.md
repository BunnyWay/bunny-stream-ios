**CLASS**

# `BunnyStreamAPI`

```swift
public class BunnyStreamAPI
```

A client SDK for interacting with the Bunny Stream API.

The `BunnyStreamAPI` class provides a convenient interface for accessing Bunny Stream's
content delivery and streaming services. It handles authentication, request management,
and provides access to all available API endpoints.

Example usage:
```swift
let api = BunnyStreamAPI(accessKey: "your-access-key")
// Use the api.client to make API calls
```

- Important: Make sure to keep your access key secure and never expose it in client-side code.

## Properties
### `client`

```swift
public let client: Client
```

The main API client interface for accessing Bunny Stream services.

Use this property to access all available API endpoints and operations.
The client is configured with proper authentication and date handling.

## Methods
### `init(accessKey:transport:)`

```swift
public init(accessKey: String, transport: ClientTransport = URLSessionTransport())
```

Creates a new instance of the Bunny Stream SDK.

- Parameters:
  - accessKey: The API access key for authentication. This can be found in your Bunny Stream dashboard.
  - transport: An optional custom transport layer for network communications. Defaults to `URLSessionTransport`.

- Note: The SDK automatically configures date handling and authentication middleware.

#### Parameters

| Name | Description |
| ---- | ----------- |
| accessKey | The API access key for authentication. This can be found in your Bunny Stream dashboard. |
| transport | An optional custom transport layer for network communications. Defaults to `URLSessionTransport`. |