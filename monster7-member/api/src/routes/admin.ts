import { Hono } from "hono";
import { z } from "zod";

import { requireAdmin } from "../middleware/admin";
import { requireAuth } from "../middleware/auth";
import {
  getAdminUserDetail,
  getDashboardStats,
  listActivity,
  listUsers,
  updateUserRole,
  updateUserStatus,
} from "../services/user";
import { jsonSuccess, parseJsonBody } from "../utils/http";
import { parsePagination } from "../utils/validation";

import type { AppEnv, LoginMethod } from "../types";

export const adminRoutes = new Hono<AppEnv>();

adminRoutes.use("*", requireAuth, requireAdmin);

adminRoutes.get("/users", async (context) => {
  const pagination = parsePagination(
    context.req.query("page"),
    context.req.query("pageSize"),
  );
  const result = await listUsers(context.env, {
    ...pagination,
    search: context.req.query("search"),
  });

  return jsonSuccess(context, result.rows, 200, {
    pagination: result.pagination,
  });
});

adminRoutes.get("/users/:id", async (context) => {
  const detail = await getAdminUserDetail(context.env, context.req.param("id"));

  if (!detail) {
    return context.json(
      {
        error: {
          code: "NOT_FOUND",
          message: "User not found.",
        },
      },
      404,
    );
  }

  return jsonSuccess(context, detail);
});

adminRoutes.put("/users/:id/role", async (context) => {
  const payload = z
    .object({
      role: z.enum(["user", "admin"]),
    })
    .parse(await parseJsonBody(context));

  const result = await updateUserRole(context.env, context.req.param("id"), payload.role);
  return jsonSuccess(context, result);
});

adminRoutes.put("/users/:id/status", async (context) => {
  const payload = z
    .object({
      is_active: z.boolean(),
    })
    .parse(await parseJsonBody(context));

  const result = await updateUserStatus(
    context.env,
    context.req.param("id"),
    payload.is_active,
  );
  return jsonSuccess(context, result);
});

adminRoutes.get("/dashboard/stats", async (context) => {
  const stats = await getDashboardStats(context.env);
  return jsonSuccess(context, stats);
});

adminRoutes.get("/dashboard/activity", async (context) => {
  const pagination = parsePagination(
    context.req.query("page"),
    context.req.query("pageSize"),
  );
  const methodValue = context.req.query("method");
  const method = methodValue && ["email", "google", "github"].includes(methodValue)
    ? (methodValue as LoginMethod)
    : undefined;

  const result = await listActivity(context.env, {
    ...pagination,
    method,
    from: context.req.query("from"),
    to: context.req.query("to"),
  });

  return jsonSuccess(context, result.rows, 200, {
    pagination: result.pagination,
  });
});
