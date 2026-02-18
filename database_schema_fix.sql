-- ============================================
-- DATABASE SCHEMA FIX FOR ORDER STATUS
-- ============================================
-- This SQL script fixes the order status column issue
-- Run this in your Supabase SQL Editor

-- Option 1: If you want to rename 'payment_status' to 'status'
-- (Recommended for new deployments)
-- ============================================

-- Step 1: Add new 'status' column if it doesn't exist
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS status TEXT;

-- Step 2: Copy data from payment_status to status (if payment_status exists)
UPDATE orders 
SET status = payment_status 
WHERE status IS NULL AND payment_status IS NOT NULL;

-- Step 3: Set default value for status
ALTER TABLE orders 
ALTER COLUMN status SET DEFAULT 'PENDING';

-- Step 4: Add check constraint for valid status values
ALTER TABLE orders 
DROP CONSTRAINT IF EXISTS chk_status;

ALTER TABLE orders 
ADD CONSTRAINT chk_status 
CHECK (status IN ('PENDING', 'SUCCESS', 'CANCELLED', 'FAILED', 'OUT_FOR_DELIVERY', 'DELIVERED'));

-- Step 5 (Optional): Drop old payment_status column after migration
-- ONLY run this after verifying all data is migrated correctly
-- ALTER TABLE orders DROP COLUMN IF EXISTS payment_status;


-- ============================================
-- Option 2: If you want to keep 'payment_status' column
-- (For backward compatibility)
-- ============================================

-- Just update the check constraint to allow the values we use
ALTER TABLE orders 
DROP CONSTRAINT IF EXISTS chk_payment_status;

ALTER TABLE orders 
ADD CONSTRAINT chk_payment_status 
CHECK (payment_status IN ('PENDING', 'SUCCESS', 'CANCELLED', 'FAILED', 'OUT_FOR_DELIVERY', 'DELIVERED'));


-- ============================================
-- ADDITIONAL RECOMMENDED COLUMNS
-- ============================================

-- Add managed_by column to track which admin updated the order
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS managed_by UUID REFERENCES profiles(id);

-- Add delivery_person column to assign delivery personnel
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_person UUID REFERENCES profiles(id);

-- Add delivery_status column to track delivery progress
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_status TEXT DEFAULT 'pending';

-- Add shipping_address column if not exists
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shipping_address TEXT;

-- Add customer_phone column if not exists
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS customer_phone TEXT;

-- Add payment_id column for online payment tracking
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS payment_id TEXT;

-- Add order_type column to distinguish CART vs BUY_NOW
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS order_type TEXT DEFAULT 'CART';

-- Add product_id for BUY_NOW orders
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS product_id UUID REFERENCES products(id);


-- ============================================
-- INDEXES FOR BETTER PERFORMANCE
-- ============================================

-- Index on user_id for faster user order queries
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);

-- Index on status for faster filtering
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- Index on payment_status (if keeping this column)
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);

-- Index on created_at for sorting
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);

-- Index on delivery_person for delivery personnel queries
CREATE INDEX IF NOT EXISTS idx_orders_delivery_person ON orders(delivery_person);


-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on orders table
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view their own orders" ON orders;
DROP POLICY IF EXISTS "Users can insert their own orders" ON orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON orders;
DROP POLICY IF EXISTS "Admins can update all orders" ON orders;

-- Allow users to view their own orders
CREATE POLICY "Users can view their own orders"
ON orders FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Allow users to insert their own orders
CREATE POLICY "Users can insert their own orders"
ON orders FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Allow admins to view all orders
-- Note: You need to set up a custom claim 'role' in your auth.users metadata
CREATE POLICY "Admins can view all orders"
ON orders FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'staff')
  )
);

-- Allow admins to update all orders
CREATE POLICY "Admins can update all orders"
ON orders FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'staff')
  )
);

-- Allow delivery personnel to view assigned orders
CREATE POLICY "Delivery can view assigned orders"
ON orders FOR SELECT
TO authenticated
USING (
  delivery_person = auth.uid()
  OR
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'delivery'
  )
);

-- Allow delivery personnel to update delivery status
CREATE POLICY "Delivery can update assigned orders"
ON orders FOR UPDATE
TO authenticated
USING (delivery_person = auth.uid());


-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check if status column exists
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'orders'
AND column_name IN ('status', 'payment_status');

-- Check constraints
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'orders';

-- View sample orders
SELECT id, user_id, amount, status, payment_status, created_at
FROM orders
ORDER BY created_at DESC
LIMIT 5;


-- ============================================
-- NOTES
-- ============================================
-- 1. The Flutter app now supports BOTH 'status' and 'payment_status' columns
-- 2. It will try 'status' first, then fall back to 'payment_status'
-- 3. Choose Option 1 (rename to 'status') for new deployments
-- 4. Choose Option 2 (keep 'payment_status') for existing deployments
-- 5. After running this script, test order creation and status updates
-- 6. Make sure to update RLS policies according to your security requirements
