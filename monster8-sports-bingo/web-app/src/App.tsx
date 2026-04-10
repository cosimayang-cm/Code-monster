import { FormEvent, useEffect, useState } from "react";

import { API_BASE_URL, apiRequest } from "./lib/api";

type Actor = { type: "guest" | "user"; id: string };

type WalletBalance = {
  actor: Actor;
  balance: number;
  trialCreditAwarded: number;
};

type WalletTransaction = {
  id: number;
  type: string;
  amount: number;
  reference_id: string | null;
  description: string | null;
  created_at: string;
};

type DrawRound = {
  round_id: string;
  draw_time: string;
  numbers: string | null;
  super_number: number | null;
  status: "pending" | "drawn" | "settled";
};

type CurrentState = {
  currentRound: DrawRound;
  latestDraw: DrawRound | null;
  countdownSeconds: number;
  cutoffAt: string;
};

type BetRecord = {
  id: number;
  round_id: string;
  bet_type: string;
  selected_numbers: string | null;
  selected_option: string | null;
  amount: number;
  status: string;
  matched_count: number | null;
  multiplier: number | null;
  payout: number;
  has_super_number: number;
  created_at: string;
};

type DrawStats = {
  draws: number;
  frequency?: Array<{ number: number; count: number }>;
  bigSmall?: { big: number; small: number; tie: number };
  oddEven?: { odd: number; even: number; tie: number };
};

type SportRecord = {
  id: string;
  label: string;
  featuredLeague?: string;
};

type LeagueRecord = {
  id: string;
  label: string;
  sportId?: string;
};

type EventRecord = {
  id: string;
  leagueId: string;
  leagueLabel: string;
  sportId?: string;
  status?: "live" | "upcoming" | "final";
  homeTeam: string;
  awayTeam: string;
  commenceTime: string;
  homeScore?: number;
  awayScore?: number;
  homeMoneyline?: number;
  awayMoneyline?: number;
  homeSpread?: number;
  awaySpread?: number;
  homeSpreadOdds?: number;
  awaySpreadOdds?: number;
  totalLine?: number;
  overOdds?: number;
  underOdds?: number;
  openHomeSpread?: number;
  openAwaySpread?: number;
  openTotalLine?: number;
};

type FavoriteEventSnapshot = EventRecord & {
  savedAt: string;
};

type SportsBetHistoryRecord = {
  id: string;
  ticketNo: string;
  eventId: string;
  sportLabel: string;
  leagueLabel: string;
  homeTeam: string;
  awayTeam: string;
  matchup: string;
  marketLabel: string;
  pickLabel: string;
  oddsLabel: string;
  amount: number;
  potentialPayout: number;
  eventTime: string;
  createdAt: string;
  status: "pending" | "won" | "lost";
  homeScore?: number;
  awayScore?: number;
  eventStatus?: "live" | "upcoming" | "final";
};

type WalletBetRecord = {
  id: string;
  source: "sports" | "bingo";
  ticketNo: string;
  category: string;
  title: string;
  subtitle: string;
  amount: number;
  payout: number | null;
  status: "pending" | "won" | "lost" | "refunded";
  statusLabel: string;
  createdAt: string;
  detailRows: Array<{ label: string; value: string }>;
};

type StatBarItem = {
  label: string;
  percentage: number;
  note: string;
};

type SportMarketOption = {
  id: string;
  label: string;
  line?: string;
  odds: string;
};

type SportMarket = {
  id: "popular" | "moneyline" | "spread" | "total";
  label: string;
  options: SportMarketOption[];
};

type QuickSportFilter = {
  id: string;
  label: string;
  code: string;
  sportId: string;
  leagueId?: string;
};

type DepositMethod = "bank" | "linepay" | "usdt";

const tabs = [
  { id: "overview", label: "總覽" },
  { id: "sports", label: "Sports" },
  { id: "bingo", label: "Bingo 大廳" },
  { id: "bet", label: "立即投注" },
  { id: "wallet", label: "錢包" },
  { id: "history", label: "歷史統計" }
] as const;

const defaultSports: SportRecord[] = [
  { id: "BASKETBALL", label: "籃球", featuredLeague: "NBA" },
  { id: "FOOTBALL", label: "美式足球", featuredLeague: "NFL" },
  { id: "BASEBALL", label: "棒球", featuredLeague: "MLB" },
  { id: "SOCCER", label: "足球", featuredLeague: "MLS" },
  { id: "HOCKEY", label: "冰球", featuredLeague: "NHL" }
];

const quickSportBlueprints = [
  { id: "nba", label: "NBA", code: "NBA", sportId: "BASKETBALL", preferredLeagueIds: ["NBA"] },
  { id: "soccer", label: "足球", code: "SC", sportId: "SOCCER", preferredLeagueIds: ["MLS", "UEFA_CHAMPIONS_LEAGUE"] },
  { id: "baseball", label: "棒球", code: "BB", sportId: "BASEBALL", preferredLeagueIds: ["MLB"] },
  { id: "hockey", label: "NHL", code: "NHL", sportId: "HOCKEY", preferredLeagueIds: ["NHL"] }
];

const depositMethodConfigs: Array<{
  id: DepositMethod;
  label: string;
  hint: string;
  meta: string;
  summary: string;
  details: Array<{ label: string; value: string }>;
}> = [
  {
    id: "bank",
    label: "銀行轉帳",
    hint: "台灣銀行 / ATM / 網銀",
    meta: "約 1~3 分鐘入帳",
    summary: "適合一般台灣使用者，提供模擬虛擬帳號與銀行代碼。",
    details: [
      { label: "銀行代碼", value: "812 台新銀行" },
      { label: "虛擬帳號", value: "9688-888-770001" },
      { label: "收款戶名", value: "Velocabet Wallet" }
    ]
  },
  {
    id: "linepay",
    label: "LINE Pay",
    hint: "快速跳轉授權",
    meta: "模擬即時入帳",
    summary: "適合手機支付，模擬完成授權後立即回寫錢包餘額。",
    details: [
      { label: "付款商戶", value: "Velocabet Wallet" },
      { label: "付款方式", value: "LINE Pay Balance / Card" },
      { label: "說明", value: "完成授權後 5 秒內更新餘額" }
    ]
  },
  {
    id: "usdt",
    label: "USDT",
    hint: "TRC20 鏈上入金",
    meta: "需確認鏈別",
    summary: "提供模擬 USDT(TRC20) 入金資訊，適合加密貨幣玩家。",
    details: [
      { label: "幣種", value: "USDT (TRC20)" },
      { label: "入金地址", value: "TVx8...8f92 mock wallet" },
      { label: "最小入金", value: "10 USDT" }
    ]
  }
];

const TEAM_ALIASES_ZH_TW: Record<string, string> = {
  "Atlanta Hawks": "亞特蘭大老鷹",
  "Boston Celtics": "波士頓塞爾提克",
  "Brooklyn Nets": "布魯克林籃網",
  "Charlotte Hornets": "夏洛特黃蜂",
  "Chicago Bulls": "芝加哥公牛",
  "Cleveland Cavaliers": "克里夫蘭騎士",
  "Dallas Mavericks": "達拉斯獨行俠",
  "Denver Nuggets": "丹佛金塊",
  "Detroit Pistons": "底特律活塞",
  "Golden State Warriors": "金州勇士",
  "Houston Rockets": "休士頓火箭",
  "Indiana Pacers": "印第安那溜馬",
  "LA Clippers": "洛杉磯快艇",
  "Los Angeles Lakers": "洛杉磯湖人",
  "Memphis Grizzlies": "曼菲斯灰熊",
  "Miami Heat": "邁阿密熱火",
  "Milwaukee Bucks": "密爾瓦基公鹿",
  "Minnesota Timberwolves": "明尼蘇達灰狼",
  "New Orleans Pelicans": "紐奧良鵜鶘",
  "New York Knicks": "紐約尼克",
  "Oklahoma City Thunder": "奧克拉荷馬雷霆",
  "Orlando Magic": "奧蘭多魔術",
  "Philadelphia 76ers": "費城七六人",
  "Phoenix Suns": "鳳凰城太陽",
  "Portland Trail Blazers": "波特蘭拓荒者",
  "Sacramento Kings": "沙加緬度國王",
  "San Antonio Spurs": "聖安東尼奧馬刺",
  "Toronto Raptors": "多倫多暴龍",
  "Utah Jazz": "猶他爵士",
  "Washington Wizards": "華盛頓巫師",
  "New York Yankees": "紐約洋基",
  "Boston Red Sox": "波士頓紅襪",
  "Los Angeles Dodgers": "洛杉磯道奇",
  "San Diego Padres": "聖地牙哥教士",
  "Chicago Cubs": "芝加哥小熊",
  "St. Louis Cardinals": "聖路易紅雀",
  "Seattle Mariners": "西雅圖水手",
  "Toronto Blue Jays": "多倫多藍鳥",
  "New York Mets": "紐約大都會",
  "San Francisco Giants": "舊金山巨人",
  "Seattle Kraken": "西雅圖海怪",
  "Anaheim Ducks": "安那罕鴨",
  "Los Angeles Kings": "洛杉磯國王",
  "Boston Bruins": "波士頓棕熊",
  "New York Islanders": "紐約島人",
  "New York Rangers": "紐約遊騎兵",
  "Toronto Maple Leafs": "多倫多楓葉",
  "Montreal Canadiens": "蒙特婁加拿大人",
  "Edmonton Oilers": "艾德蒙頓油人",
  "Vancouver Canucks": "溫哥華加人",
  "Pittsburgh Penguins": "匹茲堡企鵝",
  "Colorado Avalanche": "科羅拉多雪崩",
  "Toronto FC": "多倫多 FC",
  "CF Montréal": "CF 蒙特婁",
  "Austin FC": "奧斯汀 FC",
  "Portland Timbers": "波特蘭伐木者",
  "Charlotte FC": "夏洛特 FC",
  "Inter Miami CF": "邁阿密國際",
  "LA Galaxy": "洛杉磯銀河",
  "Los Angeles FC": "洛杉磯 FC",
  "Seattle Sounders FC": "西雅圖海灣人",
  "Atlanta United FC": "亞特蘭大聯"
};

const numberGrid = Array.from({ length: 80 }, (_, index) => index + 1);

