const BUSINESS_START_MINUTES = 7 * 60 + 5;
const BUSINESS_END_MINUTES = 23 * 60 + 55;

function startOfMinute(input: Date): Date {
  const next = new Date(input);
  next.setSeconds(0, 0);
  return next;
}

function pad(value: number, width = 2): string {
  return value.toString().padStart(width, "0");
}

export function formatDateTime(date: Date): string {
  return [
    `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`,
    `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
  ].join(" ");
}

export function isBusinessMinute(date: Date): boolean {
  const totalMinutes = date.getHours() * 60 + date.getMinutes();
  return totalMinutes >= BUSINESS_START_MINUTES && totalMinutes <= BUSINESS_END_MINUTES;
}

export function getUpcomingDrawTime(now: Date): Date {
  const base = startOfMinute(now);
  const totalMinutes = base.getHours() * 60 + base.getMinutes();

  if (totalMinutes < BUSINESS_START_MINUTES) {
    base.setHours(7, 5, 0, 0);
    return base;
  }

  if (totalMinutes > BUSINESS_END_MINUTES || (totalMinutes === BUSINESS_END_MINUTES && now.getSeconds() > 0)) {
    base.setDate(base.getDate() + 1);
    base.setHours(7, 5, 0, 0);
    return base;
  }

  const minutes = base.getMinutes();
  const remainder = minutes % 5;
  if (remainder === 0 && now.getSeconds() === 0 && totalMinutes >= BUSINESS_START_MINUTES) {
    base.setMinutes(minutes + 5, 0, 0);
  } else if (remainder === 0) {
    base.setMinutes(minutes + 5, 0, 0);
  } else {
    base.setMinutes(minutes + (5 - remainder), 0, 0);
  }

  const nextTotalMinutes = base.getHours() * 60 + base.getMinutes();
  if (nextTotalMinutes > BUSINESS_END_MINUTES) {
    base.setDate(base.getDate() + 1);
    base.setHours(7, 5, 0, 0);
  }
  return base;
}

export function getMostRecentScheduledDrawTime(now: Date): Date | null {
  const base = startOfMinute(now);
  const totalMinutes = base.getHours() * 60 + base.getMinutes();

  if (totalMinutes < BUSINESS_START_MINUTES || totalMinutes > BUSINESS_END_MINUTES) {
    return null;
  }

  const remainder = base.getMinutes() % 5;
  if (remainder !== 0) {
    base.setMinutes(base.getMinutes() - remainder, 0, 0);
  }

  if (!isBusinessMinute(base)) {
    return null;
  }

  return base;
}

function createScheduledDate(source: Date, hours: number, minutes: number): Date {
  const next = startOfMinute(source);
  next.setHours(hours, minutes, 0, 0);
  return next;
}

export function getMostRecentSettledDrawTime(now: Date): Date {
  const scheduled = getMostRecentScheduledDrawTime(now);
  if (scheduled) {
    return scheduled;
  }

  const base = startOfMinute(now);
  const totalMinutes = base.getHours() * 60 + base.getMinutes();

  if (totalMinutes < BUSINESS_START_MINUTES) {
    base.setDate(base.getDate() - 1);
    return createScheduledDate(base, 23, 55);
  }

  return createScheduledDate(base, 23, 55);
}

export function getPreviousScheduledDrawTime(drawTime: Date): Date {
  const previous = startOfMinute(drawTime);
  previous.setMinutes(previous.getMinutes() - 5, 0, 0);

  if (isBusinessMinute(previous)) {
    return previous;
  }

  previous.setDate(previous.getDate() - 1);
  previous.setHours(23, 55, 0, 0);
  return previous;
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
  const totalMinutes = drawTime.getHours() * 60 + drawTime.getMinutes();
  const sequence = Math.floor((totalMinutes - BUSINESS_START_MINUTES) / 5) + 1;
  return `${drawTime.getFullYear()}${pad(drawTime.getMonth() + 1)}${pad(drawTime.getDate())}-${pad(sequence, 3)}`;
}

export function getCutoffTime(drawTime: Date): Date {
  return new Date(drawTime.getTime() - 1000);
}

export function getCountdownSeconds(now: Date, drawTime: Date): number {
  return Math.max(0, Math.ceil((drawTime.getTime() - now.getTime()) / 1000));
}
