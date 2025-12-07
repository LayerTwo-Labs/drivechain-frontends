import type { Timestamp } from "@bufbuild/protobuf/wkt";

export function timestampToDate(timestamp?: Timestamp): Date {
  if (!timestamp) {
    return new Date(0);
  }

  const seconds = Number(timestamp.seconds);
  return new Date(seconds * 1000);
}