export default function App() {
  const [tab, setTab] = useState<(typeof tabs)[number]["id"]>("overview");
  const [viewer, setViewer] = useState<Actor | null>(null);
  const [wallet, setWallet] = useState<WalletBalance | null>(null);
  const [transactions, setTransactions] = useState<WalletTransaction[]>([]);
  const [current, setCurrent] = useState<CurrentState | null>(null);
  const [draws, setDraws] = useState<DrawRound[]>([]);
  const [drawHistory, setDrawHistory] = useState<DrawRound[]>([]);
  const [bets, setBets] = useState<BetRecord[]>([]);
  const [numberStats, setNumberStats] = useState<DrawStats | null>(null);
  const [bigSmallStats, setBigSmallStats] = useState<DrawStats | null>(null);
  const [oddEvenStats, setOddEvenStats] = useState<DrawStats | null>(null);
  const [sports, setSports] = useState<SportRecord[]>([]);
  const [leagues, setLeagues] = useState<LeagueRecord[]>([]);
  const [events, setEvents] = useState<EventRecord[]>([]);
  const [activeSport, setActiveSport] = useState<string>("");
  const [activeLeague, setActiveLeague] = useState<string>("");
  const [loading, setLoading] = useState(true);
  const [sportsLoading, setSportsLoading] = useState(true);
  const [sportsError, setSportsError] = useState("");
  const [feedback, setFeedback] = useState("");
  const [betType, setBetType] = useState("star_3");
  const [selectedNumbers, setSelectedNumbers] = useState<number[]>([]);
  const [selectedOption, setSelectedOption] = useState("big");
  const [depositAmount, setDepositAmount] = useState("1000");
  const [selectedDepositMethod, setSelectedDepositMethod] = useState<DepositMethod>("bank");
  const [favoriteEventIds, setFavoriteEventIds] = useState<string[]>([]);
  const [favoriteEventMap, setFavoriteEventMap] = useState<Record<string, FavoriteEventSnapshot>>({});
  const [favoriteSeeded, setFavoriteSeeded] = useState(false);
  const [favoriteIdsHydrated, setFavoriteIdsHydrated] = useState(false);
  const [favoriteMapHydrated, setFavoriteMapHydrated] = useState(false);
  const [selectedEventId, setSelectedEventId] = useState("");
  const [selectedSportsMarket, setSelectedSportsMarket] = useState<SportMarket["id"]>("popular");
  const [selectedSportsPickId, setSelectedSportsPickId] = useState("");
  const [selectedSportsPick, setSelectedSportsPick] = useState("");
  const [selectedSportsDraft, setSelectedSportsDraft] = useState<SportsBetHistoryRecord | null>(null);
  const [sportsStakeAmount, setSportsStakeAmount] = useState("500");
  const [countdownValue, setCountdownValue] = useState(0);
  const [sportsBetHistory, setSportsBetHistory] = useState<SportsBetHistoryRecord[]>([]);
  const [sportsHistoryHydrated, setSportsHistoryHydrated] = useState(false);
  const [selectedWalletBetId, setSelectedWalletBetId] = useState("");
  const [selectedWalletBetHydrated, setSelectedWalletBetHydrated] = useState(false);

  useEffect(() => {
    void refreshDashboard();
    void refreshSportsDirectory();
  }, []);

  useEffect(() => {
    const timer = window.setInterval(() => {
      void refreshDashboard(true);
    }, 15000);

    return () => window.clearInterval(timer);
  }, []);

  useEffect(() => {
    if (!current?.currentRound.draw_time) {
      setCountdownValue(0);
      return;
    }

    const syncCountdown = () => {
      const drawAt = new Date(current.currentRound.draw_time).getTime();
      const nextValue = Math.max(0, Math.ceil((drawAt - Date.now()) / 1000));
      setCountdownValue(nextValue);
    };

    syncCountdown();
    const timer = window.setInterval(syncCountdown, 1000);
    return () => window.clearInterval(timer);
  }, [current?.currentRound.draw_time]);

  useEffect(() => {
    try {
      const raw = window.localStorage.getItem("monster8.favorite-events");
      if (!raw) {
        setFavoriteIdsHydrated(true);
        return;
      }
      const parsed = JSON.parse(raw) as unknown;
      if (Array.isArray(parsed)) {
        const ids = parsed.filter((item): item is string => typeof item === "string");
        setFavoriteEventIds(ids);
        if (ids.length > 0) {
          setFavoriteSeeded(true);
        }
      }
    } catch {
      // Ignore invalid local storage payloads.
    } finally {
      setFavoriteIdsHydrated(true);
    }
  }, []);

  useEffect(() => {
    try {
      const raw = window.localStorage.getItem("monster8.favorite-event-map");
      if (!raw) {
        setFavoriteMapHydrated(true);
        return;
      }
      const parsed = JSON.parse(raw) as unknown;
      if (!parsed || typeof parsed !== "object") {
        setFavoriteMapHydrated(true);
        return;
      }
      const entries = Object.entries(parsed as Record<string, unknown>).map(([id, value]) => [
        id,
        normalizeFavoriteEventSnapshot(value)
      ]);
      const normalized = Object.fromEntries(
        entries.filter((entry): entry is [string, FavoriteEventSnapshot] => entry[1] !== null)
      );
      setFavoriteEventMap(normalized);
    } catch {
      // Ignore invalid local storage payloads.
    } finally {
      setFavoriteMapHydrated(true);
    }
  }, []);

  useEffect(() => {
    if (!favoriteIdsHydrated) {
      return;
    }
    window.localStorage.setItem("monster8.favorite-events", JSON.stringify(favoriteEventIds));
  }, [favoriteEventIds, favoriteIdsHydrated]);

  useEffect(() => {
    if (!favoriteMapHydrated) {
      return;
    }
    window.localStorage.setItem("monster8.favorite-event-map", JSON.stringify(favoriteEventMap));
  }, [favoriteEventMap, favoriteMapHydrated]);

  useEffect(() => {
    try {
      const raw = window.localStorage.getItem("monster8.sports-bet-history");
      if (!raw) {
        setSportsHistoryHydrated(true);
        return;
      }
      const parsed = JSON.parse(raw) as unknown;
      if (!Array.isArray(parsed)) {
        setSportsHistoryHydrated(true);
        return;
      }
      const history = parsed
        .map((item) => normalizeSportsBetHistoryRecord(item))
        .filter((item): item is SportsBetHistoryRecord => item !== null);
      setSportsBetHistory(history);
    } catch {
      // Ignore invalid local storage payloads.
    } finally {
      setSportsHistoryHydrated(true);
    }
  }, []);

  useEffect(() => {
    try {
      const raw = window.localStorage.getItem("monster8.selected-wallet-bet-id");
      if (!raw) {
        setSelectedWalletBetHydrated(true);
        return;
      }

      setSelectedWalletBetId(raw);
    } catch {
      // Ignore invalid local storage payloads.
    } finally {
      setSelectedWalletBetHydrated(true);
    }
  }, []);

  useEffect(() => {
    if (!sportsHistoryHydrated) {
      return;
    }
    window.localStorage.setItem("monster8.sports-bet-history", JSON.stringify(sportsBetHistory));
  }, [sportsBetHistory, sportsHistoryHydrated]);

  useEffect(() => {
    if (!selectedWalletBetHydrated) {
      return;
    }

    if (!selectedWalletBetId) {
      window.localStorage.removeItem("monster8.selected-wallet-bet-id");
      return;
    }

    window.localStorage.setItem("monster8.selected-wallet-bet-id", selectedWalletBetId);
  }, [selectedWalletBetHydrated, selectedWalletBetId]);

  useEffect(() => {
    const combined = buildWalletBetRecords(sportsBetHistory, bets);
    if (combined.length === 0) {
      setSelectedWalletBetId("");
      return;
    }

    if (!combined.some((record) => record.id === selectedWalletBetId)) {
      setSelectedWalletBetId("");
    }
  }, [bets, selectedWalletBetId, sportsBetHistory]);

  useEffect(() => {
    if (!activeLeague) {
      return;
    }
    void refreshSportsEvents(activeLeague);
  }, [activeLeague]);

  useEffect(() => {
    if (!activeSport) {
      return;
    }

    const visibleLeagues = leagues.filter((league) => !league.sportId || league.sportId === activeSport);
    if (visibleLeagues.length === 0) {
      const fallbackLeague = sports.find((sport) => sport.id === activeSport)?.featuredLeague;
      if (fallbackLeague) {
        setActiveLeague(fallbackLeague);
      }
      return;
    }

    if (!visibleLeagues.some((league) => league.id === activeLeague)) {
      setActiveLeague(visibleLeagues[0].id);
    }
  }, [activeLeague, activeSport, leagues, sports]);

  const visibleSports = sports.length > 0 ? sports : defaultSports;
  const visibleLeagues = leagues.filter((league) => !league.sportId || league.sportId === activeSport);
  const quickSportFilters = buildQuickSportFilters(leagues);
  const visibleEvents = events.slice(0, 12);
  const favoriteEvents = favoriteEventIds
    .map((id) => favoriteEventMap[id])
    .filter((event): event is FavoriteEventSnapshot => Boolean(event))
    .slice(0, 12);
  const featuredEvents = favoriteEvents.slice(0, 6);
  const hotNumbers = numberStats?.frequency?.slice(0, 6) ?? [];
  const recentTenDraws = drawHistory.slice(0, 10);
  const recentTopNumberRows = buildRecentTopNumberRows(recentTenDraws);
  const recentBigSmallRows = buildRecentBigSmallRows(recentTenDraws);
  const recentOddEvenRows = buildRecentOddEvenRows(recentTenDraws);
  const walletBetRecords = buildWalletBetRecords(sportsBetHistory, bets);
  const selectedWalletBet = walletBetRecords.find((record) => record.id === selectedWalletBetId) ?? null;
  const latestNumbers = drawNumbers(current?.latestDraw?.numbers ?? draws[0]?.numbers ?? null);
  const requiredCount = betType.startsWith("star_") ? Number.parseInt(betType.replace("star_", ""), 10) : 0;
  const canSubmitBet = betType.startsWith("star_") ? selectedNumbers.length === requiredCount : true;
  const selectedEvent = visibleEvents.find((event) => event.id === selectedEventId) ?? visibleEvents[0] ?? null;
  const sportsStakeValue = normalizeStakeAmount(sportsStakeAmount, 500);
  const selectedEventHasScore = selectedEvent
    ? typeof selectedEvent.homeScore === "number" || typeof selectedEvent.awayScore === "number"
    : false;
  const selectedEventMarkets = selectedEvent ? buildSportMarkets(selectedEvent) : [];
  const visibleMarkets =
    selectedSportsMarket === "popular"
      ? selectedEventMarkets.filter((market) => market.id === "popular" || market.id === "moneyline")
      : selectedEventMarkets.filter((market) => market.id === selectedSportsMarket);
  const selectedDepositConfig = depositMethodConfigs.find((method) => method.id === selectedDepositMethod) ?? depositMethodConfigs[0];
  const shortcutCards = [
    {
      id: "sports",
      title: "收藏賽事",
      meta: `${favoriteEvents.length} 場`,
      description: "收藏賽事"
    },
    {
      id: "bingo",
      title: "本期 Bingo",
      meta: current?.currentRound.round_id ?? "--",
      description: `${formatCountdown(countdownValue)} 後開獎`
    },
    {
      id: "bet",
      title: "快速投注",
      meta: "25 元",
      description: "支援 1~10 星、大小、單雙"
    },
    {
      id: "wallet",
      title: "帳戶餘額",
      meta: `${wallet?.balance.toLocaleString() ?? "--"} 元`,
      description: "訪客與會員皆從 10,000 元開始"
    },
    {
      id: "history",
      title: "歷史統計",
      meta: `${drawHistory.length} 期`,
      description: "熱門號碼、大小與單雙比例"
    }
  ] as const;

  useEffect(() => {
    if (!favoriteSeeded && visibleEvents.length > 0) {
      setFavoriteEventIds(visibleEvents.slice(0, 3).map((event) => event.id));
      setFavoriteEventMap((currentMap) => ({
        ...currentMap,
        ...Object.fromEntries(visibleEvents.slice(0, 3).map((event) => [event.id, { ...event, savedAt: new Date().toISOString() }]))
      }));
      setFavoriteSeeded(true);
    }
  }, [favoriteSeeded, visibleEvents]);

  useEffect(() => {
    if (visibleEvents.length === 0 || favoriteEventIds.length === 0) {
      return;
    }

    setFavoriteEventMap((currentMap) => {
      const visibleFavoriteEntries = visibleEvents
        .filter((event) => favoriteEventIds.includes(event.id))
        .map((event) => [event.id, { ...event, savedAt: currentMap[event.id]?.savedAt ?? new Date().toISOString() }] as const);

      if (visibleFavoriteEntries.length === 0) {
        return currentMap;
      }

      let changed = false;
      const nextMap = { ...currentMap };
      for (const [id, snapshot] of visibleFavoriteEntries) {
        const currentSnapshot = currentMap[id];
        if (!currentSnapshot || JSON.stringify(currentSnapshot) !== JSON.stringify(snapshot)) {
          nextMap[id] = snapshot;
          changed = true;
        }
      }
      return changed ? nextMap : currentMap;
    });
  }, [favoriteEventIds, visibleEvents]);

  useEffect(() => {
    if (visibleEvents.length === 0) {
      setSelectedEventId("");
      return;
    }

    if (!visibleEvents.some((event) => event.id === selectedEventId)) {
      selectEvent(visibleEvents[0]);
    }
  }, [selectedEventId, visibleEvents]);

  useEffect(() => {
    if (!selectedSportsDraft) {
      return;
    }

    setSelectedSportsDraft((currentDraft) => {
      if (!currentDraft) {
        return currentDraft;
      }

      const decimalOdds = Number.parseFloat(currentDraft.oddsLabel);
      const potentialPayout = Number.isFinite(decimalOdds) ? Math.round(sportsStakeValue * decimalOdds) : sportsStakeValue;

      if (currentDraft.amount === sportsStakeValue && currentDraft.potentialPayout === potentialPayout) {
        return currentDraft;
      }

      return {
        ...currentDraft,
        amount: sportsStakeValue,
        potentialPayout
      };
    });
  }, [selectedSportsDraft, sportsStakeValue]);

  async function refreshDashboard(silent = false): Promise<void> {
    if (!silent) {
      setLoading(true);
    }
    const results = await Promise.allSettled([
      apiRequest<{ actor: Actor }>("/api/viewer"),
      apiRequest<WalletBalance>("/api/wallet/balance"),
      apiRequest<{ transactions: WalletTransaction[] }>("/api/wallet/transactions?page=1&pageSize=10"),
      apiRequest<CurrentState>("/api/bingo/current"),
      apiRequest<{ draws: DrawRound[] }>("/api/bingo/draws/latest?limit=6"),
      apiRequest<{ draws: DrawRound[] }>("/api/bingo/draws/history?page=1&pageSize=10"),
      apiRequest<{ bets: BetRecord[] }>("/api/bingo/bets/me?page=1&pageSize=10"),
      apiRequest<DrawStats>("/api/bingo/stats/numbers?limit=120"),
      apiRequest<DrawStats>("/api/bingo/stats/big-small?limit=120"),
      apiRequest<DrawStats>("/api/bingo/stats/odd-even?limit=120")
    ]);

    if (results[0].status === "fulfilled") {
      setViewer(results[0].value.actor);
    }
    if (results[1].status === "fulfilled") {
      setWallet(results[1].value);
    }
    if (results[2].status === "fulfilled") {
      setTransactions(results[2].value.transactions);
    }
    if (results[3].status === "fulfilled") {
      setCurrent(results[3].value);
    }
    if (results[4].status === "fulfilled") {
      setDraws(results[4].value.draws);
    }
    if (results[5].status === "fulfilled") {
      setDrawHistory(results[5].value.draws);
    }
    if (results[6].status === "fulfilled") {
      setBets(results[6].value.bets);
    }
    if (results[7].status === "fulfilled") {
      setNumberStats(results[7].value);
    }
    if (results[8].status === "fulfilled") {
      setBigSmallStats(results[8].value);
    }
    if (results[9].status === "fulfilled") {
      setOddEvenStats(results[9].value);
    }
    if (!silent) {
      setLoading(false);
    }
  }

  async function refreshSportsDirectory(): Promise<void> {
    setSportsLoading(true);
    const results = await Promise.allSettled([apiRequest<unknown>("/api/sports"), apiRequest<unknown>("/api/leagues")]);

    if (results[0].status === "fulfilled") {
      const normalized = normalizeSports(results[0].value);
      setSports(normalized.length > 0 ? normalized : defaultSports);
      if (!activeSport) {
        setActiveSport((normalized[0] ?? defaultSports[0]).id);
      }
      setSportsError("");
    } else {
      setSports(defaultSports);
      setActiveSport((currentSport) => currentSport || defaultSports[0].id);
      setSportsError(results[0].reason instanceof Error ? results[0].reason.message : "Sports 服務暫時不可用");
    }

    if (results[1].status === "fulfilled") {
      setLeagues(normalizeLeagues(results[1].value));
    } else {
      setLeagues([
        { id: "NBA", label: "NBA", sportId: "basketball" },
        { id: "NFL", label: "NFL", sportId: "football" },
        { id: "MLB", label: "MLB", sportId: "baseball" }
      ]);
    }

    setSportsLoading(false);
  }

  async function refreshSportsEvents(leagueId: string): Promise<void> {
    try {
      const startsAfter = getSportsStartsAfter();
      const response = await apiRequest<unknown>(
        `/api/events?leagueID=${encodeURIComponent(leagueId)}&limit=24&oddsAvailable=true&startsAfter=${encodeURIComponent(startsAfter)}`
      );
      setEvents(normalizeEvents(response, leagues));
      setSportsError("");
    } catch (error) {
      setEvents([]);
      setSportsError(error instanceof Error ? error.message : "無法取得賽事資料");
    }
  }

  async function refreshAll(): Promise<void> {
    setFeedback("");
    await Promise.all([refreshDashboard(), refreshSportsDirectory()]);
  }

  function applyQuickFilter(filter: QuickSportFilter): void {
    setActiveSport(filter.sportId);
    if (filter.leagueId) {
      setActiveLeague(filter.leagueId);
    }
    setSelectedSportsPick("");
    setTab("sports");
  }

  function isQuickFilterActive(filter: QuickSportFilter): boolean {
    if (filter.leagueId) {
      return activeLeague === filter.leagueId;
    }
    return activeSport === filter.sportId;
  }

  function toggleFavoriteEvent(event: EventRecord): void {
    setFavoriteEventIds((currentIds) =>
      currentIds.includes(event.id) ? currentIds.filter((id) => id !== event.id) : [...currentIds, event.id]
    );
    setFavoriteEventMap((currentMap) => {
      if (currentMap[event.id]) {
        const { [event.id]: _removed, ...rest } = currentMap;
        return rest;
      }

      return {
        ...currentMap,
        [event.id]: { ...event, savedAt: new Date().toISOString() }
      };
    });
  }

  function selectEvent(event: EventRecord): void {
    setSelectedEventId(event.id);
    setSelectedSportsMarket("popular");
    const autoMarkets = buildSportMarkets(event);
    const defaultMarket = autoMarkets.find((market) => market.id === "popular") ?? autoMarkets[0];
    const defaultOption = defaultMarket?.options[0];
    if (defaultMarket && defaultOption) {
      selectSportsPick(event, defaultMarket, defaultOption);
    } else {
      setSelectedSportsPickId("");
      setSelectedSportsPick("");
    }
  }

  function selectSportsPick(event: EventRecord, market: SportMarket, option: SportMarketOption): void {
    setSelectedSportsPickId(option.id);
    const matchup = `${event.homeTeam} vs ${event.awayTeam}`;
    const pickLabel = `${option.label}${option.line ? ` ${option.line}` : ""}`;
    const amount = sportsStakeValue;
    const decimalOdds = Number.parseFloat(option.odds);
    setSelectedSportsPick(`${matchup} / ${market.label} / ${pickLabel} @ ${option.odds}`);
    setSelectedSportsDraft({
      id: `${event.id}-${option.id}-${Date.now()}`,
      ticketNo: createTicketNo("SP"),
      eventId: event.id,
      sportLabel: resolveSportLabel(event, visibleSports, activeSport),
      leagueLabel: event.leagueLabel,
      homeTeam: event.homeTeam,
      awayTeam: event.awayTeam,
      matchup,
      marketLabel: market.label,
      pickLabel,
      oddsLabel: option.odds,
      amount,
      potentialPayout: Number.isFinite(decimalOdds) ? Math.round(amount * decimalOdds) : amount,
      eventTime: event.commenceTime,
      createdAt: new Date().toISOString(),
      status: "pending",
      homeScore: event.homeScore,
      awayScore: event.awayScore,
      eventStatus: event.status
    });
  }

  function adjustSportsStake(delta: number): void {
    setSportsStakeAmount(String(Math.max(50, sportsStakeValue + delta)));
  }

  function toggleNumber(value: number): void {
    if (!betType.startsWith("star_")) {
      return;
    }

    setSelectedNumbers((currentNumbers) => {
      if (currentNumbers.includes(value)) {
        return currentNumbers.filter((item) => item !== value);
      }

      if (currentNumbers.length >= requiredCount) {
        return [...currentNumbers.slice(1), value].sort((left, right) => left - right);
      }

      return [...currentNumbers, value].sort((left, right) => left - right);
    });
  }

  async function submitBet(event: FormEvent<HTMLFormElement>): Promise<void> {
    event.preventDefault();
    setFeedback("");

    try {
      await apiRequest("/api/bingo/bet", {
        method: "POST",
        body: JSON.stringify({
          roundId: current?.currentRound.round_id,
          betType,
          amount: 25,
          selectedNumbers: betType.startsWith("star_") ? selectedNumbers : undefined,
          selectedOption: betType === "big_small" || betType === "odd_even" ? selectedOption : undefined
        })
      });
      setFeedback("投注成功，畫面已同步更新。");
      setSelectedNumbers([]);
      await refreshDashboard();
      setTab("history");
    } catch (error) {
      setFeedback(error instanceof Error ? error.message : "投注失敗");
    }
  }

  async function submitDeposit(event: FormEvent<HTMLFormElement>): Promise<void> {
    event.preventDefault();
    setFeedback("");

    try {
      await apiRequest("/api/wallet/deposit", {
        method: "POST",
        body: JSON.stringify({ amount: Number.parseInt(depositAmount, 10) })
      });
      setFeedback(`已透過 ${selectedDepositConfig.label} 模擬入金 ${Number.parseInt(depositAmount, 10).toLocaleString()} 元。`);
      await refreshDashboard();
    } catch (error) {
      setFeedback(error instanceof Error ? error.message : "儲值失敗");
    }
  }

  return (
    <div className="dashboard-shell">
      <header className="top-header">
        <div className="brand-block">
          <img alt="Velocabet" className="brand-wordmark brand-wordmark-header" src="/brand-wordmark.svg" />
        </div>
        <nav className="header-nav">
          {tabs.map((item) => (
            <button
              key={item.id}
              className={item.id === tab ? "header-tab active" : "header-tab"}
              onClick={() => setTab(item.id)}
              type="button"
            >
              {item.label}
            </button>
          ))}
        </nav>
        <button className="header-refresh" onClick={() => void refreshAll()} type="button">
          重新整理
        </button>
      </header>

      <main className="dashboard-body">
        <section className="hero-grid">
          <div className="hero-panel">
            <div className="hero-copy">
              <img alt="Velocabet" className="brand-wordmark brand-wordmark-hero" src="/brand-wordmark.svg" />
              <p className="hero-description">
                提供公開運動賽事瀏覽、Bingo Bingo 大廳、快速下注、錢包與歷史統計，整理成一個可操作的桌面版產品面板。
              </p>
              <div className="hero-actions">
                <button className="primary-button" onClick={() => setTab("sports")} type="button">
                  查看賽事
                </button>
                <button className="secondary-button" onClick={() => setTab("bingo")} type="button">
                  看 Bingo 大廳
                </button>
                <button className="secondary-button" onClick={() => setTab("bet")} type="button">
                  直接下注
                </button>
              </div>
            </div>
            <div className="category-rail">
              {quickSportFilters.map((filter) => (
                <button
                  key={filter.id}
                  className={isQuickFilterActive(filter) && tab === "sports" ? "category-chip active" : "category-chip"}
                  onClick={() => applyQuickFilter(filter)}
                  type="button"
                >
                  <span className="category-icon">
                    <SportGlyph filterId={filter.id} />
                  </span>
                  <span>{filter.label}</span>
                </button>
              ))}
            </div>
          </div>

          <aside className="status-panel">
            <InfoCell label="API" value={API_BASE_URL} />
            <InfoCell label="身份" value={viewer ? `${viewer.type} / ${viewer.id}` : "載入中"} />
            <InfoCell label="餘額" value={wallet ? `${wallet.balance.toLocaleString()} 元` : "載入中"} emphasis />
            <InfoCell label="下一期" value={current?.currentRound.round_id ?? "--"} />
            <InfoCell label="截止時間" value={current ? formatDateTime(current.cutoffAt) : "--"} />
          </aside>
        </section>

        {feedback ? <div className="notice success">{feedback}</div> : null}
        {sportsError ? <div className="notice warning">{sportsError}</div> : null}

        <section className="shortcut-grid">
          {shortcutCards.map((card) => (
            <button key={card.id} className="shortcut-card" onClick={() => setTab(card.id)} type="button">
              <span className={`shortcut-badge ${card.id}`}>
                <ShortcutGlyph cardId={card.id} />
              </span>
              <strong>{card.title}</strong>
              <span>{card.description}</span>
              <em>{card.meta}</em>
            </button>
          ))}
        </section>

        {!loading && tab === "overview" ? (
          <>
            <section className="content-grid overview-grid">
              <article className="panel">
                <div className="section-header">
                  <div>
                    <h2>收藏的賽事</h2>
                    <span>{sportsLoading ? "載入賽事中..." : `${favoriteEvents.length} 場已收藏`}</span>
                  </div>
                  <button className="text-link" onClick={() => setTab("sports")} type="button">
                    管理賽事
                  </button>
                </div>
                <div className="compact-pills">
                  {quickSportFilters.map((filter) => (
                    <button
                      key={filter.id}
                      className={isQuickFilterActive(filter) ? "compact-pill active" : "compact-pill"}
                      onClick={() => applyQuickFilter(filter)}
                      type="button"
                    >
                      {filter.label}
                    </button>
                  ))}
                </div>
                <div className="event-grid three-columns">
                  {featuredEvents.map((event) => (
                    <EventCard
                      key={event.id}
                      event={event}
                      favorited={favoriteEventIds.includes(event.id)}
                      selected={selectedEvent?.id === event.id}
                      onSelect={(clickedEvent) => {
                        if (clickedEvent.sportId) {
                          setActiveSport(clickedEvent.sportId);
                        }
                        setActiveLeague(clickedEvent.leagueId);
                        selectEvent(clickedEvent);
                        setTab("sports");
                      }}
                      onToggleFavorite={toggleFavoriteEvent}
                    />
                  ))}
                </div>
                {featuredEvents.length === 0 ? <div className="empty-state">目前沒有收藏賽事，先到 Sports 點星號收藏。</div> : null}
              </article>

              <article className="panel bingo-panel">
                <div className="section-header">
                  <div>
                    <h2>Bingo Bingo 大廳</h2>
                    <span>當期 {current?.currentRound.round_id ?? "--"}</span>
                  </div>
                  <button className="text-link" onClick={() => setTab("bet")} type="button">
                    Quick Bet
                  </button>
                </div>
                <div className="countdown-panel">
                  <span>距離下一次開獎</span>
                  <strong>{formatCountdown(countdownValue)}</strong>
                  <small>{current ? formatDateTime(current.currentRound.draw_time) : "--"}</small>
                </div>
                <div className="draw-summary-card">
                  <div className="draw-summary-header">
                    <strong>上期號碼</strong>
                    <span>{current?.latestDraw?.round_id ?? draws[0]?.round_id ?? "--"}</span>
                  </div>
                  <BallGroup numbers={latestNumbers} superNumber={current?.latestDraw?.super_number ?? draws[0]?.super_number ?? null} />
                </div>
                <div className="stat-inline-grid">
                  <StatMiniCard label="熱門號碼" value={hotNumbers.length > 0 ? hotNumbers.map((item) => item.number).join(" / ") : "--"} />
                  <StatMiniCard
                    label="大小比例"
                    value={bigSmallStats?.bigSmall ? `${bigSmallStats.bigSmall.big}:${bigSmallStats.bigSmall.small}` : "--"}
                  />
                  <StatMiniCard
                    label="單雙比例"
                    value={oddEvenStats?.oddEven ? `${oddEvenStats.oddEven.odd}:${oddEvenStats.oddEven.even}` : "--"}
                  />
                </div>
              </article>
            </section>

            <section className="content-grid side-by-side">
              <article className="panel">
                <div className="section-header">
                  <div>
                    <h2>平台重點</h2>
                    <span>快速掌握目前站內資訊</span>
                  </div>
                </div>
                <ul className="rule-list">
                  <li>Sports 目前提供 NBA、足球、棒球、NHL 的公開賽事與盤口瀏覽。</li>
                  <li>首次進站可先使用 10,000 元體驗金，方便直接試玩 Sports 與 Bingo。</li>
                  <li>Bingo Bingo 每 5 分鐘固定開獎，歷史統計會持續累積更新。</li>
                  <li>最近投注會整合 Sports 與 Bingo，方便查看每筆輸贏結果。</li>
                  <li>收藏賽事支援跨球類整理，常用對戰可以直接保留在首頁。</li>
                </ul>
              </article>

              <article className="panel">
                <div className="section-header">
                  <div>
                    <h2>近期投注</h2>
                    <span>{bets.length} 筆資料</span>
                  </div>
                  <button className="text-link" onClick={() => setTab("history")} type="button">
                    看全部
                  </button>
                </div>
                <div className="list-stack">
                  {bets.slice(0, 5).map((bet) => (
                    <div key={bet.id} className="list-row">
                      <div>
                        <strong>{bet.bet_type}</strong>
                        <span>
                          {bet.round_id} / {formatDateTime(bet.created_at)}
                        </span>
                      </div>
                      <div className="row-meta">
                        <em>{bet.amount} 元</em>
                        <span className={bet.payout > 0 ? "gain" : "muted"}>{bet.payout > 0 ? `+${bet.payout}` : bet.status}</span>
                      </div>
                    </div>
                  ))}
                  {bets.length === 0 ? <div className="empty-state">目前還沒有投注紀錄。</div> : null}
                </div>
              </article>
            </section>
          </>
        ) : null}

        {!loading && tab === "sports" ? (
          <section className="panel">
            <div className="section-header">
              <div>
                <h2>Sports</h2>
                <span>{sportsLoading ? "載入中..." : `${visibleEvents.length} 場賽事 / ${activeLeague || "未指定聯盟"}`}</span>
              </div>
            </div>
            <div className="sports-toolbar">
              <div className="category-row">
                {quickSportFilters.map((filter) => (
                  <button
                    key={filter.id}
                    className={isQuickFilterActive(filter) ? "sports-chip active" : "sports-chip"}
                    onClick={() => applyQuickFilter(filter)}
                    type="button"
                  >
                    <span className="sports-chip-icon">
                      <SportGlyph filterId={filter.id} compact />
                    </span>
                    <span>{filter.label}</span>
                  </button>
                ))}
              </div>
              <label className="league-control">
                <span>聯盟</span>
                <select value={activeLeague} onChange={(event) => setActiveLeague(event.target.value)}>
                  {visibleLeagues.map((league) => (
                    <option key={league.id} value={league.id}>
                      {league.label}
                    </option>
                  ))}
                </select>
              </label>
            </div>
            <div className="sports-content-grid">
              <div className="event-grid three-columns">
                {visibleEvents.map((event) => (
                  <EventCard
                    key={event.id}
                    event={event}
                    favorited={favoriteEventIds.includes(event.id)}
                    selected={selectedEvent?.id === event.id}
                    onSelect={selectEvent}
                    onToggleFavorite={toggleFavoriteEvent}
                  />
                ))}
                {visibleEvents.length === 0 ? <div className="empty-state">目前沒有可顯示的聯盟賽事。</div> : null}
              </div>

              <aside className="betting-panel">
                {selectedEvent ? (
                  <>
                    <div className="betting-panel-header">
                      <div>
                        <span className="league-badge">{selectedEvent.leagueLabel}</span>
                        <span className="betting-date">{formatDateTime(selectedEvent.commenceTime)}</span>
                        <div className="betting-matchup-copy">
                          <TeamLabel name={selectedEvent.homeTeam} prominent />
                          <p>vs</p>
                          <TeamLabel name={selectedEvent.awayTeam} prominent />
                        </div>
                      </div>
                      {selectedEventHasScore ? (
                        <div className="betting-score">
                          <strong>
                            {selectedEvent.homeScore ?? "-"} : {selectedEvent.awayScore ?? "-"}
                          </strong>
                        </div>
                      ) : null}
                    </div>

                    <div className="market-tabs">
                      {[
                        { id: "popular", label: "熱門" },
                        { id: "moneyline", label: "獲勝隊" },
                        { id: "spread", label: "讓分盤" },
                        { id: "total", label: "總分盤" }
                      ].map((market) => (
                        <button
                          key={market.id}
                          className={selectedSportsMarket === market.id ? "market-tab active" : "market-tab"}
                          onClick={() => setSelectedSportsMarket(market.id as SportMarket["id"])}
                          type="button"
                        >
                          {market.label}
                        </button>
                      ))}
                    </div>

                    <div className="market-stack">
                      {visibleMarkets.map((market) => (
                        <section key={market.id} className="market-group">
                          <div className="market-group-header">
                            <strong>{market.label}</strong>
                          </div>
                          <div className="market-options">
                            {market.options.map((option) => (
                              <button
                                key={option.id}
                                className={selectedSportsPickId === option.id ? "market-option active" : "market-option"}
                                onClick={() => selectSportsPick(selectedEvent, market, option)}
                                type="button"
                              >
                                <span>{option.label}</span>
                                <strong>{option.line ?? option.odds}</strong>
                                <em>{option.line ? option.odds : "可投注"}</em>
                              </button>
                            ))}
                          </div>
                        </section>
                      ))}
                    </div>

                    <div className="sports-pick-preview">
                      <strong>已選盤口</strong>
                      <span>{selectedSportsPick || "請先從左側賽事卡或上方盤口中挑一個投注選項。"}</span>
                      <div className="sports-stake-sheet">
                        <div className="sports-stake-summary">
                          <span>投注金額</span>
                          <strong>{sportsStakeValue.toLocaleString()} 元</strong>
                        </div>
                        <div className="sports-stake-controls">
                          <button className="stake-adjust-button" onClick={() => adjustSportsStake(-50)} type="button">
                            −
                          </button>
                          <input
                            inputMode="numeric"
                            onChange={(event) => setSportsStakeAmount(event.target.value.replace(/[^\d]/g, ""))}
                            placeholder="請輸入投注金額"
                            type="text"
                            value={sportsStakeAmount}
                          />
                          <button className="stake-adjust-button" onClick={() => adjustSportsStake(50)} type="button">
                            +
                          </button>
                        </div>
                        <div className="sports-stake-shortcuts">
                          {[150, 300, 500, 1000].map((amount) => (
                            <button
                              key={amount}
                              className={sportsStakeValue === amount ? "stake-chip active" : "stake-chip"}
                              onClick={() => setSportsStakeAmount(String(amount))}
                              type="button"
                            >
                              {amount} 元
                            </button>
                          ))}
                        </div>
                        <div className="sports-stake-summary muted">
                          <span>預估返還</span>
                          <strong>
                            {selectedSportsDraft ? `${selectedSportsDraft.potentialPayout.toLocaleString()} 元` : "--"}
                          </strong>
                        </div>
                      </div>
                      <button
                        className="primary-button sports-submit-button"
                        onClick={() => {
                          if (!selectedSportsPick) {
                            setFeedback("請先挑選一個運動賽事盤口。");
                            return;
                          }
                          setFeedback(`已選擇盤口：${selectedSportsPick}`);
                          if (!selectedSportsDraft) {
                            return;
                          }
                          const finalizedRecord: SportsBetHistoryRecord = {
                            ...selectedSportsDraft,
                            id: `${selectedSportsDraft.eventId}-${Date.now()}`,
                            ticketNo: createTicketNo("SP"),
                            createdAt: new Date().toISOString()
                          };
                          setSportsBetHistory((currentHistory) => [finalizedRecord, ...currentHistory].slice(0, 30));
                          setSelectedWalletBetId(`sports-${finalizedRecord.id}`);
                          setFeedback(`已加入最近投注：${selectedSportsPick}`);
                          setTab("wallet");
                        }}
                        disabled={!selectedSportsPick}
                        type="button"
                      >
                        投注
                      </button>
                    </div>
                  </>
                ) : (
                  <div className="empty-state">請先選擇一場賽事。</div>
                )}
              </aside>
            </div>
          </section>
        ) : null}

        {!loading && tab === "bingo" ? (
          <section className="content-grid bingo-grid">
            <article className="panel">
              <div className="section-header">
                <div>
                  <h2>開獎大廳</h2>
                  <span>{current?.currentRound.round_id ?? "--"}</span>
                </div>
              </div>
              <div className="countdown-panel large">
                <span>距離當期開獎</span>
                <strong>{formatCountdown(countdownValue)}</strong>
                <small>截止 {current ? formatDateTime(current.cutoffAt) : "--"}</small>
              </div>
              <div className="draw-summary-card spacious">
                <div className="draw-summary-header">
                  <strong>最新期數</strong>
                  <span>{current?.latestDraw?.round_id ?? "--"}</span>
                </div>
                <BallGroup numbers={latestNumbers} superNumber={current?.latestDraw?.super_number ?? null} />
              </div>
            </article>

            <article className="panel">
              <div className="section-header">
                <div>
                  <h2>最近開獎</h2>
                  <span>近 {draws.length} 期</span>
                </div>
              </div>
              <div className="list-stack">
                {draws.map((draw) => (
                  <div key={draw.round_id} className="draw-row">
                    <div>
                      <strong>{draw.round_id}</strong>
                      <span>{formatDateTime(draw.draw_time)}</span>
                    </div>
                    <BallGroup numbers={drawNumbers(draw.numbers).slice(0, 8)} superNumber={draw.super_number} compact />
                  </div>
                ))}
              </div>
            </article>
          </section>
        ) : null}

        {!loading && tab === "bet" ? (
          <section className="content-grid bet-grid">
            <article className="panel">
              <div className="section-header">
                <div>
                  <h2>立即投注</h2>
                  <span>當期 {current?.currentRound.round_id ?? "--"} / 單注 25 元</span>
                </div>
              </div>
              <form className="bet-form" onSubmit={(event) => void submitBet(event)}>
                <div className="bet-toolbar">
                  <label className="field-block">
                    <span>玩法</span>
                    <select
                      value={betType}
                      onChange={(event) => {
                        setBetType(event.target.value);
                        setSelectedNumbers([]);
                      }}
                    >
                      {Array.from({ length: 10 }, (_, index) => (
                        <option key={index + 1} value={`star_${index + 1}`}>
                          {index + 1} 星
                        </option>
                      ))}
                      <option value="big_small">猜大小</option>
                      <option value="odd_even">猜單雙</option>
                    </select>
                  </label>

                  {(betType === "big_small" || betType === "odd_even") ? (
                    <label className="field-block">
                      <span>選項</span>
                      <select value={selectedOption} onChange={(event) => setSelectedOption(event.target.value)}>
                        {betType === "big_small" ? (
                          <>
                            <option value="big">大</option>
                            <option value="small">小</option>
                          </>
                        ) : (
                          <>
                            <option value="odd">單</option>
                            <option value="even">雙</option>
                          </>
                        )}
                      </select>
                    </label>
                  ) : (
                    <div className="selection-summary">
                      <span>已選號碼</span>
                      <strong>{selectedNumbers.length}</strong>
                      <small>需選 {requiredCount} 個</small>
                    </div>
                  )}

                  <div className="selection-summary highlight">
                    <span>餘額</span>
                    <strong>{wallet ? wallet.balance.toLocaleString() : "--"}</strong>
                    <small>每次下注固定 25 元</small>
                  </div>
                </div>

                {betType.startsWith("star_") ? (
                  <div className="number-grid">
                    {numberGrid.map((value) => (
                      <button
                        key={value}
                        className={selectedNumbers.includes(value) ? "number-cell active" : "number-cell"}
                        onClick={() => toggleNumber(value)}
                        type="button"
                      >
                        {value}
                      </button>
                    ))}
                  </div>
                ) : (
                  <div className="option-grid">
                    <button
                      className={selectedOption === (betType === "big_small" ? "big" : "odd") ? "option-cell active" : "option-cell"}
                      onClick={() => setSelectedOption(betType === "big_small" ? "big" : "odd")}
                      type="button"
                    >
                      {betType === "big_small" ? "大" : "單"}
                    </button>
                    <button
                      className={selectedOption === (betType === "big_small" ? "small" : "even") ? "option-cell active" : "option-cell"}
                      onClick={() => setSelectedOption(betType === "big_small" ? "small" : "even")}
                      type="button"
                    >
                      {betType === "big_small" ? "小" : "雙"}
                    </button>
                  </div>
                )}

                <div className="action-row">
                  <button className="primary-button" disabled={!canSubmitBet} type="submit">
                    送出投注
                  </button>
                </div>
              </form>
            </article>

            <article className="panel">
              <div className="section-header">
                <div>
                  <h2>投注摘要</h2>
                  <span>本期下注狀態</span>
                </div>
              </div>
              <div className="summary-stack">
                <SummaryCell label="當期" value={current?.currentRound.round_id ?? "--"} />
                <SummaryCell label="玩法" value={betType.replace("_", " / ")} />
                <SummaryCell
                  label="選號 / 選項"
                  value={betType.startsWith("star_") ? (selectedNumbers.length > 0 ? selectedNumbers.join(", ") : "尚未選號") : selectedOption}
                />
                <SummaryCell label="單注金額" value="25 元" />
                <SummaryCell label="Sports 盤口" value={selectedSportsPick || "尚未加入 Sports 盤口"} />
              </div>
            </article>
          </section>
        ) : null}

        {!loading && tab === "wallet" ? (
          <section className="content-grid wallet-grid">
            <article className="panel">
              <div className="section-header">
                <div>
                  <h2>錢包</h2>
                  <span>{viewer ? `${viewer.type} / ${viewer.id}` : "--"}</span>
                </div>
              </div>
              <div className="balance-card">
                <span>目前餘額</span>
                <strong>{wallet ? `${wallet.balance.toLocaleString()} 元` : "--"}</strong>
                <small>訪客與會員皆會先得到 10,000 元試玩金</small>
              </div>
              <div className="deposit-method-grid">
                {depositMethodConfigs.map((method) => (
                  <button
                    key={method.id}
                    className={selectedDepositMethod === method.id ? "deposit-method-card active" : "deposit-method-card"}
                    onClick={() => setSelectedDepositMethod(method.id)}
                    type="button"
                  >
                    <span className={`deposit-method-icon ${method.id}`}>
                      <DepositMethodGlyph method={method.id} />
                    </span>
                    <div className="deposit-method-copy">
                      <strong>{method.label}</strong>
                      <span>{method.hint}</span>
                      <small>{method.meta}</small>
                    </div>
                  </button>
                ))}
              </div>
              <div className="deposit-method-panel">
                <div className="deposit-method-panel-copy">
                  <strong>{selectedDepositConfig.label}</strong>
                  <span>{selectedDepositConfig.summary}</span>
                </div>
                <div className="deposit-method-details">
                  {selectedDepositConfig.details.map((row) => (
                    <div key={`${selectedDepositConfig.id}-${row.label}`} className="deposit-detail-chip">
                      <span>{row.label}</span>
                      <strong>{row.value}</strong>
                    </div>
                  ))}
                </div>
              </div>
              <form className="deposit-form" onSubmit={(event) => void submitDeposit(event)}>
                <label className="field-block full-width">
                  <span>{selectedDepositConfig.label} 入金金額</span>
                  <input
                    value={depositAmount}
                    onChange={(event) => setDepositAmount(event.target.value)}
                    inputMode="numeric"
                    placeholder="整數金額"
                  />
                </label>
                <div className="deposit-quick-row">
                  {[1000, 3000, 5000, 10000].map((amount) => (
                    <button
                      key={amount}
                      className={depositAmount === String(amount) ? "deposit-quick-chip active" : "deposit-quick-chip"}
                      onClick={() => setDepositAmount(String(amount))}
                      type="button"
                    >
                      {amount.toLocaleString()} 元
                    </button>
                  ))}
                </div>
                <button className="primary-button" type="submit">
                  立即入金
                </button>
              </form>
            </article>

            <article className="panel">
              <div className="section-header">
                <div>
                  <h2>最近投注</h2>
                  <span>Sports 與 Bingo 輸贏列表</span>
                </div>
              </div>
              <div className="list-stack bet-record-stack">
                {walletBetRecords.map((record) => (
                  <div key={record.id} className={record.id === selectedWalletBet?.id ? "bet-record-item active" : "bet-record-item"}>
                    <button
                      className="bet-record-row"
                      onClick={() => setSelectedWalletBetId((currentId) => (currentId === record.id ? "" : record.id))}
                      type="button"
                    >
                      <div className="bet-record-main">
                        <span className={`bet-source-chip ${record.source}`}>{record.source === "sports" ? "Sports" : "Bingo"}</span>
                        <div>
                          <strong>{record.title}</strong>
                          <span>
                            {record.subtitle} / {formatDateTime(record.createdAt)}
                          </span>
                        </div>
                      </div>
                      <div className="row-meta">
                        <strong>{record.amount} 元</strong>
                        <span className={statusToneClass(record.status)}>{record.statusLabel}</span>
                      </div>
                    </button>

                    {record.id === selectedWalletBet?.id ? (
                      <div className="bet-record-expand">
                        <span className="bet-detail-kicker">{record.category}</span>
                        <div className="bet-detail-grid">
                          {record.detailRows.map((row) => (
                            <div key={`${record.id}-${row.label}`} className="bet-detail-cell">
                              <span>{row.label}</span>
                              <strong>{row.value}</strong>
                            </div>
                          ))}
                        </div>

                        <div className="bet-detail-footer">
                          <span>下注時間：{formatDateTime(record.createdAt)}</span>
                          <strong>
                            {record.payout !== null ? `本次返還 ${record.payout} 元` : "尚未結算，結果會在賽事或開獎完成後更新"}
                          </strong>
                        </div>
                      </div>
                    ) : null}
                  </div>
                ))}
                {walletBetRecords.length === 0 ? <div className="empty-state">目前沒有投注紀錄，先到 Sports 或 Bingo 下單。</div> : null}
              </div>
            </article>
          </section>
        ) : null}

        {!loading && tab === "history" ? (
          <>
            <section className="stats-grid">
              <ProgressStatCard title="近 10 期熱號排行" subtitle="最近 10 次開獎中最常出現的號碼" items={recentTopNumberRows} />
              <ProgressStatCard title="近 10 期大小比例" subtitle="以每期結果統計大 / 小 / 和局佔比" items={recentBigSmallRows} />
              <ProgressStatCard title="近 10 期單雙比例" subtitle="以每期結果統計單 / 雙 / 和局佔比" items={recentOddEvenRows} />
            </section>

            <section className="content-grid side-by-side">
              <article className="panel">
                <div className="section-header">
                  <div>
                    <h2>開獎歷史</h2>
                    <span>最近 {drawHistory.length} 期</span>
                  </div>
                </div>
                <div className="list-stack">
                  {drawHistory.map((draw) => (
                    <div key={draw.round_id} className="draw-row">
                      <div>
                        <strong>{draw.round_id}</strong>
                        <span>{formatDateTime(draw.draw_time)}</span>
                      </div>
                      <BallGroup numbers={drawNumbers(draw.numbers).slice(0, 8)} superNumber={draw.super_number} compact />
                    </div>
                  ))}
                </div>
              </article>

              <article className="panel">
                <div className="section-header">
                  <div>
                    <h2>投注紀錄</h2>
                    <span>最近 {walletBetRecords.length} 筆</span>
                  </div>
                </div>
                <div className="list-stack">
                  {walletBetRecords.map((record) => (
                    <div key={record.id} className="list-row">
                      <div>
                        <strong>{record.title}</strong>
                        <span>
                          {record.category} / {formatDateTime(record.createdAt)}
                        </span>
                      </div>
                      <div className="row-meta">
                        <em>{record.amount} 元</em>
                        <span className={statusToneClass(record.status)}>{record.statusLabel}</span>
                      </div>
                    </div>
                  ))}
                  {walletBetRecords.length === 0 ? <div className="empty-state">目前還沒有投注紀錄。</div> : null}
                </div>
              </article>
            </section>
          </>
        ) : null}
      </main>
    </div>
  );
}

