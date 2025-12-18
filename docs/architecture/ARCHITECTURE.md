# System Architecture

## Overview
The Food Ordering Application follows a modern, scalable microservices-inspired architecture with clear separation of concerns.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Flutter    │  │    Admin     │  │   Web App    │          │
│  │   Mobile     │  │    Panel     │  │  (Optional)  │          │
│  │     App      │  │   (React)    │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Load Balancer / CDN                         │
│                         (Nginx)                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API Gateway Layer                           │
├─────────────────────────────────────────────────────────────────┤
│  • Rate Limiting                                                 │
│  • Authentication                                                │
│  • Request Validation                                            │
│  • API Versioning                                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Application Layer                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │   Auth   │  │   Menu   │  │  Order   │  │   User   │       │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Payment  │  │  Notif.  │  │  Review  │  │  Promo   │       │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Data Layer                                  │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   MongoDB    │  │    Redis     │  │   AWS S3     │          │
│  │  (Primary)   │  │   (Cache)    │  │  (Storage)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   External Services                              │
├─────────────────────────────────────────────────────────────────┤
│  • Payment Gateways (Stripe, Razorpay)                          │
│  • Email Service (SMTP, SendGrid)                               │
│  • SMS Service (Twilio)                                          │
│  • Push Notifications (Firebase)                                │
│  • Maps API (Google Maps)                                       │
└─────────────────────────────────────────────────────────────────┘
```

## Frontend Architecture (Flutter)

### Clean Architecture Pattern

```
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                          │
│  • Pages (UI Components)                                         │
│  • Widgets (Reusable Components)                                 │
│  • BLoC (State Management)                                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Domain Layer                               │
│  • Entities (Business Models)                                    │
│  • Use Cases (Business Logic)                                    │
│  • Repository Interfaces                                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
│  • Models (Data Transfer Objects)                                │
│  • Repository Implementations                                    │
│  • Data Sources (Remote & Local)                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **BLoC Pattern (Business Logic Component)**
   - Separates business logic from UI
   - Reactive state management
   - Easy to test

2. **Dependency Injection**
   - Using get_it package
   - Centralized dependency management
   - Facilitates testing

3. **Repository Pattern**
   - Abstracts data sources
   - Single source of truth
   - Easy to switch implementations

## Backend Architecture (Node.js)

### Layered Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Routes Layer                                │
│  • Define API endpoints                                          │
│  • Route to controllers                                          │
│  • Apply middlewares                                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Controller Layer                              │
│  • Handle HTTP requests/responses                                │
│  • Input validation                                              │
│  • Call service layer                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Service Layer                                │
│  • Business logic implementation                                 │
│  • Transaction management                                        │
│  • Call external services                                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Model Layer                                 │
│  • Database schemas                                              │
│  • Data validation                                               │
│  • Database operations                                           │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Express.js Framework**
   - RESTful API design
   - Middleware pipeline
   - Error handling

2. **Mongoose ODM**
   - Schema definition
   - Validation
   - Query building

3. **JWT Authentication**
   - Stateless authentication
   - Access & refresh tokens
   - Role-based access control

## Data Flow

### Order Placement Flow

```
1. Customer (Flutter App)
   │
   ├─> Add items to cart (Local Storage)
   │
   ├─> Proceed to checkout
   │
   ├─> POST /api/v1/orders
   │   │
   │   ├─> Validate JWT token (Middleware)
   │   │
   │   ├─> Validate request body (Validator)
   │   │
   │   ├─> Order Controller
   │   │   │
   │   │   ├─> Order Service
   │   │   │   │
   │   │   │   ├─> Check item availability
   │   │   │   ├─> Calculate pricing
   │   │   │   ├─> Apply promo code
   │   │   │   ├─> Create order in DB
   │   │   │   ├─> Initiate payment
   │   │   │   └─> Send notifications
   │   │   │
   │   │   └─> Return order details
   │   │
   │   └─> HTTP 201 Response
   │
   ├─> Payment Gateway (Stripe/Razorpay)
   │   │
   │   └─> Webhook callback
   │       │
   │       ├─> Update order status
   │       └─> Send confirmation
   │
   └─> Real-time updates (Socket.io)
       │
       └─> Order status changes
```

## Security Architecture

### Authentication Flow

```
1. User Login
   │
   ├─> POST /api/v1/auth/login
   │   │
   │   ├─> Validate credentials
   │   │
   │   ├─> Generate JWT tokens
   │   │   ├─> Access Token (15min)
   │   │   └─> Refresh Token (30d)
   │   │
   │   └─> Return tokens
   │
2. API Request
   │
   ├─> Include Access Token in header
   │
   ├─> Verify token (Middleware)
   │   │
   │   ├─> Valid → Continue
   │   └─> Expired → Return 401
   │
3. Token Refresh
   │
   ├─> POST /api/v1/auth/refresh-token
   │
   ├─> Validate Refresh Token
   │
   └─> Issue new Access Token
```

