# Supabase Bucket Setup Guide

## Step 1: Create the Storage Bucket

1. **Go to your Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Select your project

2. **Navigate to Storage**
   - Click on "Storage" in the left sidebar
   - Click "Create a new bucket"

3. **Create the Bucket**
   - **Name**: `order-images`
   - **Public bucket**: ✅ Check this box (important!)
   - **File size limit**: 50MB (or your preferred limit)
   - Click "Create bucket"

## Step 2: Configure Storage Policies

### Policy 1: Allow Public Read Access
```sql
-- Go to SQL Editor in Supabase Dashboard and run this:
CREATE POLICY "Allow public read access" ON storage.objects
FOR SELECT USING (bucket_id = 'order-images');
```

### Policy 2: Allow Authenticated Uploads
```sql
-- Run this in SQL Editor:
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'order-images' AND auth.role() = 'authenticated');
```

### Policy 3: Allow Public Uploads (Alternative)
```sql
-- If you want to allow uploads without authentication:
CREATE POLICY "Allow public uploads" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'order-images');
```

## Step 3: Test the Setup

1. **Check Bucket Creation**
   - Go to Storage → order-images
   - You should see an empty bucket

2. **Test Upload via Dashboard**
   - Click "Upload file" in the bucket
   - Upload a test image
   - Verify it appears in the bucket

## Step 4: Verify App Configuration

Check your `main.dart` file has the correct Supabase credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

## Common Issues and Solutions

### Issue 1: "Bucket not found"
- **Solution**: Make sure the bucket name is exactly `order-images` (case sensitive)

### Issue 2: "Permission denied"
- **Solution**: Check that the bucket is set to "Public" and policies are configured

### Issue 3: "Authentication required"
- **Solution**: Use the public upload policy or implement authentication

### Issue 4: "File too large"
- **Solution**: Increase the file size limit in bucket settings

## Testing Steps

1. **Create the bucket** following Step 1
2. **Add the policies** following Step 2
3. **Test in the app** using the test button
4. **Upload images** and check the bucket

## Quick Test Commands

You can test the bucket setup by running these in the SQL Editor:

```sql
-- Check if bucket exists
SELECT * FROM storage.buckets WHERE id = 'order-images';

-- Check policies
SELECT * FROM storage.policies WHERE bucket_id = 'order-images';
```

## Troubleshooting

If you're still having issues:

1. **Check Supabase URL and Key** in your `main.dart`
2. **Verify bucket name** is exactly `order-images`
3. **Ensure bucket is public**
4. **Check storage policies** are applied
5. **Test with a simple file** first

## Support

If you need help:
1. Check the Supabase documentation
2. Verify your project settings
3. Test with the provided test button in the app 