function normalizeSports(payload: unknown): SportRecord[] {
  const rows = unwrapSportsApiList(payload);
  if (!rows) {
    return [];
  }

  const normalized: SportRecord[] = [];
  for (const item of rows) {
    const record = item as Record<string, unknown>;
    const id = String(record.sportID ?? record.id ?? record.name ?? "");
    const label = String(record.name ?? record.label ?? record.sportID ?? "");
    if (!id || !label) {
      continue;
    }
    normalized.push({
      id,
      label,
      featuredLeague: record.featuredLeague ? String(record.featuredLeague) : undefined
    });
  }
  return normalized;
}

function normalizeLeagues(payload: unknown): LeagueRecord[] {
  const rows = unwrapSportsApiList(payload);
  if (!rows) {
    return [];
  }

  const normalized: LeagueRecord[] = [];
  for (const item of rows) {
    const record = item as Record<string, unknown>;
    const id = String(record.leagueID ?? record.id ?? record.name ?? "");
    const label = String(record.longName ?? record.name ?? record.label ?? record.leagueID ?? "");
    if (!id || !label) {
      continue;
    }
    normalized.push({
      id,
      label,
      sportId: record.sportID ? String(record.sportID) : undefined
    });
  }
  return normalized;
}

function normalizeEvents(payload: unknown, leagues: LeagueRecord[]): EventRecord[] {
  const rows = unwrapSportsApiList(payload);
  if (!rows) {
    return [];
  }

  const normalized: EventRecord[] = [];
  for (const item of rows) {
    const record = item as Record<string, unknown>;
    const teams = isRecord(record.teams) ? record.teams : null;
    const home = teams && isRecord(teams.home) ? teams.home : null;
    const away = teams && isRecord(teams.away) ? teams.away : null;
    const homeNames = home && isRecord(home.names) ? home.names : null;
    const awayNames = away && isRecord(away.names) ? away.names : null;
    const homeTeam = String(
      record.homeTeam ?? record.home_team ?? record.home ?? homeNames?.long ?? homeNames?.medium ?? homeNames?.short ?? ""
    );
    const awayTeam = String(
      record.awayTeam ?? record.away_team ?? record.away ?? awayNames?.long ?? awayNames?.medium ?? awayNames?.short ?? ""
    );
    if (!homeTeam || !awayTeam) {
      continue;
    }

    const id = String(record.eventID ?? record.id ?? `${homeTeam}-${awayTeam}-${record.commenceTime ?? ""}`);
    const leagueId = String(record.leagueID ?? record.leagueId ?? record.league ?? "");
    const leagueLabel = leagues.find((league) => league.id === leagueId)?.label ?? leagueId;
    const odds = isRecord(record.odds) ? record.odds : null;
    const statusValue = normalizeEventStatus(record.status);
    const commenceTime = String(record.commenceTime ?? record.startTime ?? extractEventStartsAt(record.status) ?? record.date ?? "");

    if (statusValue === "final") {
      continue;
    }

    normalized.push({
      id,
      leagueId,
      leagueLabel,
      sportId: record.sportID ? String(record.sportID) : undefined,
      status: statusValue,
      homeTeam,
      awayTeam,
      commenceTime,
      homeScore: typeof home?.score === "number" ? home.score : undefined,
      awayScore: typeof away?.score === "number" ? away.score : undefined,
      homeMoneyline: extractAmericanOdd(odds, ["points-home-game-ml-home", "points-home-reg-ml3way-home"]),
      awayMoneyline: extractAmericanOdd(odds, ["points-away-game-ml-away", "points-away-reg-ml3way-away"]),
      homeSpread: extractMarketLine(odds, ["points-home-game-sp-home"], "spread"),
      awaySpread: extractMarketLine(odds, ["points-away-game-sp-away"], "spread"),
      homeSpreadOdds: extractAmericanOdd(odds, ["points-home-game-sp-home"]),
      awaySpreadOdds: extractAmericanOdd(odds, ["points-away-game-sp-away"]),
      totalLine: extractMarketLine(odds, ["points-all-game-ou-over", "points-all-game-ou-under"], "overUnder"),
      overOdds: extractAmericanOdd(odds, ["points-all-game-ou-over"]),
      underOdds: extractAmericanOdd(odds, ["points-all-game-ou-under"]),
      openHomeSpread: extractOpenMarketLine(odds, ["points-home-game-sp-home"], "spread"),
      openAwaySpread: extractOpenMarketLine(odds, ["points-away-game-sp-away"], "spread"),
      openTotalLine: extractOpenMarketLine(odds, ["points-all-game-ou-over", "points-all-game-ou-under"], "overUnder")
    });
  }
  return normalized;
}

