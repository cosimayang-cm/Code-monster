export const getClientIp = (value: string | undefined): string => value?.trim() || "0.0.0.0";
export const getUserAgent = (value: string | undefined): string => value?.trim() || "unknown";
