-- ============================================
-- SIMPLIFIED ROLES & PREMIUM BRANDING SETUP
-- ============================================

-- 1. CLEAN UP ROLES
-- Only keep 'user' and 'admin'. Move everything else to 'user'.
UPDATE profiles 
SET role = 'user' 
WHERE role NOT IN ('user', 'admin');

-- 2. UPDATE RLS POLICIES FOR SIMPLICITY
DROP POLICY IF EXISTS "Admins can view all orders" ON orders;
DROP POLICY IF EXISTS "Admins can update all orders" ON orders;
DROP POLICY IF EXISTS "Delivery can view assigned orders" ON orders;
DROP POLICY IF EXISTS "Delivery can update assigned orders" ON orders;

-- Allow only admins to view and update all orders
CREATE POLICY "Admins can manage all orders"
ON orders FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'admin'
  )
);

-- 3. REMOVE STAFF/DELIVERY COLUMNS FROM ORDERS (Optional but cleaner)
-- ALTER TABLE orders DROP COLUMN IF EXISTS managed_by;
-- ALTER TABLE orders DROP COLUMN IF EXISTS delivery_person;
-- ALTER TABLE orders DROP COLUMN IF EXISTS delivery_status;

-- 4. ENSURE USER PROFILE CAN ONLY BE 'user' OR 'admin'
ALTER TABLE profiles 
DROP CONSTRAINT IF EXISTS chk_role;

ALTER TABLE profiles 
ADD CONSTRAINT chk_role 
CHECK (role IN ('user', 'admin'));

-- 5. INITIAL ADMIN SETUP (Run this with your user ID to make yourself admin)
-- UPDATE profiles SET role = 'admin' WHERE id = 'YOUR_USER_UUID';