function unwrapSportsApiList(payload: unknown): unknown[] | null {
  if (Array.isArray(payload)) {
    return payload;
  }

  if (!isRecord(payload)) {
    return null;
  }

  const data = payload.data;
  if (Array.isArray(data)) {
    return data;
  }

  if (isRecord(data) && Array.isArray(data.data)) {
    return data.data;
  }

  return null;
}

function isRecord(value: unknown): value is Record<string, any> {
  return typeof value === "object" && value !== null;
}

function normalizeEventStatus(value: unknown): EventRecord["status"] {
  if (value === "live" || value === "upcoming" || value === "final") {
    return value;
  }

  if (isRecord(value)) {
    if (value.completed || value.ended || value.finalized || value.cancelled) {
      return "final";
    }

    if (value.live || value.started) {
      return "live";
    }

    return "upcoming";
  }

  return "upcoming";
}

function extractEventStartsAt(value: unknown): string | null {
  if (!isRecord(value)) {
    return null;
  }

  if (typeof value.startsAt === "string") {
    return value.startsAt;
  }

  return null;
}

function extractAmericanOdd(
  odds: Record<string, unknown> | null,
  keys: string[]
): number | undefined {
  if (!odds) {
    return undefined;
  }

  for (const key of keys) {
    const row = odds[key];
    if (!isRecord(row)) {
      continue;
    }

    const preferBook = row.bookOddsAvailable === true;
    const raw = preferBook ? row.bookOdds ?? row.fairOdds : row.fairOdds ?? row.bookOdds;
    const parsed = parseNumberLike(raw);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  return undefined;
}

function extractMarketLine(
  odds: Record<string, unknown> | null,
  keys: string[],
  kind: "spread" | "overUnder"
): number | undefined {
  if (!odds) {
    return undefined;
  }

  const bookKey = kind === "spread" ? "bookSpread" : "bookOverUnder";
  const fairKey = kind === "spread" ? "fairSpread" : "fairOverUnder";

  for (const key of keys) {
    const row = odds[key];
    if (!isRecord(row)) {
      continue;
    }

    const preferBook = row.bookOddsAvailable === true;
    const primary = preferBook ? row[bookKey] : row[fairKey];
    const secondary = preferBook ? row[fairKey] : row[bookKey];
    const parsed = parseNumberLike(primary) ?? parseNumberLike(secondary);
    if (typeof parsed === "number") {
      return parsed;
    }
  }

  return undefined;
}

function extractOpenMarketLine(
  odds: Record<string, unknown> | null,
  keys: string[],
  kind: "spread" | "overUnder"
): number | undefined {
  if (!odds) {
    return undefined;
  }

  const bookKey = kind === "spread" ? "openBookSpread" : "openBookOverUnder";
  const fairKey = kind === "spread" ? "openFairSpread" : "openFairOverUnder";

  for (const key of keys) {
    const row = odds[key];
    if (!isRecord(row)) {
      continue;
    }

    const preferBook = row.bookOddsAvailable === true;
    const primary = preferBook ? row[bookKey] ?? row[fairKey] : row[fairKey] ?? row[bookKey];
    const parsed = parseNumberLike(primary);
    if (typeof parsed === "number") {
      return parsed;
    }
  }

  return undefined;
}

function parseNumberLike(value: unknown): number | undefined {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number(value.trim());
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  return undefined;
}

function normalizeSportsBetHistoryRecord(payload: unknown): SportsBetHistoryRecord | null {
  if (!payload || typeof payload !== "object") {
    return null;
  }

  const record = payload as Record<string, unknown>;
  const id = typeof record.id === "string" ? record.id : "";
  const eventId = typeof record.eventId === "string" ? record.eventId : "";
  const homeTeam = typeof record.homeTeam === "string" ? record.homeTeam : "";
  const awayTeam = typeof record.awayTeam === "string" ? record.awayTeam : "";
  const matchup =
    typeof record.matchup === "string" && record.matchup.length > 0 ? record.matchup : [homeTeam, awayTeam].filter(Boolean).join(" vs ");
  const status = record.status;

  if (!id || !eventId || !matchup) {
    return null;
  }

  if (status !== "pending" && status !== "won" && status !== "lost") {
    return null;
  }

  return {
    id,
    ticketNo: typeof record.ticketNo === "string" && record.ticketNo.length > 0 ? record.ticketNo : createTicketNo("SP"),
    eventId,
    sportLabel: typeof record.sportLabel === "string" && record.sportLabel.length > 0 ? record.sportLabel : "Sports",
    leagueLabel: typeof record.leagueLabel === "string" ? record.leagueLabel : "",
    homeTeam,
    awayTeam,
    matchup,
    marketLabel: typeof record.marketLabel === "string" && record.marketLabel.length > 0 ? record.marketLabel : "熱門",
    pickLabel: typeof record.pickLabel === "string" ? record.pickLabel : "",
    oddsLabel: typeof record.oddsLabel === "string" ? record.oddsLabel : "--",
    amount: toSafeNumber(record.amount, 25),
    potentialPayout: toSafeNumber(record.potentialPayout, 0),
    eventTime: typeof record.eventTime === "string" ? record.eventTime : "",
    createdAt: typeof record.createdAt === "string" ? record.createdAt : new Date().toISOString(),
    status,
    homeScore: typeof record.homeScore === "number" ? record.homeScore : undefined,
    awayScore: typeof record.awayScore === "number" ? record.awayScore : undefined,
    eventStatus: record.eventStatus === "live" || record.eventStatus === "upcoming" || record.eventStatus === "final" ? record.eventStatus : undefined
  };
}

function normalizeFavoriteEventSnapshot(payload: unknown): FavoriteEventSnapshot | null {
  if (!payload || typeof payload !== "object") {
    return null;
  }

  const record = payload as Record<string, unknown>;
  const id = typeof record.id === "string" ? record.id : "";
  const leagueId = typeof record.leagueId === "string" ? record.leagueId : "";
  const leagueLabel = typeof record.leagueLabel === "string" ? record.leagueLabel : "";
  const homeTeam = typeof record.homeTeam === "string" ? record.homeTeam : "";
  const awayTeam = typeof record.awayTeam === "string" ? record.awayTeam : "";
  const commenceTime = typeof record.commenceTime === "string" ? record.commenceTime : "";

  if (!id || !leagueId || !leagueLabel || !homeTeam || !awayTeam) {
    return null;
  }

  return {
    id,
    leagueId,
    leagueLabel,
    sportId: typeof record.sportId === "string" ? record.sportId : undefined,
    status: record.status === "live" || record.status === "upcoming" || record.status === "final" ? record.status : undefined,
    homeTeam,
    awayTeam,
    commenceTime,
    homeScore: typeof record.homeScore === "number" ? record.homeScore : undefined,
    awayScore: typeof record.awayScore === "number" ? record.awayScore : undefined,
    homeMoneyline: typeof record.homeMoneyline === "number" ? record.homeMoneyline : undefined,
    awayMoneyline: typeof record.awayMoneyline === "number" ? record.awayMoneyline : undefined,
    homeSpread: typeof record.homeSpread === "number" ? record.homeSpread : undefined,
    awaySpread: typeof record.awaySpread === "number" ? record.awaySpread : undefined,
    homeSpreadOdds: typeof record.homeSpreadOdds === "number" ? record.homeSpreadOdds : undefined,
    awaySpreadOdds: typeof record.awaySpreadOdds === "number" ? record.awaySpreadOdds : undefined,
    totalLine: typeof record.totalLine === "number" ? record.totalLine : undefined,
    overOdds: typeof record.overOdds === "number" ? record.overOdds : undefined,
    underOdds: typeof record.underOdds === "number" ? record.underOdds : undefined,
    openHomeSpread: typeof record.openHomeSpread === "number" ? record.openHomeSpread : undefined,
    openAwaySpread: typeof record.openAwaySpread === "number" ? record.openAwaySpread : undefined,
    openTotalLine: typeof record.openTotalLine === "number" ? record.openTotalLine : undefined,
    savedAt: typeof record.savedAt === "string" ? record.savedAt : new Date().toISOString()
  };
}

function drawNumbers(serialized?: string | null): number[] {
  if (!serialized) {
    return [];
  }

  try {
    return JSON.parse(serialized) as number[];
  } catch {
    return [];
  }
}

function formatCountdown(totalSeconds: number): string {
  const safeSeconds = Math.max(totalSeconds, 0);
  const minutes = Math.floor(safeSeconds / 60)
    .toString()
    .padStart(2, "0");
  const seconds = Math.floor(safeSeconds % 60)
    .toString()
    .padStart(2, "0");
  return `${minutes}:${seconds}`;
}

function getSportsStartsAfter(): string {
  const now = new Date();
  const startOfDay = new Date(now);
  startOfDay.setHours(0, 0, 0, 0);
  return startOfDay.toISOString();
}

function formatDateTime(value: string): string {
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat("zh-TW", {
    month: "numeric",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
    hour12: false
  }).format(parsed);
}

function formatEuropeanOdds(value: number | undefined, fallback = 1.9): string {
  return toDecimalOdds(value, fallback);
}

function buildEventMarketSnapshot(event: EventRecord | FavoriteEventSnapshot): Array<{ label: string; value: string }> {
  const openParts = [
    typeof event.openHomeSpread === "number" ? `讓分 ${formatSignedLine(event.openHomeSpread)}` : null,
    typeof event.openTotalLine === "number" ? `總分 ${formatLine(event.openTotalLine)}` : null
  ].filter((value): value is string => Boolean(value));

  const currentParts = [
    typeof event.homeSpread === "number" ? `讓分 ${formatSignedLine(event.homeSpread)}` : null,
    typeof event.totalLine === "number" ? `總分 ${formatLine(event.totalLine)}` : null
  ].filter((value): value is string => Boolean(value));

  const rows: Array<{ label: string; value: string }> = [];

  if (openParts.length > 0) {
    rows.push({ label: "初盤", value: openParts.join(" / ") });
  }

  if (currentParts.length > 0) {
    rows.push({ label: "目前", value: currentParts.join(" / ") });
  }

  return rows;
}

function buildEventMarketBrief(
  event: EventRecord | FavoriteEventSnapshot
): { homeLine: string; awayLine: string; totalLine: string } | null {
  const homeLine = typeof event.homeSpread === "number" ? formatSignedLine(event.homeSpread) : "—";
  const awayLine = typeof event.awaySpread === "number" ? formatSignedLine(event.awaySpread) : "—";
  const totalLine = typeof event.totalLine === "number" ? `大小分 ${formatLine(event.totalLine)}` : "—";

  if (homeLine === "—" && awayLine === "—" && totalLine === "—") {
    return null;
  }

  return {
    homeLine,
    awayLine,
    totalLine
  };
}

function EventCard({
  event,
  favorited,
  selected,
  onSelect,
  onToggleFavorite
}: {
  event: EventRecord | FavoriteEventSnapshot;
  favorited: boolean;
  selected: boolean;
  onSelect: (event: EventRecord) => void;
  onToggleFavorite: (event: EventRecord) => void;
}) {
  const isLive = event.status === "live" || (event.status === undefined && new Date(event.commenceTime).getTime() <= Date.now());
  const timingLabel = isLive ? "即時" : formatDateTime(event.commenceTime);
  const hasScore = typeof event.homeScore === "number" || typeof event.awayScore === "number";
  const marketBrief = buildEventMarketBrief(event);

  return (
    <article className={selected ? "event-card selected" : "event-card"} onClick={() => onSelect(event)}>
      <div className="event-card-top">
        <div className="event-card-tags">
          <span className="league-badge">{event.leagueLabel}</span>
          {isLive ? <span className="live-badge">LIVE</span> : null}
        </div>
        <button
          aria-label={favorited ? "取消收藏賽事" : "收藏賽事"}
          className={favorited ? "favorite-button active" : "favorite-button"}
          onClick={(eventObject) => {
            eventObject.stopPropagation();
            onToggleFavorite(event);
          }}
          type="button"
        >
          ★
        </button>
      </div>
      <div className={hasScore ? "event-team-stack" : "event-team-stack with-brief"}>
        <div className="event-team-copy-block">
          <div className="team-row">
            <div className="team-row-main">
              <TeamLabel name={event.homeTeam} />
            </div>
            {hasScore ? <span>{event.homeScore ?? "-"}</span> : null}
          </div>
          <div className="team-row">
            <div className="team-row-main">
              <TeamLabel name={event.awayTeam} />
            </div>
            {hasScore ? <span>{event.awayScore ?? "-"}</span> : null}
          </div>
        </div>
        {!hasScore && marketBrief ? (
          <div className="event-market-brief">
            <div className="event-market-row">
              <strong>{marketBrief.homeLine}</strong>
            </div>
            <div className="event-market-row">
              <strong>{marketBrief.awayLine}</strong>
            </div>
            <div className="event-market-total">
              <span>{marketBrief.totalLine}</span>
            </div>
          </div>
        ) : null}
      </div>
      <div className="event-card-bottom">
        <span>{timingLabel}</span>
        {(event.homeMoneyline !== undefined || event.awayMoneyline !== undefined) ? (
          <div className="odds-pills">
            <span>
              <small>主勝</small>
              <strong>{formatEuropeanOdds(event.homeMoneyline)}</strong>
            </span>
            <span>
              <small>客勝</small>
              <strong>{formatEuropeanOdds(event.awayMoneyline)}</strong>
            </span>
          </div>
        ) : null}
      </div>
    </article>
  );
}

function TeamLabel({ name, prominent }: { name: string; prominent?: boolean }) {
  const alias = getTeamAliasZhTw(name);

  if (!alias) {
    return prominent ? <strong>{name}</strong> : <strong>{name}</strong>;
  }

  return (
    <div className={prominent ? "team-copy prominent" : "team-copy"}>
      <strong>{name}</strong>
      <small>{alias}</small>
    </div>
  );
}

function SportGlyph({ filterId, compact }: { filterId: string; compact?: boolean }) {
  const size = compact ? 22 : 42;

  if (filterId === "nba") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 48 48" width={size}>
        <circle cx="24" cy="24" fill="#ff6d3d" r="17.5" />
        <path d="M24 6.8c-5.3 4.1-8.7 10.3-8.7 17.2 0 6.9 3.4 13.1 8.7 17.2" fill="none" stroke="#1a1a1a" strokeWidth="3.2" />
        <path d="M24 6.8c5.3 4.1 8.7 10.3 8.7 17.2 0 6.9-3.4 13.1-8.7 17.2" fill="none" stroke="#1a1a1a" strokeWidth="3.2" />
        <path d="M6.8 24h34.4" fill="none" stroke="#1a1a1a" strokeWidth="3.2" />
      </svg>
    );
  }

  if (filterId === "soccer") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 48 48" width={size}>
        <circle cx="24" cy="24" fill="#ffffff" r="17.5" stroke="#24384f" strokeWidth="1.8" />
        <polygon fill="#1f2430" points="24,13.2 18.5,17 20.6,23.2 27.4,23.2 29.5,17" />
        <path d="M20.6 23.2 16 29.2M27.4 23.2l4.6 6M18.5 17l-5.7 1.6M29.5 17l5.7 1.6" fill="none" stroke="#1f2430" strokeLinecap="round" strokeWidth="2.2" />
        <path d="M16 29.2 20.4 33.5M32 29.2l-4.4 4.3" fill="none" stroke="#1f2430" strokeLinecap="round" strokeWidth="2.2" />
      </svg>
    );
  }

  if (filterId === "baseball") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 48 48" width={size}>
        <circle cx="24" cy="24" fill="#ffffff" r="17.5" stroke="#dce5ef" strokeWidth="1.8" />
        <path d="M17 12.8c-2.8 3.2-4.5 7-4.5 11.2 0 4.2 1.7 8 4.5 11.2" fill="none" stroke="#d94b5a" strokeLinecap="round" strokeWidth="2.7" />
        <path d="M31 12.8c2.8 3.2 4.5 7 4.5 11.2 0 4.2-1.7 8-4.5 11.2" fill="none" stroke="#d94b5a" strokeLinecap="round" strokeWidth="2.7" />
        <path d="M16 17.5 19.3 20M15.2 22 18.8 24.7M15.8 27 19.1 29.5M32 17.5 28.7 20M32.8 22 29.2 24.7M32.2 27 28.9 29.5" fill="none" stroke="#d94b5a" strokeLinecap="round" strokeWidth="1.8" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" height={size} viewBox="0 0 48 48" width={size}>
      <rect fill="#1f2834" height="10" rx="3.3" width="18" x="15" y="23" />
      <path d="M12 18.5c4.8-5.8 10-9 15.6-9 4.1 0 7.4 1.6 10.4 5.2" fill="none" stroke="#88c6ff" strokeLinecap="round" strokeWidth="3.2" />
      <path d="M9.5 33.5h29" fill="none" stroke="#88c6ff" strokeLinecap="round" strokeWidth="2.8" />
      <circle cx="33.5" cy="17.5" fill="#ffffff" r="2.3" />
    </svg>
  );
}

