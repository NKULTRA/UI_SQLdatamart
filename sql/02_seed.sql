-- ============================================================================
-- FILE: 02_seed.sql
-- PURPOSE: Create testdate within the previously created tables
-- ============================================================================

SET search_path TO airbnb;

-- ---------------------------
-- Seed currencies (20)
-- ---------------------------
INSERT INTO currencies (currency_code, currency_name, symbol)
VALUES
('EUR','Euro','€'),
('USD','US Dollar','$'),
('GBP','Pound Sterling','£'),
('JPY','Japanese Yen','¥'),
('CHF','Swiss Franc','CHF'),
('CAD','Canadian Dollar','$'),
('AUD','Australian Dollar','$'),
('CNY','Chinese Yuan','¥'),
('SEK','Swedish Krona','kr'),
('NOK','Norwegian Krone','kr'),
('DKK','Danish Krone','kr'),
('PLN','Polish Złoty','zł'),
('CZK','Czech Koruna','Kč'),
('HUF','Hungarian Forint','Ft'),
('TRY','Turkish Lira','₺'),
('BRL','Brazilian Real','R$'),
('INR','Indian Rupee','₹'),
('KRW','South Korean Won','₩'),
('MXN','Mexican Peso','$'),
('ZAR','South African Rand','R');

-- ---------------------------
-- Seed countries (20)
-- ---------------------------
INSERT INTO countries (country_name, country_code)
SELECT 'Country ' || gs, 'C' || lpad(gs::text, 1, '0')
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed booking_status (20)
-- ---------------------------
INSERT INTO booking_status (status_name)
SELECT 'STATUS_' || gs
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed cities (20)
-- ---------------------------
INSERT INTO cities (city_name, country_id)
SELECT
  'City ' || gs,
  ((gs - 1) % 20) + 1
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed addresses (20)
-- ---------------------------
INSERT INTO addresses (street, house_number, postal_code, city_id, latitude, longitude)
SELECT
  'Street ' || gs,
  gs::text,
  lpad(gs::text, 5, '0'),
  ((gs - 1) % 20) + 1,
  50.0 + (gs * 0.01),
  8.0 + (gs * 0.01)
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed users (20)
-- ---------------------------
INSERT INTO users (first_name, last_name, country_id, default_currency_code)
SELECT
  'First' || gs,
  'Last' || gs,
  ((gs - 1) % 20) + 1,
  'EUR'
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed property_types (20)
-- ---------------------------
INSERT INTO property_types (name, description)
SELECT
  'PropertyType ' || gs,
  'Description for property type ' || gs
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed listings (20)
-- ---------------------------
INSERT INTO listings (
  host_id, address_id, property_type_id, title, description,
  max_guests, bedrooms, beds, bathrooms,
  base_price_per_night, cleaning_fee, currency_code
)
SELECT
  ((gs - 1) % 20) + 1,
  ((gs - 1) % 20) + 1,
  ((gs - 1) % 20) + 1,
  'Listing ' || gs,
  'Description for listing ' || gs,
  2 + (gs % 5),
  gs % 4,
  1 + (gs % 5),
  1 + (gs % 3),
  50 + gs,
  10,
  'EUR'
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed amenities (20)
-- ---------------------------
INSERT INTO amenities (name, description)
SELECT
  'Amenity ' || gs,
  'Amenity description ' || gs
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed listing_amenities (20)
-- ---------------------------
INSERT INTO listing_amenities (listing_id, amenity_id)
SELECT
  ((gs - 1) % 20) + 1,
  ((gs - 1) % 20) + 1
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed listing_calendar (20)
-- ---------------------------
INSERT INTO listing_calendar (listing_id, date, price_per_night, is_available, min_nights, max_nights)
SELECT
  ((gs - 1) % 20) + 1,
  DATE '2026-01-01' + (gs - 1),
  60 + gs,
  TRUE,
  1,
  14
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed images (20)
-- ---------------------------
INSERT INTO images (listing_id, image_url)
SELECT
  ((gs - 1) % 20) + 1,
  'https://example.com/listing_' || ((gs - 1) % 20) + 1 || '/img_' || gs || '.jpg'
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed wishlists (20)
-- ---------------------------
INSERT INTO wishlists (user_id, name)
SELECT ((gs - 1) % 20) + 1, 'Wishlist ' || gs
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed wishlist_items (20)
-- ---------------------------
INSERT INTO wishlist_items (wishlist_id, listing_id)
SELECT ((gs - 1) % 20) + 1, ((gs - 1) % 20) + 1
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed bookings (20)
-- ---------------------------
INSERT INTO bookings (
  listing_id, guest_id, check_in_date, check_out_date,
  num_guests, status_id, total_price, service_fee, currency_code
)
SELECT
  ((gs - 1) % 20) + 1,
  ((gs - 1) % 20) + 1,
  DATE '2026-02-01' + gs,
  DATE '2026-02-03' + gs,
  1 + (gs % 4),
  ((gs - 1) % 20) + 1,
  200 + gs,
  20,
  'EUR'
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed payment_methods (20)
-- ---------------------------
INSERT INTO payment_methods (method_name, provider, is_active)
SELECT
  'METHOD_' || gs,
  'PROVIDER_' || gs,
  TRUE
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed payments (20)
-- ---------------------------
INSERT INTO payments (booking_id, payment_method_id, amount, currency_code, status, paid_at)
SELECT
  ((gs - 1) % 20) + 1,
  ((gs - 1) % 20) + 1,
  200 + gs,
  'EUR',
  'COMPLETED',
  NOW() - (gs || ' days')::interval
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed payouts (20)
-- ---------------------------
INSERT INTO payouts (booking_id, host_id, amount, currency_code, scheduled_at, status)
SELECT
  ((gs - 1) % 20) + 1,
  ((gs - 1) % 20) + 1,
  150 + gs,
  'EUR',
  DATE '2026-02-10' + gs,
  'PAID'
