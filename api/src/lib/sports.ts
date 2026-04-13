import type { EnvBindings } from "../types/env";

export interface SportsProxyResult {
  data: unknown;
  cacheStatus: "HIT" | "MISS";
}

const DEMO_SPORTS = [
  { sportID: "basketball", name: "Basketball", featuredLeague: "NBA" },
  { sportID: "football", name: "Football", featuredLeague: "NFL" },
  { sportID: "baseball", name: "Baseball", featuredLeague: "MLB" },
  { sportID: "soccer", name: "Soccer", featuredLeague: "EPL" },
  { sportID: "hockey", name: "Hockey", featuredLeague: "NHL" }
];

const DEMO_LEAGUES = [
  { leagueID: "NBA", name: "National Basketball Association", sportID: "basketball" },
  { leagueID: "NFL", name: "National Football League", sportID: "football" },
  { leagueID: "MLB", name: "Major League Baseball", sportID: "baseball" },
  { leagueID: "EPL", name: "Premier League", sportID: "soccer" },
  { leagueID: "NHL", name: "National Hockey League", sportID: "hockey" }
];

const DEMO_TEAMS = [
  { teamID: "bos-celtics", name: "Boston Celtics", leagueID: "NBA" },
  { teamID: "kc-chiefs", name: "Kansas City Chiefs", leagueID: "NFL" },
  { teamID: "la-dodgers", name: "Los Angeles Dodgers", leagueID: "MLB" },
  { teamID: "arsenal", name: "Arsenal", leagueID: "EPL" },
  { teamID: "ny-rangers", name: "New York Rangers", leagueID: "NHL" }
];

type DemoMatchSeed = {
  leagueID: string;
  id: string;
  homeTeam: string;
  awayTeam: string;
  offsetMinutes: number;
  liveScore?: { home: number; away: number };
  odds: { homeMoneyline: number; awayMoneyline: number };
};

const DEMO_MATCH_SEEDS: DemoMatchSeed[] = [
  {
    leagueID: "NBA",
    id: "nba-001",
    homeTeam: "Boston Celtics",
    awayTeam: "Milwaukee Bucks",
    offsetMinutes: -28,
    liveScore: { home: 58, away: 54 },
    odds: { homeMoneyline: -135, awayMoneyline: 120 }
  },
  {
    leagueID: "NBA",
    id: "nba-002",
    homeTeam: "Los Angeles Lakers",
    awayTeam: "Golden State Warriors",
    offsetMinutes: 36,
    odds: { homeMoneyline: -110, awayMoneyline: 102 }
  },
  {
    leagueID: "NBA",
    id: "nba-003",
    homeTeam: "Miami Heat",
    awayTeam: "New York Knicks",
    offsetMinutes: 102,
    odds: { homeMoneyline: 118, awayMoneyline: -128 }
  },
  {
    leagueID: "NFL",
    id: "nfl-001",
    homeTeam: "Kansas City Chiefs",
    awayTeam: "Baltimore Ravens",
    offsetMinutes: -14,
    liveScore: { home: 17, away: 14 },
    odds: { homeMoneyline: -112, awayMoneyline: 105 }
  },
  {
    leagueID: "NFL",
    id: "nfl-002",
    homeTeam: "San Francisco 49ers",
    awayTeam: "Philadelphia Eagles",
    offsetMinutes: 58,
    odds: { homeMoneyline: -124, awayMoneyline: 114 }
  },
  {
    leagueID: "NFL",
    id: "nfl-003",
    homeTeam: "Buffalo Bills",
    awayTeam: "Cincinnati Bengals",
    offsetMinutes: 138,
    odds: { homeMoneyline: -105, awayMoneyline: -101 }
  },
  {
    leagueID: "MLB",
    id: "mlb-001",
    homeTeam: "Los Angeles Dodgers",
    awayTeam: "San Diego Padres",
    offsetMinutes: -45,
    liveScore: { home: 4, away: 3 },
    odds: { homeMoneyline: -150, awayMoneyline: 135 }
  },
  {
    leagueID: "MLB",
    id: "mlb-002",
    homeTeam: "New York Yankees",
    awayTeam: "Boston Red Sox",
    offsetMinutes: 24,
    odds: { homeMoneyline: -132, awayMoneyline: 122 }
  },
  {
    leagueID: "MLB",
    id: "mlb-003",
    homeTeam: "Chicago Cubs",
    awayTeam: "St. Louis Cardinals",
    offsetMinutes: 118,
    odds: { homeMoneyline: 108, awayMoneyline: -118 }
  },
  {
    leagueID: "EPL",
    id: "epl-001",
    homeTeam: "Arsenal",
    awayTeam: "Tottenham Hotspur",
    offsetMinutes: -20,
    liveScore: { home: 1, away: 0 },
    odds: { homeMoneyline: -125, awayMoneyline: 160 }
  },
  {
    leagueID: "EPL",
    id: "epl-002",
    homeTeam: "Liverpool",
    awayTeam: "Chelsea",
    offsetMinutes: 42,
    odds: { homeMoneyline: -118, awayMoneyline: 142 }
  },
  {
    leagueID: "EPL",
    id: "epl-003",
    homeTeam: "Manchester City",
    awayTeam: "Newcastle United",
    offsetMinutes: 134,
    odds: { homeMoneyline: -155, awayMoneyline: 190 }
  },
  {
    leagueID: "NHL",
    id: "nhl-001",
    homeTeam: "New York Rangers",
    awayTeam: "Boston Bruins",
    offsetMinutes: -32,
    liveScore: { home: 2, away: 2 },
    odds: { homeMoneyline: -118, awayMoneyline: 108 }
  },
  {
    leagueID: "NHL",
    id: "nhl-002",
    homeTeam: "Toronto Maple Leafs",
    awayTeam: "Montreal Canadiens",
    offsetMinutes: 48,
    odds: { homeMoneyline: -128, awayMoneyline: 118 }
  },
  {
    leagueID: "NHL",
    id: "nhl-003",
    homeTeam: "Edmonton Oilers",
    awayTeam: "Vancouver Canucks",
    offsetMinutes: 126,
    odds: { homeMoneyline: -120, awayMoneyline: 112 }
  }
];

