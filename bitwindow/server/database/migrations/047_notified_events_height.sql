-- Records the block that confirmed an event, so a fork purge can drop the rows
-- whose confirming block went away and let the notification fire again. NULL
-- for events that aren't tied to a block.
ALTER TABLE notified_events ADD COLUMN height INTEGER;
