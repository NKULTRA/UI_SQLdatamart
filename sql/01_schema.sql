-- ============================================================================
-- FILE: 01_schema.sql
-- PURPOSE: Logical separation of Airbnb tables within the database
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS airbnb;

SET search_path TO airbnb;


-- =============================================================================
-- -----------------------    base reference tables    -------------------------
-- =============================================================================


-- Create currencies table
CREATE TABLE currencies (
    currency_code CHAR(3) PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    symbol VARCHAR(10),

    CONSTRAINT chk_currency_code_uppercase
        CHECK (currency_code = UPPER(currency_code)),

    CONSTRAINT chk_currency_name_not_empty
        CHECK (trim(currency_name) <> ''),

    CONSTRAINT uq_currency_name
        UNIQUE (currency_name)
);

-- Create countries table
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    country_code CHAR(2) NOT NULL,

    CONSTRAINT chk_country_code_uppercase
        CHECK (country_code = UPPER(country_code)),

    CONSTRAINT chk_country_name_not_empty
        CHECK (trim(country_name) <> ''),

    CONSTRAINT uq_country_name
        UNIQUE (country_name)
);

-- Create roles table
CREATE TABLE roles (
    role_code VARCHAR(20) PRIMARY KEY,
    description TEXT
);

-- Create booking_status table
CREATE TABLE booking_status (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create property_types table
CREATE TABLE property_types (
    property_type_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,

    CONSTRAINT chk_property_name_not_empty
        CHECK (trim(name) <> ''),

    CONSTRAINT uq_property_name
        UNIQUE (name)
);

-- Create amenities table
CREATE TABLE amenities (
    amenity_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    CONSTRAINT chk_amenity_name_not_empty
        CHECK (trim(name) <> ''),

    CONSTRAINT uq_amenity_name
        UNIQUE (name)
);

-- Create payment_methods table
CREATE TABLE payment_methods (
    payment_method_id SERIAL PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL,
    provider VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uq_payment_method_name
        UNIQUE (method_name),

    CONSTRAINT chk_provider_not_empty
        CHECK (trim(provider) <> '')
);


-- =============================================================================
-- -----------------------    geographic dimensions    -------------------------
-- =============================================================================


-- Create cities table
CREATE TABLE cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_id INTEGER NOT NULL,

    CONSTRAINT chk_city_name_not_empty
        CHECK (trim(city_name) <> ''),

    CONSTRAINT uq_city_country
        UNIQUE (city_name, country_id),
        
    CONSTRAINT fk_city_country
        FOREIGN KEY (country_id)
        REFERENCES countries (country_id)
);

-- Create addresses table
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    street VARCHAR(200) NOT NULL,
    house_number VARCHAR(20) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city_id INTEGER NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,

    CONSTRAINT chk_address_street_not_empty
        CHECK (trim(street) <> ''),

    CONSTRAINT chk_address_house_number_not_empty
        CHECK (trim(house_number) <> ''),

    CONSTRAINT chk_address_postal_code_not_empty
        CHECK (trim(postal_code) <> ''),

    CONSTRAINT chk_address_latitude_range
        CHECK (latitude BETWEEN -90 AND 90),

    CONSTRAINT chk_address_longitude_range
        CHECK (longitude BETWEEN -180 AND 180),

    CONSTRAINT uq_address_unique
        UNIQUE (street, house_number, postal_code, city_id), 

    CONSTRAINT fk_address_city
        FOREIGN KEY (city_id)
        REFERENCES cities (city_id)
);


-- =============================================================================
-- --------------------------    core user table    ----------------------------
-- =============================================================================


-- Create users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country_id INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    default_currency_code CHAR(3),

    CONSTRAINT fk_users_country
        FOREIGN KEY (country_id)
        REFERENCES countries (country_id),

    CONSTRAINT fk_users_currency
        FOREIGN KEY (default_currency_code)
        REFERENCES currencies (currency_code)
);


-- =============================================================================
-- --------------------------    user dimensions    ----------------------------
-- =============================================================================


-- Create user_contact table
CREATE TABLE user_contact (
    contact_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    type VARCHAR(20) NOT NULL 
        CHECK(type IN ('phone', 'email')),
    value VARCHAR(255) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_user_contact_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT uq_user_contact
        UNIQUE (user_id, type, value)
);

-- Create user_roles table
CREATE TABLE user_roles (
    user_id INTEGER NOT NULL,
    role_code VARCHAR(20) NOT NULL,

    CONSTRAINT pk_user_roles
        PRIMARY KEY (user_id, role_code),

    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_code)
        REFERENCES roles (role_code)       
);

-- Create user_photos table
CREATE TABLE user_photos (
    photo_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    photo_url VARCHAR(500) NOT NULL,
    is_profile_photo BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_photos_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
);

