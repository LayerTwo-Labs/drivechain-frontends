-- Terminal transitions now record the height they happened at. Rows written
-- before that carry only their last vote, so a fork purge cannot tell which
-- branch ended them and has to take them conservatively. This marks the rows
-- that do carry a real stamp, so the conservative path applies to legacy rows
-- alone rather than to every terminal bundle forever.
ALTER TABLE withdrawal_bundles ADD COLUMN status_stamped INTEGER NOT NULL DEFAULT 0;
