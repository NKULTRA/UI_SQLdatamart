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

    CONSTRAINT uq_payout_booking_host
        UNIQUE (booking_id, host_id)

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
-- --------------------------    user dimensions    ----------------------------
-- =============================================================================


