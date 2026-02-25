# API Contract: AuthClient

## Login

### Endpoint

```
POST https://dummyjson.com/auth/login
```

### Request

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
    "username": "emilys",
    "password": "emilyspass",
    "expiresInMins": 30
}
```

### Response - Success (HTTP 200)

```json
{
    "id": 1,
    "username": "emilys",
    "email": "emily.johnson@x.dummyjson.com",
    "firstName": "Emily",
    "lastName": "Johnson",
    "gender": "female",
    "image": "https://dummyjson.com/icon/emilys/128",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Response - Failure (HTTP 400)

```json
{
    "message": "Invalid credentials"
}
```

### TCA Dependency Client

```swift
@DependencyClient
struct AuthClient: Sendable {
    var login: @Sendable (_ username: String, _ password: String) async throws -> User
}

extension AuthClient: DependencyKey {
    static let liveValue: Self = .init(
        login: { username, password in
            var request = URLRequest(url: URL(string: "https://dummyjson.com/auth/login")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "username": username,
                "password": password,
                "expiresInMins": 30
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError
            }

            if httpResponse.statusCode == 200 {
                return try JSONDecoder().decode(User.self, from: data)
            } else {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw AuthError.serverError(errorResponse.message)
            }
        }
    )
}
```

### Error Types

```swift
enum AuthError: LocalizedError {
    case networkError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .serverError(let message):
            return message
        }
    }
}

struct ErrorResponse: Codable {
    let message: String
}
```

### Test Curl

```bash
# Success
curl -X POST https://dummyjson.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "emilys", "password": "emilyspass", "expiresInMins": 30}'

# Failure
curl -X POST https://dummyjson.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "wrong", "password": "wrong"}'
```
