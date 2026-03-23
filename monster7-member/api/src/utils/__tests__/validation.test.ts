import { describe, expect, it } from 'vitest'

import {
  AVATAR_MAX_BYTES,
  getOAuthProvider,
  isAllowedImageType,
  parsePagination,
  validateEmail,
  validatePassword,
  validateProfileBio,
  validateProfileName,
} from '../validation'

describe('validation utils', () => {
  it('validates email and password rules', () => {
    expect(validateEmail('member@example.com')).toBe(true)
    expect(validateEmail('wrong-email')).toBe(false)
    expect(validatePassword('Monster7123')).toBe(true)
    expect(validatePassword('weak')).toBe(false)
  })

  it('checks profile field limits', () => {
    expect(validateProfileName('Monster7')).toBe(true)
    expect(validateProfileName('a'.repeat(101))).toBe(false)
    expect(validateProfileBio('hello')).toBe(true)
    expect(validateProfileBio('a'.repeat(501))).toBe(false)
  })

  it('parses pagination with defaults and limits', () => {
    expect(parsePagination(undefined, undefined)).toEqual({
      page: 1,
      pageSize: 20,
      offset: 0,
    })

    expect(parsePagination('3', '999')).toEqual({
      page: 3,
      pageSize: 100,
      offset: 200,
    })
  })

  it('accepts allowed OAuth providers and image types', () => {
    expect(getOAuthProvider('google')).toBe('google')
    expect(getOAuthProvider('github')).toBe('github')
    expect(() => getOAuthProvider('facebook')).toThrow()
    expect(isAllowedImageType('image/webp')).toBe(true)
    expect(isAllowedImageType('image/gif')).toBe(false)
    expect(AVATAR_MAX_BYTES).toBe(5 * 1024 * 1024)
  })
})