FROM generate_series(1,20) gs;

-- ---------------------------
-- Seed roles (20)
-- ---------------------------
INSERT INTO roles (role_code, description)
SELECT
  'ROLE_' || gs,
  'Role description ' || gs
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed user_roles (20)
-- ---------------------------
INSERT INTO user_roles (user_id, role_code)
SELECT
  gs,
  'ROLE_' || gs
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed user_contact (20)
-- ---------------------------
INSERT INTO user_contact (user_id, type, value, is_verified, is_primary)
SELECT
  gs,
  'email',
  'user' || gs || '@example.com',
  TRUE,
  TRUE
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed user_photos (20)
-- ---------------------------
INSERT INTO user_photos (user_id, photo_url, is_profile_photo)
SELECT
  gs,
  'https://example.com/users/' || gs || '/photo.jpg',
  TRUE
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed user_social_account (20)
-- ---------------------------
INSERT INTO user_social_account (user_id, platform, external_id)
SELECT
  gs,
  CASE WHEN gs % 2 = 0 THEN 'FACEBOOK' ELSE 'INSTAGRAM' END,
  'ext_' || gs
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed user_social_connections (20)
-- ---------------------------
INSERT INTO user_social_connections (user_id, connected_user_id, platform)
SELECT
  gs,
  CASE WHEN gs = 20 THEN 1 ELSE gs + 1 END,
  CASE WHEN gs % 2 = 0 THEN 'FACEBOOK' ELSE 'INSTAGRAM' END
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed house_rules (20)
-- ---------------------------
INSERT INTO house_rules (listing_id, rule_text, rule_type)
SELECT
  gs,
  'Rule text for listing ' || gs,
  CASE (gs % 6)
    WHEN 0 THEN 'CHECK_IN'
    WHEN 1 THEN 'CHECK_OUT'
    WHEN 2 THEN 'SMOKING'
    WHEN 3 THEN 'PETS'
    WHEN 4 THEN 'PARTY'
    ELSE 'NOISE'
  END
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed messages (20)
-- ---------------------------
INSERT INTO messages (booking_id, sender_id, recipient_id, message_text)
SELECT
  gs,
  ((gs - 1) % 20) + 1,
  ((gs) % 20) + 1,
  'Message text ' || gs
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed reviews (20)
-- ---------------------------
INSERT INTO reviews (
  booking_id, reviewer_id, reviewee_user_id, review_type,
  rating_overall, rating_cleanliness, rating_communication, comment
)
SELECT
  gs,
  ((gs - 1) % 20) + 1,
  ((gs) % 20) + 1,
  CASE WHEN gs % 2 = 0 THEN 'GUEST_TO_HOST' ELSE 'HOST_TO_GUEST' END,
  3 + (gs % 3),      -- values 3..5
  3 + (gs % 3),
  3 + (gs % 3),
  'Review comment ' || gs
FROM generate_series(1, 20) gs;

-- ---------------------------
-- Seed earnings_simulation (20)
-- ---------------------------
INSERT INTO earnings_simulation (
  host_id, listing_id, date_from, date_to, estimated_net_income
)
SELECT
  gs,
  gs,
  DATE '2026-03-01' + gs,
  DATE '2026-03-07' + gs,
  500 + (gs * 10)
FROM generate_series(1, 20) gs;