function ShortcutGlyph({ cardId }: { cardId: string }) {
  const size = 22;

  if (cardId === "sports") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 28 28" width={size}>
        <path
          d="m14 4.8 2.7 5.5 6.1.9-4.4 4.3 1 6.1L14 18.7 8.6 21.6l1-6.1-4.4-4.3 6.1-.9Z"
          fill="currentColor"
        />
      </svg>
    );
  }

  if (cardId === "bingo") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 28 28" width={size}>
        <circle cx="9" cy="9" fill="none" r="4.4" stroke="currentColor" strokeWidth="2" />
        <circle cx="19" cy="9" fill="none" r="4.4" stroke="currentColor" strokeWidth="2" />
        <circle cx="9" cy="19" fill="none" r="4.4" stroke="currentColor" strokeWidth="2" />
        <circle cx="19" cy="19" fill="none" r="4.4" stroke="currentColor" strokeWidth="2" />
      </svg>
    );
  }

  if (cardId === "bet") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 28 28" width={size}>
        <path d="M7 8h14l-1.4 12H8.4L7 8Z" fill="none" stroke="currentColor" strokeLinejoin="round" strokeWidth="2" />
        <path d="M10 8a4 4 0 0 1 8 0" fill="none" stroke="currentColor" strokeWidth="2" />
        <path d="M11 13h6M14 10v6" stroke="currentColor" strokeLinecap="round" strokeWidth="2" />
      </svg>
    );
  }

  if (cardId === "wallet") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 28 28" width={size}>
        <rect fill="none" height="12" rx="3" stroke="currentColor" strokeWidth="2" width="18" x="5" y="8" />
        <path d="M8 8V6h10v2" fill="none" stroke="currentColor" strokeWidth="2" />
        <circle cx="19" cy="14" fill="currentColor" r="1.6" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" height={size} viewBox="0 0 28 28" width={size}>
      <path d="M7 21V11M14 21V7M21 21V14" fill="none" stroke="currentColor" strokeLinecap="round" strokeWidth="2.2" />
      <circle cx="7" cy="9" fill="none" r="2.6" stroke="currentColor" strokeWidth="2" />
      <circle cx="14" cy="5" fill="none" r="2.6" stroke="currentColor" strokeWidth="2" />
      <circle cx="21" cy="12" fill="none" r="2.6" stroke="currentColor" strokeWidth="2" />
    </svg>
  );
}

