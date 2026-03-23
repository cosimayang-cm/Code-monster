import { describe, expect, it } from 'vitest'

import { signAccessToken, signRefreshToken, verifyToken } from '../jwt'

const secret = 'monster7-test-secret'

describe('jwt utils', () => {
  it('signs and verifies access tokens', async () => {
    const token = await signAccessToken(secret, {
      sub: 'user-1',
      email: 'user@example.com',
      role: 'user',
    })

    const claims = await verifyToken(secret, token, 'access')

    expect(claims.sub).toBe('user-1')
    expect(claims.email).toBe('user@example.com')
    expect(claims.role).toBe('user')
    expect(claims.type).toBe('access')
  })

  it('keeps refresh tokens separate from access tokens', async () => {
    const token = await signRefreshToken(secret, {
      sub: 'user-2',
      email: 'admin@example.com',
      role: 'admin',
    })

    await expect(verifyToken(secret, token, 'access')).rejects.toThrow()
    await expect(verifyToken(secret, token, 'refresh')).resolves.toMatchObject({
      sub: 'user-2',
      role: 'admin',
    })
  })
})
