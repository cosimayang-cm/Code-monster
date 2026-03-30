import type { OAuthProvider, PaginationInput } from "../types";

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
const VALID_IMAGE_TYPES = new Set(["image/jpeg", "image/png", "image/webp"]);

export const AVATAR_MAX_BYTES = 5 * 1024 * 1024;

export const validateEmail = (value: string): boolean => EMAIL_REGEX.test(value);

export const validatePassword = (value: string): boolean =>
  PASSWORD_REGEX.test(value);

export const validateProfileName = (value: string | null | undefined): boolean =>
  value == null || value.length <= 100;

export const validateProfileBio = (value: string | null | undefined): boolean =>
  value == null || value.length <= 500;

export const isAllowedImageType = (value: string): boolean =>
  VALID_IMAGE_TYPES.has(value);

export const getOAuthProvider = (value: string): OAuthProvider => {
  if (value !== "google" && value !== "github") {
    throw new Error("Unsupported OAuth provider.");
  }

  return value;
};

export const parsePagination = (
  pageValue: string | undefined,
  pageSizeValue: string | undefined,
  maxPageSize = 100,
): PaginationInput => {
  const page = Math.max(Number(pageValue ?? "1") || 1, 1);
  const requestedSize = Math.max(Number(pageSizeValue ?? "20") || 20, 1);
  const pageSize = Math.min(requestedSize, maxPageSize);

  return {
    page,
    pageSize,
    offset: (page - 1) * pageSize,
  };
};
