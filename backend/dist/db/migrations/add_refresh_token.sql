-- Add refresh_token column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS refresh_token TEXT;

-- Add index for faster token lookups
CREATE INDEX IF NOT EXISTS idx_users_refresh_token ON users(refresh_token);

-- Add last_login column if it doesn't exist
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;
