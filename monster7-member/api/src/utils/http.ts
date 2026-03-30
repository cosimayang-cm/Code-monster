import type { Context } from "hono";
import { HTTPException } from "hono/http-exception";
import type { ContentfulStatusCode } from "hono/utils/http-status";

import type { AppEnv, PaginationMeta } from "../types";

export class ApiError extends Error {
  status: number;
  code: string;
  details?: unknown;

  constructor(status: number, code: string, message: string, details?: unknown) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export const jsonSuccess = <T>(
  context: Context<AppEnv>,
  data: T,
  status = 200,
  extras?: Record<string, unknown>,
) => context.json({ data, ...extras }, status as ContentfulStatusCode);

export const buildPagination = (
  total: number,
  page: number,
  pageSize: number,
): PaginationMeta => ({
  page,
  pageSize,
  total,
  totalPages: total === 0 ? 0 : Math.ceil(total / pageSize),
});

export const parseJsonBody = async <T>(context: Context<AppEnv>): Promise<T> => {
  try {
    return (await context.req.json()) as T;
  } catch (error) {
    throw new ApiError(400, "INVALID_JSON", "Request body must be valid JSON.", error);
  }
};

export const getClientIp = (context: Context<AppEnv>): string =>
  context.req.header("CF-Connecting-IP") ??
  context.req.header("X-Forwarded-For")?.split(",")[0]?.trim() ??
  "0.0.0.0";

export const getUserAgent = (context: Context<AppEnv>): string =>
  context.req.header("User-Agent") ?? "unknown";

export const normalizeErrorResponse = (error: unknown) => {
  if (error instanceof ApiError) {
    return {
      status: error.status,
      body: {
        error: {
          code: error.code,
          message: error.message,
          ...(error.details ? { details: error.details } : {}),
        },
      },
    };
  }

  if (error instanceof HTTPException) {
    return {
      status: error.status,
      body: {
        error: {
          code: "HTTP_EXCEPTION",
          message: error.message || "Request failed.",
        },
      },
    };
  }

  console.error(error);

  return {
    status: 500,
    body: {
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Something went wrong.",
      },
    },
  };
};
