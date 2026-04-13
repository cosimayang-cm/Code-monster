import { Hono } from "hono";

import { authenticateRequest } from "../lib/auth";
import { ok } from "../lib/json";
import { getPublicUser, getUserById } from "../lib/users";
import type { AppVariables, EnvBindings } from "../types/env";

const usersRoutes = new Hono<{ Bindings: EnvBindings; Variables: AppVariables }>();

usersRoutes.get("/me", async (c) => {
  const auth = await authenticateRequest(c);
  const user = await getUserById(c.env, auth.userId);
  return ok({ user: getPublicUser(user) });
});

export default usersRoutes;
