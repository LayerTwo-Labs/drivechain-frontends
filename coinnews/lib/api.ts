import type { Timestamp } from "@bufbuild/protobuf/wkt";

export function timestampToDate(timestamp?: Timestamp): Date {
  if (!timestamp) {
    return new Date(0);
  }
  const seconds = Number(timestamp.seconds);
  return new Date(seconds * 1000);
}

export function timeAgo(date: Date): string {
  const now = Date.now();
  const ms = now - date.getTime();
  const sec = Math.floor(ms / 1000);
  if (sec < 60) return `${sec}s ago`;
  const min = Math.floor(sec / 60);
  if (min < 60) return `${min}m ago`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h ago`;
  const day = Math.floor(hr / 24);
  if (day < 365) return `${day}d ago`;
  const yr = Math.floor(day / 365);
  return `${yr}y ago`;
}
