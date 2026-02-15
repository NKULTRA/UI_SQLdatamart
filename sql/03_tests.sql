-- ============================================================================
-- FILE: 03_test.sql
-- PURPOSE: Create testcommands to test the previously created database
-- ============================================================================

SET search_path TO airbnb;

-- Table users
INSERT INTO users (first_name, last_name, country_id, default_currency_code)
VALUES ('Max', 'Mustermann', 1, 'EUR');

SELECT * FROM users WHERE last_name = 'Mustermann';

-- Table listings
INSERT INTO listings (
  host_id, address_id, property_type_id, title, description,
  max_guests, bedrooms, beds, bathrooms,
  base_price_per_night, cleaning_fee, currency_code
)
SELECT
    u.user_id, 1, 1, 'Cozy Apartment in Berlin',
    'Modern apartment hosted by Max Mustermann.',
    4, 2, 2, 1, 120.00, 25.00, 'EUR'
FROM users u
WHERE u.first_name = 'Max'
  AND u.last_name = 'Mustermann';

SELECT * FROM listings INNER JOIN users on listings.host_id = users.user_id WHERE last_name = 'Mustermann';

-- Table bookings
INSERT INTO bookings (
  listing_id, guest_id, check_in_date, check_out_date,
  num_guests, status_id, total_price, service_fee, currency_code
)
VALUES(21, 21, '2026-02-01', '2026-02-04', 1, 1, 125.00, 9.00, 'EUR');

SELECT * FROM bookings INNER JOIN users on bookings.guest_id = users.user_id WHERE last_name = 'Mustermann';

-- Table payments
INSERT INTO payments (booking_id, payment_method_id, amount, currency_code, status, paid_at)
VALUES(21, 1, 134.00, 'EUR', 'COMPLETED', '2026-02-10');

SELECT * FROM payments ORDER BY booking_id DESC LIMIT 1;

-- Table payouts
INSERT INTO payouts (booking_id, host_id, amount, currency_code, scheduled_at, status)
VALUES(21, 21, 134.00, 'EUR', '2026-02-12', 'PAID');

SELECT * FROM payouts ORDER BY booking_id DESC;

-- Table user_roles
INSERT INTO user_roles (user_id, role_code)
VALUES(21, 'ROLE_2');

SELECT * FROM user_roles WHERE role_code = 'ROLE_2';

-- Table roles
UPDATE roles 
SET description = 'GUEST'
WHERE role_code = 'ROLE_2';

SELECT * FROM roles WHERE role_code = 'ROLE_2';

-- Table user_contact
INSERT INTO user_contact (user_id, type, value, is_verified, is_primary)
VALUES (21, 'email', 'max.mustermann@gmx.de', TRUE, TRUE);

SELECT * FROM user_contact WHERE user_id = 21;

-- Table user_social_account
INSERT INTO user_social_account (user_id, platform, external_id)
VALUES (21, 'INSTAGRAM', 'www.instagram.com');

SELECT * FROM user_social_account WHERE platform = 'INSTAGRAM';

-- Table user_social_connections
INSERT INTO user_social_connections (user_id, connected_user_id, platform)
VALUES (21, 2, 'INSTAGRAM');

SELECT * FROM user_social_connections WHERE platform = 'INSTAGRAM';

-- Table user_photos
INSERT INTO user_photos (user_id, photo_url, is_profile_photo)
VALUES (21, 'https://example.com/photo.jpg', TRUE);

SELECT * FROM user_photos WHERE user_id = 21;

-- Table addresses
INSERT INTO addresses (street, house_number, postal_code, city_id, latitude, longitude)
VALUES
('Unter den Linden', '12', '10117', 1, 52.5170, 13.3889),
('Friedrichstraße', '45', '10117', 1, 52.5075, 13.3903),
('Kurfürstendamm', '101', '10711', 1, 52.5030, 13.3320),
('Alexanderplatz', '3', '10178', 1, 52.5219, 13.4132),
('Potsdamer Straße', '88', '10785', 1, 52.4987, 13.3656);


SELECT 
    l.listing_id,
    l.title,
    u.first_name,
    u.last_name,
    a.street,
    a.house_number,
    a.postal_code,
    c.city_name,
    co.country_name
FROM listings l
JOIN users u 
    ON u.user_id = l.host_id
JOIN addresses a 
    ON a.address_id = l.address_id
JOIN cities c 
    ON c.city_id = a.city_id
JOIN countries co
    ON co.country_id = c.country_id
WHERE l.listing_id = 21;

-- Table cities
INSERT INTO cities (city_name, country_id) 
VALUES ('Munich', 1);

SELECT * FROM cities 
JOIN countries on cities.country_id = countries.country_id 
WHERE cities.country_id = 1;

-- Table countries
INSERT INTO countries (country_name, country_code)
VALUES ('Austria', 'AT');

SELECT * FROM countries;

-- Table amenities
INSERT INTO amenities (name, description)
VALUES ('Wi-Fi', 'The listing has free Wi-Fi.');

SELECT * FROM amenities;

-- Table listing_amenities
INSERT INTO listing_amenities (listing_id, amenity_id)
VALUES (21, 21);