-- Create user_social_account table
CREATE TABLE user_social_account (
    social_account_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    platform VARCHAR(50) NOT NULL 
        CHECK (platform IN ('FACEBOOK', 'INSTAGRAM')),
    external_id VARCHAR(500) NOT NULL,
    connected_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_social_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
);

-- Create user_social_account table
CREATE TABLE user_social_connections (
    connection_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    connected_user_id INTEGER NOT NULL,
    platform VARCHAR(50) NOT NULL 
        CHECK (platform IN ('FACEBOOK', 'INSTAGRAM')),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_connect_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_user_connected_user
        FOREIGN KEY (connected_user_id)
        REFERENCES users (user_id),

    CONSTRAINT chk_not_self
        CHECK (user_id <> connected_user_id)
);

-- Create wishlists table
CREATE TABLE wishlists (
    wishlist_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_wishlist_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
);


-- =============================================================================
-- ---------------------------    listings table    ----------------------------
-- =============================================================================


-- Create listings table
CREATE TABLE listings (
    listing_id SERIAL PRIMARY KEY,
    host_id INTEGER NOT NULL,
    address_id INTEGER,
    property_type_id INTEGER,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    max_guests INTEGER NOT NULL 
        CHECK (max_guests > 0),
    bedrooms INTEGER NOT NULL 
        CHECK (bedrooms >= 0),
    beds INTEGER NOT NULL 
        CHECK (beds >= 0),
    bathrooms INTEGER NOT NULL 
        CHECK (bathrooms >= 0),
    base_price_per_night DECIMAL(10,2) NOT NULL 
        CHECK (base_price_per_night >= 0),
    cleaning_fee DECIMAL(10,2),
    currency_code CHAR(3) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_listing_user
        FOREIGN KEY (host_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_listing_address
            FOREIGN KEY (address_id)
            REFERENCES addresses (address_id),
     
    CONSTRAINT fk_listing_property
            FOREIGN KEY (property_type_id)
            REFERENCES property_types (property_type_id),

    CONSTRAINT fk_listing_currency
        FOREIGN KEY (currency_code)
        REFERENCES currencies (currency_code)
);


-- =============================================================================
-- ------------------------    listings dimensions    --------------------------
-- =============================================================================


-- Create listing_amenities table
CREATE TABLE listing_amenities (
    amenity_id INTEGER NOT NULL,
    listing_id INTEGER NOT NULL,

    CONSTRAINT pk_listing_amenities
        PRIMARY KEY (listing_id, amenity_id),

    CONSTRAINT fk_listing_amenities_amenity
        FOREIGN KEY (amenity_id)
        REFERENCES amenities (amenity_id),

    CONSTRAINT fk_listing_amenities_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (listing_id)       
);


-- Create house_rules table
CREATE TABLE house_rules (
    rule_id SERIAL PRIMARY KEY,
    listing_id INTEGER NOT NULL,
    rule_text TEXT NOT NULL,
    rule_type VARCHAR(50) NOT NULL 
        CHECK (rule_type IN ('CHECK_IN', 'CHECK_OUT', 'SMOKING', 'PETS', 'PARTY', 'NOISE', 'OTHER')),

    CONSTRAINT uq_listing_rule_type
        UNIQUE (listing_id, rule_type),

    CONSTRAINT fk_house_rules_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (listing_id)    
);

-- Create listing_calendar table
CREATE TABLE listing_calendar (
    listing_id INTEGER NOT NULL,
    date DATE NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL
        CHECK (price_per_night >= 0),
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    min_nights INTEGER,
    max_nights INTEGER,

    CONSTRAINT pk_listing_calendar_listing
        PRIMARY KEY (listing_id, date),

    CONSTRAINT fk_listing_calendar_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (listing_id),

    CONSTRAINT chk_listing_calendar_nights
        CHECK (
            (min_nights IS NULL OR min_nights > 0)
            AND (max_nights IS NULL OR max_nights > 0)
            AND (min_nights IS NULL OR max_nights IS NULL OR min_nights <= max_nights)
        )
);

-- Create images table
CREATE TABLE images (
    image_id SERIAL PRIMARY KEY,
    listing_id INTEGER NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_images_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (listing_id)    
);

-- Create wishlist_items table
CREATE TABLE wishlist_items (
    wishlist_id INTEGER NOT NULL,
    listing_id INTEGER NOT NULL,

    CONSTRAINT pk_wishlist_items
        PRIMARY KEY (wishlist_id, listing_id),

    CONSTRAINT fk_wishlist_items_wishlist
        FOREIGN KEY (wishlist_id)
        REFERENCES wishlists (wishlist_id),

    CONSTRAINT fk_wishlist_items_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (listing_id)       
);


-- =============================================================================
-- --------------------------    bookings table    -----------------------------
-- =============================================================================


-- Create bookings table
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    listing_id INTEGER NOT NULL,
    guest_id INTEGER NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    num_guests INTEGER NOT NULL 
        CHECK(num_guests > 0),
    status_id INTEGER NOT NULL,
    total_price DECIMAL(10,2) NOT NULL 
        CHECK(total_price >= 0),
    service_fee DECIMAL(10,2) CHECK(service_fee >= 0),
    currency_code CHAR(3) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_booking_dates
        CHECK (check_out_date > check_in_date),

    CONSTRAINT fk_booking_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (listing_id),

    CONSTRAINT fk_booking_user
            FOREIGN KEY (guest_id)
            REFERENCES users (user_id),
     
    CONSTRAINT fk_booking_status
            FOREIGN KEY (status_id)
            REFERENCES booking_status (status_id),

    CONSTRAINT fk_booking_currency
        FOREIGN KEY (currency_code)
        REFERENCES currencies (currency_code)
);


