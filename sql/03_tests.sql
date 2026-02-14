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
WHERE l.listing_id = 21
  AND u.first_name = 'Max'
  AND u.last_name = 'Mustermann';



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