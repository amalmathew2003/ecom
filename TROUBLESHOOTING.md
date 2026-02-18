# Quick Troubleshooting Guide

## Common Issues & Solutions

### 1. Order Placement Errors

#### Issue: "Order Error" after successful payment
**Cause:** Missing user profile information (address or phone)  
**Solution:**
- User must update profile with address and phone before checkout
- App now validates this before payment and guides users to profile screen

#### Issue: Database foreign key errors
**Cause:** Ambiguous foreign key relationships in orders table  
**Solution:**
- Use explicit relationship names in Supabase queries
- Example: `customer:profiles!user_id(full_name, email)`

---

### 2. Admin Order Management

#### Issue: Filter chips not working
**Status:** ✅ FIXED  
**Solution:** Implemented full filtering logic in controller

#### Issue: Orders not showing
**Cause:** Database schema mismatch  
**Solution:** App includes fallback queries that work with basic schema

---

### 3. Cart Issues

#### Issue: Cart not updating after quantity change
**Status:** ✅ FIXED (in previous updates)  
**Solution:** Using proper reactive state management with `.refresh()`

#### Issue: Stock validation not working
**Status:** ✅ WORKING  
**Solution:** Stock is validated on both increase and add to cart

---

### 4. Payment Integration

#### Issue: Razorpay not opening
**Cause:** Missing or incorrect API key  
**Solution:** 
- Verify `.env` file exists with `RAZORPAY_TEST_KEY`
- Ensure `flutter_dotenv` is loading properly

#### Issue: Payment success but order not created
**Cause:** Database insertion error  
**Solution:**
- Check all required fields are being sent
- Verify user profile has address and phone
- Check Supabase logs for specific error

---

### 5. Image Upload Issues

#### Issue: Product images not uploading
**Cause:** Storage bucket not configured  
**Solution:**
- Create `product-images` bucket in Supabase Storage
- Set proper permissions (public read, authenticated write)

---

### 6. Authentication Issues

#### Issue: Users redirected to wrong dashboard
**Cause:** Role not set in profiles table  
**Solution:**
- Ensure `role` column exists in profiles table
- Default role should be 'user' for new registrations

---

### 7. Build Issues

#### Issue: Build fails with dependency errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

#### Issue: "No issues found" but app crashes
**Solution:**
- Check Supabase connection
- Verify `.env` file is in project root
- Check database tables exist

---

## Database Setup Commands

### Create Orders Table (if missing columns)
```sql
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_address TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_phone TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS managed_by UUID REFERENCES profiles(id);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_person UUID REFERENCES profiles(id);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_status TEXT DEFAULT 'pending';
```

### Create Foreign Key Constraints
```sql
ALTER TABLE orders 
  ADD CONSTRAINT orders_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES profiles(id);

ALTER TABLE orders 
  ADD CONSTRAINT orders_managed_by_fkey 
  FOREIGN KEY (managed_by) REFERENCES profiles(id);

ALTER TABLE orders 
  ADD CONSTRAINT orders_delivery_person_fkey 
  FOREIGN KEY (delivery_person) REFERENCES profiles(id);
```

---

## Testing Checklist

### User Flow Testing
- [ ] Register new user
- [ ] Login
- [ ] Browse products
- [ ] Add to cart
- [ ] Update profile (address, phone)
- [ ] Checkout with COD
- [ ] Checkout with Razorpay
- [ ] View orders
- [ ] Cancel order

### Admin Flow Testing
- [ ] Login as admin
- [ ] View all orders
- [ ] Filter orders by status
- [ ] Update order status
- [ ] Assign delivery person
- [ ] Add new product
- [ ] Edit product
- [ ] Delete product

### Delivery Flow Testing
- [ ] Login as delivery person
- [ ] View assigned orders
- [ ] Update delivery status

---

## Performance Tips

1. **Pagination:** Implement for large product lists
2. **Caching:** Cache product images locally
3. **Lazy Loading:** Load order items on demand
4. **Debouncing:** Add debounce to search functionality
5. **Indexing:** Create database indexes on frequently queried columns

---

## Security Checklist

- [ ] Enable RLS on all Supabase tables
- [ ] Validate user input on both client and server
- [ ] Use environment variables for sensitive keys
- [ ] Implement rate limiting
- [ ] Add CAPTCHA for registration (optional)
- [ ] Use HTTPS for all API calls
- [ ] Sanitize user-generated content

---

## Deployment Steps

### 1. Prepare Environment
```bash
# Update version
# Edit pubspec.yaml: version: 1.0.0+1

# Clean build
flutter clean
flutter pub get
```

### 2. Build for Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle (for Play Store)
flutter build appbundle --release
```

### 3. Build for iOS
```bash
flutter build ios --release
```

### 4. Build for Web
```bash
flutter build web --release
```

---

## Environment Variables

### Development (.env)
```
RAZORPAY_TEST_KEY=rzp_test_S3fapdhsO8Bp4m
```

### Production (.env)
```
RAZORPAY_LIVE_KEY=rzp_live_YOUR_LIVE_KEY
```

---

## Monitoring & Analytics

### Recommended Tools
1. **Firebase Analytics** - User behavior tracking
2. **Sentry** - Error tracking
3. **Supabase Dashboard** - Database monitoring
4. **Google Analytics** - Web analytics

---

## Support Resources

- **Flutter Issues:** https://github.com/flutter/flutter/issues
- **Supabase Support:** https://supabase.com/support
- **GetX Documentation:** https://pub.dev/packages/get
- **Razorpay Support:** https://razorpay.com/support

---

**Last Updated:** February 9, 2026
