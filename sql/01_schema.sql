-- ============================================================================
-- FILE: 01_schema.sql
-- PURPOSE: Logical separation of Airbnb tables within the database
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS airbnb;

SET search_path TO airbnb;

-- =============================================================================
-- ----------------------------    main tables    ------------------------------
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

-- Create listings table
CREATE TABLE listings (
    listing_id SERIAL PRIMARY KEY,
    host_id INTEGER NOT NULL,
    address_id INTEGER,
    property_type_id INTEGER,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    max_guests INTEGER NOT NULL CHECK (max_guests > 0),
    bedrooms INTEGER NOT NULL CHECK (bedrooms >= 0),
    beds INTEGER NOT NULL CHECK (beds >= 0),
    bathrooms INTEGER NOT NULL CHECK (bathrooms >= 0),
    base_price_per_night DECIMAL(10,2) NOT NULL CHECK (base_price_per_night >= 0),
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

-- Create bookings table
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    listing_id INTEGER NOT NULL,
    guest_id INTEGER NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    num_guests INTEGER NOT NULL CHECK(num_guests > 0),
    status_id INTEGER NOT NULL,
    total_price DECIMAL(10,2) NOT NULL CHECK(total_price >= 0),
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

-- Create payments table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    payment_method_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0),
    currency_code CHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL CHECK(status IN ('PENDING', 'COMPLETED', 'REFUNDED', 'FAILED')),
    paid_at TIMESTAMP,

    CONSTRAINT fk_payment_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings (booking_id),

    CONSTRAINT fk_payment_paymentmethod
            FOREIGN KEY (payment_method_id)
            REFERENCES payment_method (payment_method_id),

    CONSTRAINT fk_payment_currency
        FOREIGN KEY (currency_code)
        REFERENCES currencies (currency_code)
);

-- Create payouts table
CREATE TABLE payouts (
    payout_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    host_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0),
    currency_code CHAR(3) NOT NULL,
    scheduled_at DATE NOT NULL,
    status VARCHAR(30) NOT NULL CHECK(status IN ('SCHEDULED', 'PAID', 'FAILED')),

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

-- =============================================================================
-- -------------------------   overall dimensions    ---------------------------
-- =============================================================================


-- =============================================================================
-- --------------------------    user dimensions    ----------------------------
-- =============================================================================


-- Create user_contact table
CREATE TABLE user_contact (
    contact_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    type VARCHAR(20) NOT NULL CHECK(type IN ('phone', 'email')),
    value VARCHAR(255) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_user_contact_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT uq_user_contact
        UNIQUE (user_id, type, value)
);

-- Create roles table
CREATE TABLE roles (
    role_code VARCHAR(20) PRIMARY KEY,
    description TEXT,

    CONSTRAINT chk_role_code
            CHECK (role_code IN ('HOST', 'GUEST'))
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
    platform VARCHAR(50) NOT NULL CHECK (platform IN ('FACEBOOK', 'INSTAGRAM')),
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
    platform VARCHAR(50) NOT NULL CHECK (platform IN ('FACEBOOK', 'INSTAGRAM')),
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

-- =============================================================================
-- ------------------------    bookings dimensions    --------------------------
-- =============================================================================


-- Create reviews table
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL,
    reviewer_id INTEGER NOT NULL,
    reviewee_user_id INTEGER NOT NULL,
    review_type VARCHAR(30) NOT NULL CHECK(review_type IN ('GUEST_TO_HOST', 'HOST_TO_GUEST')),
    rating_overall INTEGER NOT NULL CHECK(rating_overall BETWEEN 1 AND 5),
    rating_cleanliness INTEGER CHECK(rating_cleanliness BETWEEN 1 AND 5),
    rating_communication INTEGER CHECK(rating_communication BETWEEN 1 AND 5),
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