function DepositMethodGlyph({ method }: { method: DepositMethod }) {
  const size = 56;

  if (method === "bank") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 64 64" width={size}>
        <rect fill="#ffffff" height="64" rx="16" width="64" />
        <circle cx="32" cy="32" fill="#ffffff" r="24" stroke="#3c3c3c" strokeWidth="4" />
        <path d="M19 29.5 32 20l13 9.5" fill="#74b800" stroke="#74b800" strokeLinejoin="round" strokeWidth="2.5" />
        <path d="M22.5 29h19v13.5h-19zM26.5 31.5v10M32 31.5v10M37.5 31.5v10M20 44.5h24" fill="none" stroke="#74b800" strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" />
        <circle cx="43.5" cy="19.5" fill="#2f2f2f" r="9.5" />
        <path d="M43.5 13.8v11.4M46.8 16.8c0-1.4-1.4-2.5-3.3-2.5-1.8 0-3.2 1.1-3.2 2.5s1.4 2.4 3.2 2.4c1.9 0 3.3 1.1 3.3 2.5 0 1.4-1.4 2.5-3.3 2.5-1.8 0-3.2-1.1-3.2-2.5" fill="none" stroke="#ffffff" strokeLinecap="round" strokeWidth="2" />
      </svg>
    );
  }

  if (method === "linepay") {
    return (
      <svg aria-hidden="true" height={size} viewBox="0 0 64 64" width={size}>
        <rect fill="#ffffff" height="64" rx="16" width="64" />
        <rect fill="#26c943" height="40" rx="10" width="44" x="10" y="12" />
        <text fill="#ffffff" fontFamily="Arial, Helvetica, sans-serif" fontSize="12" fontWeight="700" textAnchor="middle" x="32" y="28">LINE</text>
        <text fill="#ffffff" fontFamily="Arial, Helvetica, sans-serif" fontSize="17" fontWeight="800" textAnchor="middle" x="32" y="44">Pay</text>
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" height={size} viewBox="0 0 64 64" width={size}>
      <rect fill="#ffffff" height="64" rx="16" width="64" />
      <circle cx="32" cy="34" fill="#1bb98b" r="22" />
      <path d="M18 21.5h28M24 21.5v7.2h16v-7.2M32 28.7v18M23.8 37.8h16.4" fill="none" stroke="#ffffff" strokeLinecap="round" strokeLinejoin="round" strokeWidth="4.8" />
      <ellipse cx="37.5" cy="34.2" fill="none" rx="10.8" ry="18.6" stroke="#ffffff" strokeWidth="2.4" transform="rotate(18 37.5 34.2)" />
    </svg>
  );
}

