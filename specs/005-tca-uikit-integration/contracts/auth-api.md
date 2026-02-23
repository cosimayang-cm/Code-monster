# API Contract: Auth (Login)

**Base URL**: `https://dummyjson.com`
**Documentation**: https://dummyjson.com/docs/auth

## POST /auth/login

Authenticates a user with username and password.

### Request

```
POST https://dummyjson.com/auth/login
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

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| username | String | Yes | User's login name |
| password | String | Yes | User's password |
| expiresInMins | Int | No | Token expiry in minutes (default: 60) |

### Success Response (200)

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

### Error Response (400)

```json
{
  "message": "Invalid credentials"
}
```

### Test Credentials

| Username | Password | Expected |
|----------|----------|----------|
| emilys | emilyspass | Success |
| wronguser | wrongpass | 400 Error |

### Swift Model Mapping

```swift
struct LoginRequest: Encodable {
    let username: String
    let password: String
    let expiresInMins: Int = 30
}

struct LoginResponse: Codable, Equatable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let accessToken: String
    let refreshToken: String
}

struct LoginErrorResponse: Codable {
    let message: String
}
```