function minutesFromNow(offsetMinutes: number): string {
  const now = new Date();
  const shifted = new Date(now.getTime() + offsetMinutes * 60_000);
  return shifted.toISOString();
}

function getDemoEvents() {
  return DEMO_MATCH_SEEDS.map((seed) => ({
    eventID: seed.id,
    leagueID: seed.leagueID,
    homeTeam: seed.homeTeam,
    awayTeam: seed.awayTeam,
    commenceTime: minutesFromNow(seed.offsetMinutes),
    status: seed.offsetMinutes < 0 ? "live" : "upcoming",
    score: seed.liveScore ?? {},
    odds: seed.odds
  }));
}

function getDemoPayload(endpoint: string, query: URLSearchParams): unknown {
  const demoEvents = getDemoEvents();
  switch (endpoint) {
    case "sports":
      return DEMO_SPORTS;
    case "leagues":
      return DEMO_LEAGUES;
    case "teams":
      return DEMO_TEAMS;
    case "events": {
      const leagueID = query.get("leagueID");
      if (!leagueID) {
        return demoEvents;
      }
      const allowed = new Set(leagueID.split(",").map((value) => value.trim()));
      return demoEvents.filter((item) => allowed.has(item.leagueID));
    }
    case "event": {
      const eventID = query.get("eventID");
      return demoEvents.find((item) => item.eventID === eventID) ?? null;
    }
    default:
      return [];
  }
}

function buildCacheKey(endpoint: string, query: URLSearchParams): string {
  const collected: Array<[string, string]> = [];
  query.forEach((value, key) => {
    collected.push([key, value]);
  });
  const pairs = collected.sort(([leftKey, leftValue], [rightKey, rightValue]) => {
    if (leftKey === rightKey) {
      return leftValue.localeCompare(rightValue);
    }
    return leftKey.localeCompare(rightKey);
  });
  const serialized = new URLSearchParams(pairs).toString();
  return serialized ? `sports_api:${endpoint}:${serialized}` : `sports_api:${endpoint}`;
}

function buildExternalUrl(baseUrl: string, path: string, query: URLSearchParams): string {
  const normalizedBase = baseUrl.endsWith("/") ? baseUrl : `${baseUrl}/`;
  const normalizedPath = path.startsWith("/") ? path.slice(1) : path;
  const target = new URL(normalizedPath, normalizedBase);
  query.forEach((value, key) => target.searchParams.set(key, value));
  return target.toString();
}

export async function proxySportsApi(
  env: EnvBindings,
  endpoint: string,
  path: string,
  query: URLSearchParams,
  ttlSeconds: number
): Promise<SportsProxyResult> {
  if (!env.SPORTSGAMEODDS_API_KEY) {
    return {
      data: getDemoPayload(endpoint, query),
      cacheStatus: "MISS"
    };
  }

  const cacheKey = buildCacheKey(endpoint, query);
  const cached = await env.SPORTS_CACHE.get(cacheKey, "json");
  if (cached) {
    return { data: cached, cacheStatus: "HIT" };
  }

  const url = buildExternalUrl(env.SPORTS_API_BASE_URL ?? "https://api.sportsgameodds.com/v2", path, query);
  const response = await fetch(url, {
    headers: {
      "X-Api-Key": env.SPORTSGAMEODDS_API_KEY
    }
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Sports API request failed (${response.status}): ${body}`);
  }

  const data = await response.json();
  await env.SPORTS_CACHE.put(cacheKey, JSON.stringify(data), { expirationTtl: ttlSeconds });
  return { data, cacheStatus: "MISS" };
}
