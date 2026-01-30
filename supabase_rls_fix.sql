-- Run this in your Supabase SQL Editor to fix the permission errors

-- 1. Enable RLS (Row Level Security) ensuring tables are protected
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- 2. ORDERS Table Policies
-- Allow authenticated users to create (insert) their own orders
CREATE POLICY "Enable insert for users based on user_id"
ON orders FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Allow users to view their own orders
CREATE POLICY "Enable select for users based on user_id"
ON orders FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Allow detailed update for delivery/admin if needed (optional, basic users usually don't update orders)


-- 3. ORDER_ITEMS Table Policies
-- Allow authenticated users to insert items for their orders
-- We check if the associated order belongs to the user
CREATE POLICY "Enable insert for order items"
ON order_items FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM orders
        WHERE id = order_items.order_id
        AND user_id = auth.uid()
    )
);

-- Allow users to view their own order items
CREATE POLICY "Enable select for order items"
ON order_items FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM orders
        WHERE id = order_items.order_id
        AND user_id = auth.uid()
    )
);

-- 4. DELIVERY/ADMIN Policies (If you have role-based access)
-- Example: Allow admins to view all orders
-- create policy "Admins can view all orders" on orders for select using ( get_my_claim('role') = 'admin' );
