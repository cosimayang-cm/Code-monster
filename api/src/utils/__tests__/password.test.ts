import { describe, expect, it } from 'vitest'

import { hashPassword, verifyPassword } from '../password'

describe('password utils', () => {
  it('hashes and verifies a valid password', async () => {
    const password = 'Monster7123'
    const hash = await hashPassword(password)

    expect(hash).toContain('pbkdf2_sha256')
    await expect(verifyPassword(password, hash)).resolves.toBe(true)
    await expect(verifyPassword('WrongPass123', hash)).resolves.toBe(false)
  })
})
