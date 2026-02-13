-- ============================================================================
-- FILE: 03_test.sql
-- PURPOSE: Create testcommands to test the previously created database
-- ============================================================================

SET search_path TO airbnb;

SELECT * FROM booking_status;

SET search_path TO airbnb;

SELECT
  b.booking_id,
  b.check_in_date,
  b.check_out_date,
  l.title AS listing_title,
  host.user_id AS host_id,
  host.first_name || ' ' || host.last_name AS host_name,
  guest.user_id AS guest_id,
  guest.first_name || ' ' || guest.last_name AS guest_name,
  bs.status_name,
  p.payment_id,
  p.amount AS payment_amount,
  po.payout_id,
  po.amount AS payout_amount
FROM bookings b
JOIN listings l ON l.listing_id = b.listing_id
JOIN users host ON host.user_id = l.host_id
JOIN users guest ON guest.user_id = b.guest_id
JOIN booking_status bs ON bs.status_id = b.status_id
LEFT JOIN payments p ON p.booking_id = b.booking_id
LEFT JOIN payouts  po ON po.booking_id = b.booking_id
ORDER BY b.booking_id
LIMIT 20;

SET search_path TO airbnb;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'airbnb'
ORDER BY table_name;

SELECT
  'users' AS table, COUNT(*) FROM users
UNION ALL SELECT 'listings', COUNT(*) FROM listings
UNION ALL SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'payouts', COUNT(*) FROM payouts;
