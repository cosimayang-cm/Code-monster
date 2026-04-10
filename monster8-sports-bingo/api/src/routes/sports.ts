import { Hono } from "hono";
import type { Context } from "hono";

import { fail, ok } from "../lib/json";
import { proxySportsApi } from "../lib/sports";
import type { AppVariables, EnvBindings } from "../types/env";

const sports = new Hono<{ Bindings: EnvBindings; Variables: AppVariables }>();

async function proxyResponse(
  c: Context<{ Bindings: EnvBindings; Variables: AppVariables }>,
  endpoint: string,
  path: string,
  ttl: number,
  queryFactory?: (source: URLSearchParams) => URLSearchParams
): Promise<Response> {
  try {
    const sourceQuery = new URL(c.req.url).searchParams;
    const query = queryFactory ? queryFactory(sourceQuery) : new URLSearchParams(sourceQuery);
    const result = await proxySportsApi(c.env, endpoint, path, query, ttl);
    return ok(result.data, { headers: { "x-cache-status": result.cacheStatus } });
  } catch (error) {
    return fail("SPORTS_API_ERROR", error instanceof Error ? error.message : "Sports proxy failed", 502);
  }
}

sports.get("/sports", async (c) => proxyResponse(c, "sports", "/sports/", 60 * 60 * 24));
sports.get("/leagues", async (c) => proxyResponse(c, "leagues", "/leagues/", 60 * 60 * 24));
sports.get("/teams", async (c) => proxyResponse(c, "teams", "/teams/", 60 * 60 * 24));
sports.get("/events", async (c) => proxyResponse(c, "events", "/events/", 60 * 60));
sports.get("/events/:eventId", async (c) =>
  proxyResponse(c, "event", "/events/", 60 * 15, () => {
    const query = new URLSearchParams();
    query.set("eventID", c.req.param("eventId"));
    return query;
  })
);

export default sports;