SELECT l.title, l.description, a.name, a.description
FROM listings l
JOIN listing_amenities la on l.listing_id = la.listing_id
JOIN amenities a on a.amenity_id = la.amenity_id
WHERE l.listing_id = 21;

-- Table wishlist_items
INSERT INTO wishlist_items (wishlist_id, listing_id)
VALUES (20, 21);

SELECT * FROM wishlist_items;

-- Table wishlists
UPDATE wishlists
SET user_id = 21, name = 'Summer vacation'
WHERE wishlist_id = 20;

SELECT * FROM wishlists;

-- Table property_types
INSERT INTO property_types (name, description)
VALUES ('Apartment', 'Self-contained residential unit within a building.');

SELECT * FROM property_types ORDER BY property_type_id DESC;

-- Table house_rules
INSERT INTO house_rules (listing_id, rule_text, rule_type)
VALUES (21, 'No smoking allowed.', 'SMOKING');

SELECT * FROM house_rules WHERE listing_id = 21;

-- Table listing_calendar
INSERT INTO listing_calendar (listing_id, date, price_per_night, is_available, min_nights, max_nights)
VALUES (21, '2026-02-15', 60, TRUE, 1, 12);

SELECT * FROM listing_calendar WHERE listing_id = 21;

-- Table images
INSERT INTO images (listing_id, image_url)
VALUES (21, 'https://example.com/listing_21_max_mustermann.jpg');

SELECT * FROM images WHERE listing_id = 21;

-- Table earnings_simulation
INSERT INTO earnings_simulation (host_id, listing_id, date_from, date_to, estimated_net_income)
VALUES (21, 21, '2026-02-15', '2026-02-27', 720);

SELECT * FROM earnings_simulation WHERE listing_id = 21;

-- Table messages
-- preparation for another host / booking / Listing
INSERT INTO users (first_name, last_name, country_id, default_currency_code)
VALUES ('Anna', 'Hostmann', 1, 'EUR')
RETURNING user_id;

INSERT INTO listings (
  host_id, address_id, property_type_id, title, description,
  max_guests, bedrooms, beds, bathrooms,
  base_price_per_night, cleaning_fee, currency_code
)
SELECT
  u.user_id, 1, 1,
  'Bright Studio in Berlin',
  'Hosted by Anna Hostmann.',
  2, 1, 1, 1,
  90.00, 20.00, 'EUR'
FROM users u
WHERE u.first_name = 'Anna' AND u.last_name = 'Hostmann'
RETURNING listing_id;

INSERT INTO bookings (
  listing_id, guest_id, check_in_date, check_out_date,
  num_guests, status_id, total_price, service_fee, currency_code
)
SELECT
  (SELECT listing_id
   FROM listings l
   JOIN users u ON u.user_id = l.host_id
   WHERE u.first_name='Anna' AND u.last_name='Hostmann'
   ORDER BY l.listing_id DESC
   LIMIT 1),
  (SELECT user_id FROM users WHERE first_name='Max' AND last_name='Mustermann' LIMIT 1),
  '2026-02-10', '2026-02-13',
  1, 1, 270.00, 15.00, 'EUR'
RETURNING booking_id;

INSERT INTO messages (booking_id, sender_id, recipient_id, message_text)
SELECT
  b.booking_id,
  b.guest_id,
  l.host_id,
  'Hi Anna, what is the easiest way to get the key?'
FROM bookings b
JOIN listings l ON l.listing_id = b.listing_id
WHERE b.guest_id <> l.host_id
ORDER BY b.booking_id DESC
LIMIT 1;

SELECT *
FROM messages
ORDER BY message_id DESC
LIMIT 1;

-- Table booking_status
INSERT INTO booking_status (status_name)
VALUES ('CONFIRMED');

SELECT * FROM booking_status WHERE status_name = 'CONFIRMED';

-- Table reviews
INSERT INTO reviews (
  booking_id, reviewer_id, reviewee_user_id, review_type,
  rating_overall, rating_cleanliness, rating_communication, comment
)
SELECT
    b.booking_id,
    u_guest.user_id AS reviewer_id,
    l.host_id       AS reviewee_user_id,
    'GUEST_TO_HOST',
    5, 5, 5,
    'Great host, smooth check-in and very responsive.'
FROM bookings b
JOIN users u_guest ON u_guest.user_id = b.guest_id
JOIN listings l ON l.listing_id = b.listing_id
WHERE u_guest.first_name = 'Max'
  AND u_guest.last_name  = 'Mustermann'
ORDER BY b.booking_id DESC
LIMIT 1;

SELECT *
FROM reviews
ORDER BY review_id DESC;

-- Table payment_methods
INSERT INTO payment_methods (method_name, provider, is_active)
VALUES ('CREDIT_CARD', 'VISA', TRUE);

SELECT * FROM payment_methods WHERE method_name = 'CREDIT_CARD';

-- Table currencies
INSERT INTO currencies (currency_code, currency_name, symbol)
VALUES ('HKG', 'Hong Kong Dollar', '$')
ON CONFLICT (currency_code) DO NOTHING;

SELECT * FROM currencies WHERE currency_code = 'HKG';