function BallGroup({
  numbers,
  superNumber,
  compact
}: {
  numbers: number[];
  superNumber: number | null;
  compact?: boolean;
}) {
  return (
    <div className={compact ? "ball-group compact" : "ball-group"}>
      {numbers.map((value) => (
        <span key={value} className={compact ? "ball tiny" : "ball"}>
          {value}
        </span>
      ))}
      {superNumber ? <span className={compact ? "ball super tiny" : "ball super"}>{superNumber}</span> : null}
    </div>
  );
}

function StatCard({ title, items }: { title: string; items: string[] }) {
  return (
    <article className="panel stat-card">
      <div className="section-header">
        <div>
          <h2>{title}</h2>
          <span>最近 120 期</span>
        </div>
      </div>
      <div className="stat-items">
        {items.length > 0 ? items.map((item) => <span key={item}>{item}</span>) : <span>尚無資料</span>}
      </div>
    </article>
  );
}

function ProgressStatCard({ title, subtitle, items }: { title: string; subtitle: string; items: StatBarItem[] }) {
  return (
    <article className="panel stat-card progress-card">
      <div className="section-header">
        <div>
          <h2>{title}</h2>
          <span>{subtitle}</span>
        </div>
      </div>
      <div className="progress-stack">
        {items.map((item) => (
          <div key={item.label} className="progress-row">
            <div className="progress-copy">
              <strong>{item.label}</strong>
              <span>{item.note}</span>
            </div>
            <div className="progress-track">
              <div className="progress-fill" style={{ width: `${Math.max(item.percentage, 4)}%` }} />
            </div>
            <strong className="progress-value">{item.percentage}%</strong>
          </div>
        ))}
      </div>
    </article>
  );
}

