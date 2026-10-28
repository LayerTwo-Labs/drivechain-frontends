CREATE TEMP TABLE retired_cn_items AS
WITH RECURSIVE retired(item_id) AS (
    SELECT item_id FROM cn_items WHERE type_tag IN (4, 5)
    UNION
    SELECT c.item_id FROM cn_comments c JOIN retired r ON c.parent_id = r.item_id
)
SELECT item_id FROM retired;

DELETE FROM cn_continuations WHERE head_id IN (SELECT item_id FROM retired_cn_items);
DELETE FROM cn_comments WHERE item_id IN (SELECT item_id FROM retired_cn_items);
DELETE FROM cn_items WHERE item_id IN (SELECT item_id FROM retired_cn_items);
DROP TABLE retired_cn_items;

DROP TABLE IF EXISTS cn_votes;
