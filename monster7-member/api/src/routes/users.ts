import { Hono } from "hono";
import { z } from "zod";

import { requireAuth } from "../middleware/auth";
import { changePassword } from "../services/auth";
import {
  findOAuthAccountByUserProvider,
  getLoginHistory,
  getOAuthAccounts,
  getPublicUser,
  getUserById,
  unlinkOAuthAccount,
  updateUserAvatar,
  updateUserProfile,
} from "../services/user";
import { jsonSuccess, parseJsonBody, ApiError } from "../utils/http";
import {
  AVATAR_MAX_BYTES,
  getOAuthProvider,
  isAllowedImageType,
  parsePagination,
  validateProfileBio,
  validateProfileName,
} from "../utils/validation";
import { generateUUID } from "../utils/uuid";

import type { AppEnv } from "../types";

const profileSchema = z.object({
  name: z.string().max(100).nullable().optional(),
  bio: z.string().max(500).nullable().optional(),
});

const passwordSchema = z.object({
  currentPassword: z.string().min(1),
  newPassword: z.string(),
});

const CONTENT_TYPE_TO_EXTENSION: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
};

export const usersRoutes = new Hono<AppEnv>();

usersRoutes.use("*", requireAuth);

usersRoutes.get("/me", async (context) => {
  const auth = context.get("auth");
  const user = await getUserById(context.env, auth.userId);

  if (!user) {
    throw new ApiError(404, "NOT_FOUND", "User not found.");
  }

  return jsonSuccess(context, getPublicUser(user));
});

usersRoutes.put("/me", async (context) => {
  const auth = context.get("auth");
  const payload = profileSchema.parse(await parseJsonBody(context));
  const name = payload.name?.trim() || null;
  const bio = payload.bio?.trim() || null;

  if (!validateProfileName(name) || !validateProfileBio(bio)) {
    throw new ApiError(
      400,
      "VALIDATION_ERROR",
      "Profile values exceed the allowed length.",
    );
  }

  const user = await updateUserProfile(context.env, auth.userId, { name, bio });
  return jsonSuccess(context, user);
});

usersRoutes.post("/me/avatar", async (context) => {
  const auth = context.get("auth");
  const bucket = context.env.BUCKET;
  const publicBase = context.env.R2_PUBLIC_URL?.trim().replace(/\/+$/, "");

  if (!bucket || !publicBase) {
    throw new ApiError(
      503,
      "AVATAR_STORAGE_NOT_CONFIGURED",
      "Avatar upload is temporarily unavailable in this environment.",
    );
  }

  const formData = await context.req.formData();
  const avatar = formData.get("avatar");

  if (!(avatar instanceof File)) {
    throw new ApiError(400, "INVALID_FILE_TYPE", "Avatar file is required.");
  }

  if (!isAllowedImageType(avatar.type)) {
    throw new ApiError(
      400,
      "INVALID_FILE_TYPE",
      "Only jpeg, png, and webp files are supported.",
    );
  }

  if (avatar.size > AVATAR_MAX_BYTES) {
    throw new ApiError(400, "FILE_TOO_LARGE", "Avatar must be 5MB or smaller.");
  }

  const extension = CONTENT_TYPE_TO_EXTENSION[avatar.type];
  const objectKey = `avatars/${auth.userId}/${generateUUID()}.${extension}`;

  await bucket.put(objectKey, await avatar.arrayBuffer(), {
    httpMetadata: {
      contentType: avatar.type,
    },
  });

  const avatarUrl = `${publicBase}/${objectKey}`;
  await updateUserAvatar(context.env, auth.userId, avatarUrl);

  return jsonSuccess(context, { avatar_url: avatarUrl });
});

usersRoutes.put("/me/password", async (context) => {
  const auth = context.get("auth");
  const payload = passwordSchema.parse(await parseJsonBody(context));

  await changePassword(context.env, {
    userId: auth.userId,
    currentPassword: payload.currentPassword,
    newPassword: payload.newPassword,
  });

  return jsonSuccess(context, {
    message: "Password updated successfully.",
  });
});

usersRoutes.get("/me/login-history", async (context) => {
  const auth = context.get("auth");
  const pagination = parsePagination(
    context.req.query("page"),
    context.req.query("pageSize"),
  );
  const result = await getLoginHistory(context.env, auth.userId, pagination);

  return jsonSuccess(context, result.rows, 200, {
    pagination: result.pagination,
  });
});

usersRoutes.get("/me/oauth-accounts", async (context) => {
  const auth = context.get("auth");
  const accounts = await getOAuthAccounts(context.env, auth.userId);
  return jsonSuccess(context, accounts);
});

usersRoutes.delete("/me/oauth-accounts/:provider", async (context) => {
  const auth = context.get("auth");
  const provider = getOAuthProvider(context.req.param("provider"));
  const user = await getUserById(context.env, auth.userId);

  if (!user) {
    throw new ApiError(404, "NOT_FOUND", "User not found.");
  }

  const account = await findOAuthAccountByUserProvider(context.env, auth.userId, provider);

  if (!account) {
    throw new ApiError(404, "NOT_FOUND", "OAuth account not found.");
  }

  const accounts = await getOAuthAccounts(context.env, auth.userId);
  const hasPassword = Boolean(user.password_hash);

  if (!hasPassword && accounts.length <= 1) {
    throw new ApiError(
      400,
      "LAST_LOGIN_METHOD",
      "Cannot remove the last available login method.",
    );
  }

  await unlinkOAuthAccount(context.env, auth.userId, provider);

  return jsonSuccess(context, {
    message: "OAuth account unlinked successfully.",
  });
});
