-- 1. Add column to track the assigned delivery person
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_person uuid REFERENCES auth.users(id);

-- 2. Add column to track delivery status (e.g., 'pending', 'assigned', 'out_for_delivery', 'delivered')
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_status text DEFAULT 'pending';

-- 3. Ensure the profiles table has a role column so we can distinguish 'delivery' users
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role text DEFAULT 'user';

-- 4. Enable RLS for profiles just in case
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 5. Allow everyone to view profiles (needed so Admin can see list of delivery people)
CREATE POLICY "Public profiles are viewable by everyone" 
ON profiles FOR SELECT 
USING (true);

-- 6. Allow users to update their own profile
CREATE POLICY "Users can insert their own profile" 
ON profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE 
USING (auth.uid() = id);
