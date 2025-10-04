# Supabase Image Storage Setup

This document explains how to set up Supabase for image storage in the project management app.

## Prerequisites

1. A Supabase project (already configured in main.dart)
2. Supabase Storage bucket for storing images

## Setup Steps

### 1. Create Storage Bucket

1. Go to your Supabase dashboard
2. Navigate to Storage in the left sidebar
3. Click "Create a new bucket"
4. Name the bucket: `order-images`
5. Set it as public (so images can be accessed via URLs)
6. Click "Create bucket"

### 2. Configure Storage Policies

You need to set up Row Level Security (RLS) policies for the storage bucket:

#### For Uploading Images:
```sql
-- Allow authenticated users to upload images
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

#### For Reading Images:
```sql
-- Allow public read access to images
CREATE POLICY "Allow public read access" ON storage.objects
FOR SELECT USING (bucket_id = 'order-images');
```

### 3. Test the Setup

1. Run the app
2. Navigate to `/test-image-upload` route
3. Try uploading some images
4. Check if they appear in the Supabase Storage dashboard

## Features Implemented

### Image Upload
- Users can select multiple images from their device
- Images are uploaded to Supabase Storage
- Maximum number of images is limited to the client's pieces number
- Images are stored with unique filenames

### Image Display
- Images are displayed in a horizontal scrollable gallery
- Tap on images to view them in full screen
- Images are cached for better performance

### Integration with Orders
- Images are associated with specific clients in orders
- Image URLs are stored in the order data
- Images can be viewed in the order details dialog

## File Structure

```
lib/
├── data/
│   ├── datasources/
│   │   └── supabase_storage_datasource.dart  # Supabase storage operations
│   └── models/
│       └── order_model.dart                   # Updated to include images
├── domain/
│   ├── entities/
│   │   └── order.dart                        # Updated to include images
│   └── usecases/
│       └── order_usecases.dart               # Added image upload use case
├── presentation/
│   ├── blocs/
│   │   └── order/
│   │       └── order_bloc.dart               # Added image upload events
│   ├── pages/
│   │   ├── client_orders_page.dart           # Updated to show images
│   │   └── test_image_upload_page.dart       # Test page for image upload
│   └── widgets/
│       ├── image_gallery_widget.dart         # Image gallery display
│       └── image_picker_widget.dart          # Image selection and upload
```

## Usage

### Adding Images to Client Orders

1. Navigate to a client's orders page
2. Tap on an order to view details
3. In the order details dialog, scroll to the "Images" section
4. Tap "Add Images" to select images from your device
5. Tap "Upload Images" to upload them to Supabase
6. Images will be displayed in the gallery

### Viewing Images

1. In the order details, tap on any image in the gallery
2. Images will open in full-screen mode
3. Swipe left/right to navigate between images
4. Use pinch gestures to zoom in/out

## Error Handling

The app includes comprehensive error handling:

- Clear error messages for upload failures
- Loading indicators during upload
- Graceful handling of network issues
- Validation of image file types and sizes

## Security Considerations

- Images are stored in a public bucket for easy access
- File names include timestamps to prevent conflicts
- Maximum image count is enforced per client
- Only authenticated users can upload images

## Future Enhancements

- Image compression before upload
- Support for different image formats
- Image deletion functionality
- Image editing capabilities
- Bulk image operations 