function InfoCell({ label, value, emphasis }: { label: string; value: string; emphasis?: boolean }) {
  return (
    <div className={emphasis ? "info-cell emphasis" : "info-cell"}>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

function StatMiniCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="mini-stat-card">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

function SummaryCell({ label, value }: { label: string; value: string }) {
  return (
    <div className="summary-cell">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

function buildSportMarkets(event: EventRecord): SportMarket[] {
  const seed = seededNumber(event.id);
  const marketProfile = getSportMarketProfile(event, seed);
  const homeDecimal = toDecimalOdds(event.homeMoneyline, marketProfile.moneylineHomeFallback);
  const awayDecimal = toDecimalOdds(event.awayMoneyline, marketProfile.moneylineAwayFallback);
  const homeSpreadLine = typeof event.homeSpread === "number" ? event.homeSpread : -marketProfile.spread;
  const awaySpreadLine = typeof event.awaySpread === "number" ? event.awaySpread : marketProfile.spread;
  const totalLine = typeof event.totalLine === "number" ? event.totalLine : marketProfile.total;
  const homeSpreadDecimal = toDecimalOdds(event.homeSpreadOdds, marketProfile.spreadOddsHomeFallback);
  const awaySpreadDecimal = toDecimalOdds(event.awaySpreadOdds, marketProfile.spreadOddsAwayFallback);
  const overDecimal = toDecimalOdds(event.overOdds, marketProfile.totalOddsOverFallback);
  const underDecimal = toDecimalOdds(event.underOdds, marketProfile.totalOddsUnderFallback);
  const spreadOptions = buildSpreadOptions(
    event,
    Math.abs(homeSpreadLine || marketProfile.spread),
    homeSpreadDecimal,
    awaySpreadDecimal,
    marketProfile.spreadAltStep
  );
  const totalOptions = buildTotalOptions(event, totalLine, overDecimal, underDecimal, marketProfile.totalAltStep);

  return [
    {
      id: "popular",
      label: "熱門",
      options: [
        { id: `${event.id}-pop-home`, label: event.homeTeam, odds: homeDecimal },
        { id: `${event.id}-pop-away`, label: event.awayTeam, odds: awayDecimal }
      ]
    },
    {
      id: "moneyline",
      label: "獲勝隊",
      options: [
        { id: `${event.id}-ml-home`, label: `${event.homeTeam} 獲勝`, odds: homeDecimal },
        { id: `${event.id}-ml-away`, label: `${event.awayTeam} 獲勝`, odds: awayDecimal }
      ]
    },
    {
      id: "spread",
      label: "讓分盤",
      options: spreadOptions
    },
    {
      id: "total",
      label: "總分盤",
      options: totalOptions
    }
  ];
}

function getSportMarketProfile(event: EventRecord, seed: number) {
  const sportOrLeague = `${event.sportId ?? ""}:${event.leagueId}`.toUpperCase();

  if (sportOrLeague.includes("NBA") || sportOrLeague.includes("BASKETBALL")) {
    return {
      spread: 4.5 + (seed % 8),
      total: 214.5 + (seed % 24),
      moneylineHomeFallback: 1.68 + (seed % 7) * 0.05,
      moneylineAwayFallback: 1.82 + ((seed + 4) % 7) * 0.06,
      spreadOddsHomeFallback: 1.86,
      spreadOddsAwayFallback: 1.92,
      totalOddsOverFallback: 1.90,
      totalOddsUnderFallback: 1.90,
      spreadAltStep: 1,
      totalAltStep: 2
    };
  }

  if (sportOrLeague.includes("NHL") || sportOrLeague.includes("HOCKEY")) {
    return {
      spread: 1.5,
      total: 5.5 + (seed % 3) * 0.5,
      moneylineHomeFallback: 1.74 + (seed % 6) * 0.05,
      moneylineAwayFallback: 1.78 + ((seed + 3) % 6) * 0.05,
      spreadOddsHomeFallback: 2.05,
      spreadOddsAwayFallback: 1.80,
      totalOddsOverFallback: 1.92,
      totalOddsUnderFallback: 1.88,
      spreadAltStep: 0.5,
      totalAltStep: 0.5
    };
  }

  if (sportOrLeague.includes("MLB") || sportOrLeague.includes("BASEBALL")) {
    return {
      spread: 1.5,
      total: 6.5 + (seed % 5) * 0.5,
      moneylineHomeFallback: 1.72 + (seed % 6) * 0.05,
      moneylineAwayFallback: 1.86 + ((seed + 2) % 6) * 0.06,
      spreadOddsHomeFallback: 2.10,
      spreadOddsAwayFallback: 1.76,
      totalOddsOverFallback: 1.92,
      totalOddsUnderFallback: 1.88,
      spreadAltStep: 0.5,
      totalAltStep: 0.5
    };
  }

  if (sportOrLeague.includes("SOCCER") || sportOrLeague.includes("MLS") || sportOrLeague.includes("UEFA")) {
    return {
      spread: 0.5 + (seed % 3) * 0.5,
      total: 2.5 + (seed % 3) * 0.5,
      moneylineHomeFallback: 1.95,
      moneylineAwayFallback: 2.15,
      spreadOddsHomeFallback: 1.95,
      spreadOddsAwayFallback: 1.87,
      totalOddsOverFallback: 1.93,
      totalOddsUnderFallback: 1.87,
      spreadAltStep: 0.5,
      totalAltStep: 0.5
    };
  }

  return {
    spread: 3.5 + (seed % 5),
    total: 41.5 + (seed % 11),
    moneylineHomeFallback: 1.75,
    moneylineAwayFallback: 2.05,
    spreadOddsHomeFallback: 1.90,
    spreadOddsAwayFallback: 1.90,
    totalOddsOverFallback: 1.90,
    totalOddsUnderFallback: 1.90,
    spreadAltStep: 1,
    totalAltStep: 1
  };
}

function buildSpreadOptions(
  event: EventRecord,
  baseAbsSpread: number,
  homeBaseOdds: string,
  awayBaseOdds: string,
  step: number
): SportMarketOption[] {
  const levels = buildAlternativeLevels(baseAbsSpread, step);
  const homeBase = Number.parseFloat(homeBaseOdds);
  const awayBase = Number.parseFloat(awayBaseOdds);

  return levels.flatMap((absLine) => {
    const diff = absLine - baseAbsSpread;
    const homeOdds = formatDecimal(adjustDecimal(homeBase, diff > 0 ? 0.14 : diff < 0 ? -0.14 : 0));
    const awayOdds = formatDecimal(adjustDecimal(awayBase, diff > 0 ? -0.14 : diff < 0 ? 0.14 : 0));

    return [
      { id: `${event.id}-spread-home-${absLine}`, label: event.homeTeam, line: formatSignedLine(-absLine), odds: homeOdds },
      { id: `${event.id}-spread-away-${absLine}`, label: event.awayTeam, line: formatSignedLine(absLine), odds: awayOdds }
    ];
  });
}

function buildTotalOptions(
  event: EventRecord,
  baseTotal: number,
  overBaseOdds: string,
  underBaseOdds: string,
  step: number
): SportMarketOption[] {
  const levels = buildAlternativeLevels(baseTotal, step);
  const overBase = Number.parseFloat(overBaseOdds);
  const underBase = Number.parseFloat(underBaseOdds);

  return levels.flatMap((lineValue) => {
    const diff = lineValue - baseTotal;
    const overOdds = formatDecimal(adjustDecimal(overBase, diff > 0 ? 0.12 : diff < 0 ? -0.12 : 0));
    const underOdds = formatDecimal(adjustDecimal(underBase, diff > 0 ? -0.12 : diff < 0 ? 0.12 : 0));

    return [
      { id: `${event.id}-total-over-${lineValue}`, label: "大分", line: formatLine(lineValue), odds: overOdds },
      { id: `${event.id}-total-under-${lineValue}`, label: "小分", line: formatLine(lineValue), odds: underOdds }
    ];
  });
}

function buildAlternativeLevels(baseValue: number, step: number): number[] {
  const values = [baseValue - step, baseValue, baseValue + step]
    .filter((value) => value > 0)
    .map((value) => roundToHalf(value));

  return Array.from(new Set(values));
}

function roundToHalf(value: number): number {
  return Math.round(value * 2) / 2;
}

function adjustDecimal(base: number, delta: number): number {
  const safeBase = Number.isFinite(base) ? base : 1.9;
  return Math.max(1.2, safeBase + delta);
}

function normalizeStakeAmount(value: string | number, fallback: number): number {
  const parsed =
    typeof value === "number" ? value : Number.parseInt(String(value).replace(/[^\d]/g, ""), 10);

  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }

  return Math.max(50, Math.round(parsed));
}

function seededNumber(seed: string): number {
  let hash = 0;
  for (const char of seed) {
    hash = (hash * 31 + char.charCodeAt(0)) % 100000;
  }
  return hash;
}

function toDecimalOdds(value: number | undefined, fallback: number): string {
  if (typeof value !== "number") {
    return formatDecimal(fallback);
  }

  if (value > 0) {
    return formatDecimal(value / 100 + 1);
  }

  return formatDecimal(100 / Math.abs(value) + 1);
}

function formatDecimal(value: number): string {
  return value.toFixed(2);
}

function formatSignedLine(value: number): string {
  return `${value > 0 ? "+" : ""}${formatLine(value)}`;
}

function formatLine(value: number): string {
  return Number.isInteger(value) ? value.toString() : value.toFixed(1);
}

function getTeamAliasZhTw(name: string): string {
  return TEAM_ALIASES_ZH_TW[name] ?? "";
}

function toSafeNumber(value: unknown, fallback: number): number {
  const parsed = typeof value === "number" ? value : Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function createTicketNo(prefix: "SP" | "BG"): string {
  return `${prefix}${Date.now().toString().slice(-9)}${Math.floor(Math.random() * 900 + 100)}`;
}

function resolveSportLabel(event: EventRecord, sports: SportRecord[], activeSport: string): string {
  const matchedSport = sports.find((sport) => sport.id === event.sportId);
  if (matchedSport) {
    return matchedSport.label;
  }

  const fallbackSport = sports.find((sport) => sport.id === activeSport);
  return fallbackSport?.label ?? "Sports";
}

function buildWalletBetRecords(sportsBetHistory: SportsBetHistoryRecord[], bingoBets: BetRecord[]): WalletBetRecord[] {
  const sportsRecords: WalletBetRecord[] = sportsBetHistory.map((record) => {
    const scoreLabel =
      typeof record.homeScore === "number" && typeof record.awayScore === "number"
        ? `${record.homeTeam} ${record.homeScore} : ${record.awayScore} ${record.awayTeam}`
        : "比賽尚未有最終比分";

    return {
      id: `sports-${record.id}`,
      source: "sports",
      ticketNo: record.ticketNo,
      category: `${record.sportLabel} / ${record.leagueLabel}`,
      title: record.matchup,
      subtitle: `${record.marketLabel} / ${record.pickLabel}`,
      amount: record.amount,
      payout: record.status === "won" ? record.potentialPayout : record.status === "lost" ? 0 : null,
      status: record.status,
      statusLabel: formatBetStatus(record.status),
      createdAt: record.createdAt,
      detailRows: [
        { label: "投注單號", value: record.ticketNo },
        { label: "賽事項目", value: record.sportLabel },
        { label: "聯盟", value: record.leagueLabel },
        { label: "玩法", value: record.marketLabel },
        { label: "下注選項", value: record.pickLabel },
        { label: "賠率", value: record.oddsLabel },
        { label: "下注金額", value: `${record.amount} 元` },
        { label: "預估返還", value: `${record.potentialPayout} 元` },
        { label: "開賽時間", value: record.eventTime ? formatDateTime(record.eventTime) : "--" },
        { label: "比分", value: scoreLabel },
        { label: "結果", value: formatBetStatus(record.status) }
      ]
    };
  });

  const bingoRecords: WalletBetRecord[] = bingoBets.map((bet) => {
    const normalizedStatus = normalizeBingoStatus(bet.status);
    const payout = normalizedStatus === "pending" ? null : bet.payout;

    return {
      id: `bingo-${bet.id}`,
      source: "bingo",
      ticketNo: `BG${String(bet.id).padStart(8, "0")}`,
      category: "Bingo Bingo",
      title: `${formatBingoBetType(bet.bet_type)} / ${bet.round_id}`,
      subtitle: formatBingoSelection(bet),
      amount: bet.amount,
      payout,
      status: normalizedStatus,
      statusLabel: formatBetStatus(normalizedStatus),
      createdAt: bet.created_at,
      detailRows: [
        { label: "投注單號", value: `BG${String(bet.id).padStart(8, "0")}` },
        { label: "期數", value: bet.round_id },
        { label: "玩法", value: formatBingoBetType(bet.bet_type) },
        { label: "投注內容", value: formatBingoSelection(bet) },
        { label: "下注金額", value: `${bet.amount} 元` },
        { label: "命中數", value: bet.matched_count !== null ? `${bet.matched_count}` : "--" },
        { label: "倍率", value: bet.multiplier !== null ? `x${bet.multiplier}` : "--" },
        { label: "超級獎號", value: bet.has_super_number ? "有命中" : "未命中" },
        { label: "返還金額", value: payout !== null ? `${payout} 元` : "待開獎" },
        { label: "結果", value: formatBetStatus(normalizedStatus) }
      ]
    };
  });

  return [...sportsRecords, ...bingoRecords].sort(
    (left, right) => new Date(right.createdAt).getTime() - new Date(left.createdAt).getTime()
  );
}

function normalizeBingoStatus(status: string): WalletBetRecord["status"] {
  if (status === "won" || status === "lost" || status === "refunded" || status === "pending") {
    return status;
  }

  return "pending";
}

function formatBetStatus(status: WalletBetRecord["status"]): string {
  switch (status) {
    case "won":
      return "已中獎";
    case "lost":
      return "未中獎";
    case "refunded":
      return "已退款";
    default:
      return "待開獎";
  }
}

function statusToneClass(status: WalletBetRecord["status"]): string {
  switch (status) {
    case "won":
      return "gain";
    case "lost":
      return "loss";
    case "refunded":
      return "muted";
    default:
      return "muted";
  }
}

function formatBingoBetType(value: string): string {
  if (value.startsWith("star_")) {
    return `${value.replace("star_", "")} 星`;
  }

  if (value === "big_small") {
    return "猜大小";
  }

  if (value === "odd_even") {
    return "猜單雙";
  }

  return value;
}

function formatBingoSelection(bet: BetRecord): string {
  if (bet.selected_numbers) {
    const numbers = drawNumbers(bet.selected_numbers);
    if (numbers.length > 0) {
      return numbers.join(" / ");
    }
  }

  if (bet.selected_option) {
    if (bet.bet_type === "big_small") {
      return bet.selected_option === "big" ? "大" : "小";
    }

    if (bet.bet_type === "odd_even") {
      return bet.selected_option === "odd" ? "單" : "雙";
    }

    return bet.selected_option;
  }

  return "尚無投注內容";
}

function buildQuickSportFilters(leagues: LeagueRecord[]): QuickSportFilter[] {
  return quickSportBlueprints.flatMap((item) => {
    const matchingLeagues = leagues.filter((league) => league.sportId === item.sportId);
    if (matchingLeagues.length === 0) {
      return [];
    }

    const selectedLeague =
      item.preferredLeagueIds
        .map((leagueId) => matchingLeagues.find((league) => league.id === leagueId))
        .find(Boolean) ?? matchingLeagues[0];

    return [
      {
        id: item.id,
        label: item.label,
        code: item.code,
        sportId: item.sportId,
        leagueId: selectedLeague?.id
      }
    ];
  });
}

function buildRecentTopNumberRows(draws: DrawRound[]): StatBarItem[] {
  if (draws.length === 0) {
    return [{ label: "尚無資料", percentage: 0, note: "等待更多開獎紀錄" }];
  }

  const frequency = new Map<number, number>();
  for (const draw of draws) {
    for (const number of drawNumbers(draw.numbers)) {
      frequency.set(number, (frequency.get(number) ?? 0) + 1);
    }
  }

  return Array.from(frequency.entries())
    .sort((left, right) => right[1] - left[1] || left[0] - right[0])
    .slice(0, 5)
    .map(([number, count]) => ({
      label: `${number} 號`,
      percentage: Math.round((count / draws.length) * 100),
      note: `${count} / ${draws.length} 期出現`
    }));
}

function buildRecentBigSmallRows(draws: DrawRound[]): StatBarItem[] {
  if (draws.length === 0) {
    return [{ label: "尚無資料", percentage: 0, note: "等待更多開獎紀錄" }];
  }

  let big = 0;
  let small = 0;
  let tie = 0;

  for (const draw of draws) {
    const numbers = drawNumbers(draw.numbers);
    const bigCount = numbers.filter((number) => number >= 41).length;
    const smallCount = numbers.length - bigCount;

    if (bigCount >= 13) {
      big += 1;
    } else if (smallCount >= 13) {
      small += 1;
    } else {
      tie += 1;
    }
  }

  return [
    { label: "大", percentage: Math.round((big / draws.length) * 100), note: `${big} / ${draws.length} 期` },
    { label: "小", percentage: Math.round((small / draws.length) * 100), note: `${small} / ${draws.length} 期` },
    { label: "和局", percentage: Math.round((tie / draws.length) * 100), note: `${tie} / ${draws.length} 期` }
  ];
}

function buildRecentOddEvenRows(draws: DrawRound[]): StatBarItem[] {
  if (draws.length === 0) {
    return [{ label: "尚無資料", percentage: 0, note: "等待更多開獎紀錄" }];
  }

  let odd = 0;
  let even = 0;
  let tie = 0;

  for (const draw of draws) {
    const numbers = drawNumbers(draw.numbers);
    const oddCount = numbers.filter((number) => number % 2 === 1).length;
    const evenCount = numbers.length - oddCount;

    if (oddCount > evenCount) {
      odd += 1;
    } else if (evenCount > oddCount) {
      even += 1;
    } else {
      tie += 1;
    }
  }

  return [
    { label: "單", percentage: Math.round((odd / draws.length) * 100), note: `${odd} / ${draws.length} 期` },
    { label: "雙", percentage: Math.round((even / draws.length) * 100), note: `${even} / ${draws.length} 期` },
    { label: "和局", percentage: Math.round((tie / draws.length) * 100), note: `${tie} / ${draws.length} 期` }
  ];
}
