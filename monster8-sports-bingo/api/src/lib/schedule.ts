const BUSINESS_START_MINUTES = 7 * 60 + 5;
const BUSINESS_END_MINUTES = 23 * 60 + 55;
const TAIPEI_OFFSET_MS = 8 * 60 * 60 * 1000;

function toTaipeiClock(input: Date): Date {
  return new Date(input.getTime() + TAIPEI_OFFSET_MS);
}

function fromTaipeiClock(input: Date): Date {
  return new Date(input.getTime() - TAIPEI_OFFSET_MS);
}

function startOfMinute(input: Date): Date {
  const next = toTaipeiClock(input);
  next.setUTCSeconds(0, 0);
  return fromTaipeiClock(next);
}

function pad(value: number, width = 2): string {
  return value.toString().padStart(width, "0");
}

export function formatDateTime(date: Date): string {
  const taipei = toTaipeiClock(date);
  return [
    `${taipei.getUTCFullYear()}-${pad(taipei.getUTCMonth() + 1)}-${pad(taipei.getUTCDate())}`,
    `${pad(taipei.getUTCHours())}:${pad(taipei.getUTCMinutes())}:${pad(taipei.getUTCSeconds())}`
  ].join(" ");
}

export function isBusinessMinute(date: Date): boolean {
  const taipei = toTaipeiClock(date);
  const totalMinutes = taipei.getUTCHours() * 60 + taipei.getUTCMinutes();
  return totalMinutes >= BUSINESS_START_MINUTES && totalMinutes <= BUSINESS_END_MINUTES;
}

export function getUpcomingDrawTime(now: Date): Date {
  const base = toTaipeiClock(startOfMinute(now));
  const totalMinutes = base.getUTCHours() * 60 + base.getUTCMinutes();

  if (totalMinutes < BUSINESS_START_MINUTES) {
    base.setUTCHours(7, 5, 0, 0);
    return fromTaipeiClock(base);
  }

  if (totalMinutes > BUSINESS_END_MINUTES || (totalMinutes === BUSINESS_END_MINUTES && now.getSeconds() > 0)) {
    base.setUTCDate(base.getUTCDate() + 1);
    base.setUTCHours(7, 5, 0, 0);
    return fromTaipeiClock(base);
  }

  const minutes = base.getUTCMinutes();
  const remainder = minutes % 5;
  if (remainder === 0 && now.getSeconds() === 0 && totalMinutes >= BUSINESS_START_MINUTES) {
    base.setUTCMinutes(minutes + 5, 0, 0);
  } else if (remainder === 0) {
    base.setUTCMinutes(minutes + 5, 0, 0);
  } else {
    base.setUTCMinutes(minutes + (5 - remainder), 0, 0);
  }

  const nextTotalMinutes = base.getUTCHours() * 60 + base.getUTCMinutes();
  if (nextTotalMinutes > BUSINESS_END_MINUTES) {
    base.setUTCDate(base.getUTCDate() + 1);
    base.setUTCHours(7, 5, 0, 0);
  }
  return fromTaipeiClock(base);
}

export function getMostRecentScheduledDrawTime(now: Date): Date | null {
  const base = toTaipeiClock(startOfMinute(now));
  const totalMinutes = base.getUTCHours() * 60 + base.getUTCMinutes();

  if (totalMinutes < BUSINESS_START_MINUTES || totalMinutes > BUSINESS_END_MINUTES) {
    return null;
  }

  const remainder = base.getUTCMinutes() % 5;
  if (remainder !== 0) {
    base.setUTCMinutes(base.getUTCMinutes() - remainder, 0, 0);
  }

  const localTime = fromTaipeiClock(base);
  if (!isBusinessMinute(localTime)) {
    return null;
  }

  return localTime;
}

function createScheduledDate(source: Date, hours: number, minutes: number): Date {
  const next = toTaipeiClock(startOfMinute(source));
  next.setUTCHours(hours, minutes, 0, 0);
  return fromTaipeiClock(next);
}

export function getMostRecentSettledDrawTime(now: Date): Date {
  const scheduled = getMostRecentScheduledDrawTime(now);
  if (scheduled) {
    return scheduled;
  }

  const base = toTaipeiClock(startOfMinute(now));
  const totalMinutes = base.getUTCHours() * 60 + base.getUTCMinutes();

  if (totalMinutes < BUSINESS_START_MINUTES) {
    base.setUTCDate(base.getUTCDate() - 1);
    return createScheduledDate(fromTaipeiClock(base), 23, 55);
  }

  return createScheduledDate(fromTaipeiClock(base), 23, 55);
}

export function getPreviousScheduledDrawTime(drawTime: Date): Date {
  const previous = toTaipeiClock(startOfMinute(drawTime));
  previous.setUTCMinutes(previous.getUTCMinutes() - 5, 0, 0);

  const previousLocal = fromTaipeiClock(previous);
  if (isBusinessMinute(previousLocal)) {
    return previousLocal;
  }

  previous.setUTCDate(previous.getUTCDate() - 1);
  previous.setUTCHours(23, 55, 0, 0);
  return fromTaipeiClock(previous);
}

export function getRecentScheduledDrawTimes(now: Date, count: number): Date[] {
  const result: Date[] = [];
  let cursor = getMostRecentSettledDrawTime(now);

  while (result.length < count) {
    result.push(new Date(cursor));
    cursor = getPreviousScheduledDrawTime(cursor);
  }

  return result.reverse();
}

export function getRoundId(drawTime: Date): string {
  const taipei = toTaipeiClock(drawTime);
  const totalMinutes = taipei.getUTCHours() * 60 + taipei.getUTCMinutes();
  const sequence = Math.floor((totalMinutes - BUSINESS_START_MINUTES) / 5) + 1;
  return `${taipei.getUTCFullYear()}${pad(taipei.getUTCMonth() + 1)}${pad(taipei.getUTCDate())}-${pad(sequence, 3)}`;
}

export function getCutoffTime(drawTime: Date): Date {
  return new Date(drawTime.getTime() - 1000);
}

export function parseDateTime(value: string): Date {
  const [datePart, timePart = "00:00:00"] = value.split(" ");
  const [year, month, day] = datePart.split("-").map((item) => Number.parseInt(item, 10));
  const [hours, minutes, seconds] = timePart.split(":").map((item) => Number.parseInt(item, 10));

  return new Date(Date.UTC(year, month - 1, day, hours, minutes, seconds || 0) - TAIPEI_OFFSET_MS);
}

export function getCountdownSeconds(now: Date, drawTime: Date): number {
  return Math.max(0, Math.ceil((drawTime.getTime() - now.getTime()) / 1000));
}