-- =============================================================================
-- ---------------------------    booking related   ----------------------------
-- =============================================================================


-- Create payments table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    payment_method_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0),
    currency_code CHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL 
        CHECK(status IN ('PENDING', 'COMPLETED', 'REFUNDED', 'FAILED')),
    paid_at TIMESTAMP,

    CONSTRAINT fk_payment_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings (booking_id),

    CONSTRAINT fk_payment_paymentmethod
            FOREIGN KEY (payment_method_id)
            REFERENCES payment_methods (payment_method_id),

    CONSTRAINT fk_payment_currency
        FOREIGN KEY (currency_code)
        REFERENCES currencies (currency_code)
);

-- Create payouts table
CREATE TABLE payouts (
    payout_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    host_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL 
        CHECK(amount >= 0),
    currency_code CHAR(3) NOT NULL,
    scheduled_at DATE NOT NULL,
    status VARCHAR(30) NOT NULL 
        CHECK(status IN ('SCHEDULED', 'PAID', 'FAILED')),

    CONSTRAINT fk_payout_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings (booking_id),

    CONSTRAINT fk_payout_user
            FOREIGN KEY (host_id)
            REFERENCES users (user_id),

    CONSTRAINT fk_payout_currency
        FOREIGN KEY (currency_code)
        REFERENCES currencies (currency_code)
);

-- Create reviews table
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    reviewer_id INTEGER NOT NULL,
    reviewee_user_id INTEGER NOT NULL,
    review_type VARCHAR(30) NOT NULL 
        CHECK(review_type IN ('GUEST_TO_HOST', 'HOST_TO_GUEST')),
    rating_overall INTEGER NOT NULL 
        CHECK(rating_overall BETWEEN 1 AND 5),
    rating_cleanliness INTEGER 
        CHECK(rating_cleanliness BETWEEN 1 AND 5),
    rating_communication INTEGER 
        CHECK(rating_communication BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_review_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings (booking_id),

    CONSTRAINT fk_reviewer_user
            FOREIGN KEY (reviewer_id)
            REFERENCES users (user_id),

    CONSTRAINT fk_reviewee_user
            FOREIGN KEY (reviewee_user_id)
            REFERENCES users (user_id)
);

-- Create messages table
CREATE TABLE messages (
    message_id SERIAL PRIMARY KEY,
    booking_id INTEGER,
    sender_id INTEGER NOT NULL,
    recipient_id INTEGER NOT NULL,
    message_text TEXT NOT NULL,
    sent_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_message_text_not_empty
        CHECK (trim(message_text) <> ''),

    CONSTRAINT chk_message_not_self
        CHECK (sender_id <> recipient_id),

    CONSTRAINT fk_messages_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings (booking_id),

    CONSTRAINT fk_sender_user
        FOREIGN KEY (sender_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_recipient_user
        FOREIGN KEY (recipient_id)
        REFERENCES users (user_id)
);


-- =============================================================================
-- -----------------------    earnings simulation    ---------------------------
-- =============================================================================


-- Create earnings_simulation table
CREATE TABLE earnings_simulation (
    simulation_id SERIAL PRIMARY KEY,
    host_id INTEGER NOT NULL,
    listing_id INTEGER NOT NULL,
    date_from DATE NOT NULL,
    date_to DATE NOT NULL,
    estimated_net_income DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_earnings_sim_dates
        CHECK (date_to > date_from),

    CONSTRAINT fk_earnings_sim_users
        FOREIGN KEY (host_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_earnings_sim_listings
        FOREIGN KEY listing_id
        REFERENCES listings (listing_id)       
);

