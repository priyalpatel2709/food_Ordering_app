# Database Schema Documentation

## Overview
This document describes the database schema for the Food Ordering Application using MongoDB.

## Collections

### 1. Users Collection
Stores customer and admin user information.

```javascript
{
  _id: ObjectId,
  firstName: String,
  lastName: String,
  email: String (unique, required),
  password: String (hashed, required),
  phone: String (unique),
  role: String (enum: ['customer', 'admin', 'staff'], default: 'customer'),
  avatar: String (URL),
  isEmailVerified: Boolean (default: false),
  isPhoneVerified: Boolean (default: false),
  isActive: Boolean (default: true),
  addresses: [{
    type: String (enum: ['home', 'work', 'other']),
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String,
    isDefault: Boolean,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  }],
  preferences: {
    notifications: {
      email: Boolean (default: true),
      sms: Boolean (default: true),
      push: Boolean (default: true)
    },
    dietary: [String] (e.g., ['vegetarian', 'vegan', 'gluten-free'])
  },
  refreshToken: String,
  resetPasswordToken: String,
  resetPasswordExpire: Date,
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `email` (unique)
- `phone` (unique)
- `createdAt`

---

### 2. Restaurants Collection
Stores restaurant information.

```javascript
{
  _id: ObjectId,
  name: String (required),
  description: String,
  logo: String (URL),
  coverImage: String (URL),
  phone: String (required),
  email: String,
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  operatingHours: [{
    day: String (enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
    openTime: String (HH:MM format),
    closeTime: String (HH:MM format),
    isClosed: Boolean (default: false)
  }],
  cuisine: [String] (e.g., ['Italian', 'Chinese', 'Indian']),
  deliveryRadius: Number (in kilometers),
  minimumOrder: Number,
  deliveryCharge: Number,
  packagingCharge: Number,
  taxPercentage: Number,
  averagePreparationTime: Number (in minutes),
  rating: {
    average: Number (default: 0),
    count: Number (default: 0)
  },
  isActive: Boolean (default: true),
  isFeatured: Boolean (default: false),
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `name`
- `isActive`
- `isFeatured`

---

### 3. Categories Collection
Menu item categories.

```javascript
{
  _id: ObjectId,
  name: String (required, unique),
  description: String,
  image: String (URL),
  icon: String (URL),
  displayOrder: Number (default: 0),
  isActive: Boolean (default: true),
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `name` (unique)
- `displayOrder`
- `isActive`

---

### 4. MenuItems Collection
Food items available for order.

```javascript
{
  _id: ObjectId,
  name: String (required),
  description: String,
  category: ObjectId (ref: 'Category', required),
  images: [String] (URLs),
  price: Number (required),
  discountedPrice: Number,
  preparationTime: Number (in minutes),
  isVegetarian: Boolean (default: false),
  isVegan: Boolean (default: false),
  isGlutenFree: Boolean (default: false),
  spiceLevel: String (enum: ['none', 'mild', 'medium', 'hot', 'extra-hot']),
  calories: Number,
  allergens: [String],
  ingredients: [String],
  nutritionalInfo: {
    protein: Number,
    carbs: Number,
    fat: Number,
    fiber: Number
  },
  isAvailable: Boolean (default: true),
  isFeatured: Boolean (default: false),
  isPopular: Boolean (default: false),
  rating: {
    average: Number (default: 0),
    count: Number (default: 0)
  },
  orderCount: Number (default: 0),
  tags: [String],
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `category`
- `name` (text index for search)
- `isAvailable`
- `isFeatured`
- `isPopular`
- `price`

---

### 5. Addons Collection
Additional items that can be added to menu items.

```javascript
{
  _id: ObjectId,
  name: String (required),
  description: String,
  price: Number (required),
  category: String (e.g., 'Extra Toppings', 'Sides', 'Drinks'),
  isAvailable: Boolean (default: true),
  applicableItems: [ObjectId] (ref: 'MenuItem'), // Empty array means applicable to all
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `name`
- `isAvailable`

---

### 6. Orders Collection
Customer orders.

```javascript
{
  _id: ObjectId,
  orderNumber: String (unique, auto-generated),
  customer: ObjectId (ref: 'User', required),
  items: [{
    menuItem: ObjectId (ref: 'MenuItem'),
    name: String,
    price: Number,
    quantity: Number,
    addons: [{
      addon: ObjectId (ref: 'Addon'),
      name: String,
      price: Number
    }],
    specialInstructions: String,
    subtotal: Number
  }],
  deliveryAddress: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  orderType: String (enum: ['delivery', 'pickup'], required),
  status: String (enum: ['pending', 'confirmed', 'preparing', 'ready', 'out-for-delivery', 'delivered', 'cancelled'], default: 'pending'),
  statusHistory: [{
    status: String,
    timestamp: Date,
    note: String
  }],
  pricing: {
    subtotal: Number,
    tax: Number,
    deliveryCharge: Number,
    packagingCharge: Number,
    discount: Number,
    total: Number
  },
  payment: {
    method: String (enum: ['cash', 'card', 'upi', 'wallet']),
    status: String (enum: ['pending', 'completed', 'failed', 'refunded']),
    transactionId: String,
    paidAt: Date
  },
  promoCode: String,
  scheduledFor: Date,
  estimatedDeliveryTime: Date,
  actualDeliveryTime: Date,
  preparationTime: Number (in minutes),
  rating: {
    food: Number (1-5),
    delivery: Number (1-5),
    overall: Number (1-5),
    comment: String,
    ratedAt: Date
  },
  cancellationReason: String,
  cancelledBy: String (enum: ['customer', 'restaurant', 'system']),
  cancelledAt: Date,
  notes: String,
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `orderNumber` (unique)
- `customer`
- `status`
- `orderType`
- `createdAt`
- `payment.status`

---

### 7. Payments Collection
Payment transaction records.

```javascript
{
  _id: ObjectId,
  order: ObjectId (ref: 'Order', required),
  customer: ObjectId (ref: 'User', required),
  amount: Number (required),
  currency: String (default: 'INR'),
  method: String (enum: ['cash', 'card', 'upi', 'wallet'], required),
  provider: String (e.g., 'stripe', 'razorpay'),
  transactionId: String (unique),
  status: String (enum: ['pending', 'processing', 'completed', 'failed', 'refunded'], default: 'pending'),
  gatewayResponse: Object,
  refundAmount: Number,
  refundReason: String,
  refundedAt: Date,
  metadata: Object,
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `order`
- `customer`
- `transactionId` (unique, sparse)
- `status`
- `createdAt`

---

### 8. Notifications Collection
User notifications.

```javascript
{
  _id: ObjectId,
  user: ObjectId (ref: 'User', required),
  type: String (enum: ['order', 'promotion', 'system'], required),
  title: String (required),
  message: String (required),
  data: Object,
  channels: {
    push: Boolean (default: false),
    email: Boolean (default: false),
    sms: Boolean (default: false)
  },
  status: {
    push: String (enum: ['pending', 'sent', 'failed']),
    email: String (enum: ['pending', 'sent', 'failed']),
    sms: String (enum: ['pending', 'sent', 'failed'])
  },
  isRead: Boolean (default: false),
  readAt: Date,
  expiresAt: Date,
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `user`
- `type`
- `isRead`
- `createdAt`
- `expiresAt` (TTL index)

---

### 9. PromoCodes Collection
Promotional discount codes.

```javascript
{
  _id: ObjectId,
  code: String (unique, required),
  description: String,
  type: String (enum: ['percentage', 'fixed'], required),
  value: Number (required),
  minOrderAmount: Number,
  maxDiscount: Number,
  usageLimit: Number,
  usageCount: Number (default: 0),
  perUserLimit: Number,
  validFrom: Date,
  validUntil: Date,
  applicableCategories: [ObjectId] (ref: 'Category'),
  applicableItems: [ObjectId] (ref: 'MenuItem'),
  isActive: Boolean (default: true),
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `code` (unique)
- `isActive`
- `validFrom`
- `validUntil`

---

### 10. Reviews Collection
Customer reviews and ratings.

```javascript
{
  _id: ObjectId,
  order: ObjectId (ref: 'Order', required),
  customer: ObjectId (ref: 'User', required),
  menuItem: ObjectId (ref: 'MenuItem'),
  rating: Number (1-5, required),
  comment: String,
  images: [String] (URLs),
  response: {
    message: String,
    respondedBy: ObjectId (ref: 'User'),
    respondedAt: Date
  },
  isVerified: Boolean (default: true),
  isPublished: Boolean (default: true),
  helpfulCount: Number (default: 0),
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**
- `order`
- `customer`
- `menuItem`
- `rating`
- `isPublished`
- `createdAt`

---

## Relationships

```
User (1) -----> (N) Orders
User (1) -----> (N) Notifications
User (1) -----> (N) Reviews

Category (1) -----> (N) MenuItems

MenuItem (1) -----> (N) OrderItems
MenuItem (1) -----> (N) Reviews

Order (1) -----> (1) Payment
Order (1) -----> (N) OrderItems
Order (1) -----> (1) Review

Addon (N) -----> (N) MenuItems
```

## Data Integrity Rules

1. **Cascading Deletes:**
   - When a User is deleted, anonymize their orders (don't delete)
   - When a MenuItem is deleted, mark it as unavailable (soft delete)
   - When a Category is deleted, reassign items to "Uncategorized"

2. **Validation Rules:**
   - Email must be unique and valid format
   - Phone must be unique and valid format
   - Order total must match sum of items + charges
   - Payment amount must match order total
   - Promo code must be valid and not expired

3. **Business Rules:**
   - Orders cannot be cancelled after "preparing" status
   - Refunds only allowed within 24 hours
   - Reviews only allowed for delivered orders
   - Minimum order amount must be met

## Indexing Strategy

- **Compound Indexes:**
  - `{ customer: 1, createdAt: -1 }` on Orders
  - `{ status: 1, createdAt: -1 }` on Orders
  - `{ category: 1, isAvailable: 1 }` on MenuItems

- **Text Indexes:**
  - `{ name: "text", description: "text" }` on MenuItems

- **Geospatial Indexes:**
  - `{ "address.coordinates": "2dsphere" }` on Restaurants
  - `{ "deliveryAddress.coordinates": "2dsphere" }` on Orders

## Backup Strategy

- Daily automated backups
- Point-in-time recovery enabled
- Backup retention: 30 days
- Test restore monthly
