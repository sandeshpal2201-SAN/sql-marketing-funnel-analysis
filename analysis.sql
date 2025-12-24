-- Funnel counts
SELECT
  COUNT(CASE WHEN event_type = 'impression' THEN 1 END) AS impressions,
  COUNT(CASE WHEN event_type = 'click' THEN 1 END) AS clicks,
  COUNT(CASE WHEN event_type = 'conversion' THEN 1 END) AS conversions
FROM funnel_events;

-- Campaign-wise performance
SELECT
  campaign_id,
  COUNT(CASE WHEN event_type = 'impression' THEN 1 END) AS impressions,
  COUNT(CASE WHEN event_type = 'click' THEN 1 END) AS clicks,
  COUNT(CASE WHEN event_type = 'conversion' THEN 1 END) AS conversions,
  ROUND(
    1.0 * COUNT(CASE WHEN event_type = 'click' THEN 1 END) /
    NULLIF(COUNT(CASE WHEN event_type = 'impression' THEN 1 END), 0), 2
  ) AS ctr,
  ROUND(
    1.0 * COUNT(CASE WHEN event_type = 'conversion' THEN 1 END) /
    NULLIF(COUNT(CASE WHEN event_type = 'click' THEN 1 END), 0), 2
  ) AS conversion_rate
FROM funnel_events
GROUP BY campaign_id;

-- User drop-off summary
SELECT
  COUNT(*) AS total_users,
  SUM(clicked) AS users_clicked,
  SUM(converted) AS users_converted,
  SUM(clicked) - SUM(converted) AS drop_after_click
FROM (
  SELECT
    user_id,
    MAX(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) AS clicked,
    MAX(CASE WHEN event_type = 'conversion' THEN 1 ELSE 0 END) AS converted
  FROM funnel_events
  GROUP BY user_id
);

-- Spend and cost per conversion
SELECT
  campaign_id,
  ROUND(SUM(spend), 2) AS total_spend,
  COUNT(CASE WHEN event_type = 'conversion' THEN 1 END) AS conversions,
  ROUND(
    SUM(spend) / NULLIF(COUNT(CASE WHEN event_type = 'conversion' THEN 1 END), 0),
    2
  ) AS cost_per_conversion
FROM funnel_events
GROUP BY campaign_id;
