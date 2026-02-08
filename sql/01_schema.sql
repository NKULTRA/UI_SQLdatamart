-- ============================================================================
-- FILE: 01_schema.sql
-- PURPOSE: Logical separation of Airbnb tables within the database
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS airbnb;

SET search_path TO airbnb;
