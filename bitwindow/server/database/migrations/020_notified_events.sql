-- Track which events have been notified to avoid duplicates on restart
CREATE TABLE IF NOT EXISTS notified_events (
    event_type TEXT NOT NULL,
    event_id TEXT NOT NULL,
    notified_at TEXT NOT NULL,
    PRIMARY KEY (event_type, event_id)
);