### Security Layers

1. **Network Security**
   - HTTPS/TLS encryption
   - CORS configuration
   - Rate limiting

2. **Application Security**
   - Input validation
   - SQL/NoSQL injection prevention
   - XSS protection
   - CSRF protection

3. **Authentication & Authorization**
   - JWT tokens
   - Password hashing (bcrypt)
   - Role-based access control

4. **Data Security**
   - Encryption at rest
   - Encryption in transit
   - PII data protection

## Scalability Considerations

### Horizontal Scaling

```
┌─────────────┐
│Load Balancer│
└─────────────┘
       │
       ├─────────┬─────────┬─────────┐
       │         │         │         │
   ┌───▼───┐ ┌──▼────┐ ┌──▼────┐ ┌──▼────┐
   │API #1 │ │API #2 │ │API #3 │ │API #N │
   └───────┘ └───────┘ └───────┘ └───────┘
       │         │         │         │
       └─────────┴─────────┴─────────┘
                   │
            ┌──────▼──────┐
            │  MongoDB    │
            │  Replica    │
            │    Set      │
            └─────────────┘
```

### Caching Strategy

1. **Application-level Cache (Redis)**
   - Menu items
   - Restaurant info
   - User sessions
   - API responses

2. **Database Query Cache**
   - Frequently accessed queries
   - Aggregation results

3. **CDN Cache**
   - Static assets
   - Images
   - CSS/JS files

## Performance Optimization

### Backend Optimizations

1. **Database Indexing**
   - Compound indexes on frequently queried fields
   - Text indexes for search
   - Geospatial indexes for location queries

2. **Query Optimization**
   - Projection (select only needed fields)
   - Pagination
   - Aggregation pipelines

3. **Caching**
   - Redis for session storage
   - Cache frequently accessed data
   - Cache invalidation strategy

4. **Connection Pooling**
   - MongoDB connection pool
   - Redis connection pool

### Frontend Optimizations

1. **Code Splitting**
   - Lazy loading routes
   - Dynamic imports

2. **Image Optimization**
   - Cached network images
   - Lazy loading
   - Responsive images

3. **State Management**
   - Efficient BLoC usage
   - Minimize rebuilds

## Monitoring & Logging

### Application Monitoring

```
┌─────────────────────────────────────────────────────────────────┐
│                      Monitoring Stack                            │
├─────────────────────────────────────────────────────────────────┤
│  • Application Logs (Winston)                                    │
│  • Error Tracking (Sentry)                                       │
│  • Performance Monitoring (New Relic / DataDog)                  │
│  • Uptime Monitoring (Pingdom)                                   │
│  • Database Monitoring (MongoDB Atlas)                           │
└─────────────────────────────────────────────────────────────────┘
```

### Log Levels

- **ERROR**: Application errors, exceptions
- **WARN**: Warning messages, deprecated usage
- **INFO**: General information, API calls
- **DEBUG**: Detailed debugging information

## Deployment Architecture

### Production Environment

```
┌─────────────────────────────────────────────────────────────────┐
│                         Cloud Provider                           │
│                      (AWS / GCP / Azure)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │   App Server   │  │   App Server   │  │   App Server   │   │
│  │  (EC2/VM)      │  │  (EC2/VM)      │  │  (EC2/VM)      │   │
│  └────────────────┘  └────────────────┘  └────────────────┘   │
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │   MongoDB      │  │     Redis      │  │      S3        │   │
│  │  (Managed)     │  │   (Managed)    │  │   (Storage)    │   │
│  └────────────────┘  └────────────────┘  └────────────────┘   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              Load Balancer (ALB/NLB)                   │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Technology Stack Summary

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: BLoC
- **DI**: get_it
- **HTTP**: dio
- **Storage**: hive, shared_preferences
- **Navigation**: go_router

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: MongoDB
- **Cache**: Redis
- **Queue**: Bull
- **Auth**: JWT

### DevOps
- **Containerization**: Docker
- **Orchestration**: Docker Compose / Kubernetes
- **CI/CD**: GitHub Actions
- **Monitoring**: Winston, Sentry

## Future Enhancements

1. **Microservices Migration**
   - Split into independent services
   - Service mesh (Istio)
   - API Gateway (Kong)

2. **Event-Driven Architecture**
   - Message queue (RabbitMQ/Kafka)
   - Event sourcing
   - CQRS pattern

3. **Advanced Features**
   - Real-time order tracking
   - AI-powered recommendations
   - Voice ordering
   - AR menu preview
