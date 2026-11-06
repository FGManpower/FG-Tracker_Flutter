# Chat Module Production QA & Testing Suite

This directory contains test scripts, database seeders, integration suites, and load testing scripts for certifying the Chat Module (Unified Listing + Chat Screen | Private + Group).

---

## 1. Prerequisites
- **Node.js**: v18+ or v20+
- **MongoDB**: Active connection (for `seed_chat_test_data.js`)
- **k6**: (Optional, for load testing) `brew install k6` or binary install

Install npm test dependencies:
```bash
cd scripts/chat_qa
npm init -y
npm install mongoose socket.io-client supertest jest dotenv
```

---

## 2. Seed Database with 100+ Chats & 1,000+ Messages
Generates:
- 1 Primary User (ID `10001`)
- 250 Contacts
- 105 Private Chats with staggered timestamps & unread badges
- 10 Groups (including Group #70001 & #70002 with 216 members each)
- 1,100 deep messages in Chat #50001 for upward scroll pagination testing

Run:
```bash
MONGO_URI="mongodb://localhost:27017/fgtracker_chat_test" node seed_chat_test_data.js
```

---

## 3. Run Automated REST API Tests
Verifies `/api/chat-list`, `/messages`, pagination overlap checks, block/unblock permissions:
```bash
API_BASE_URL="http://localhost:3000" TEST_AUTH_TOKEN="Bearer <YOUR_JWT>" npx jest chat_api.test.js
```

---

## 4. Run Real-time Socket.IO Tests
Verifies 1-to-1 message delivery, latency (<300ms SLA), double ticks (delivered + seen), 200+ member group broadcast, edit and delete for everyone:
```bash
SOCKET_URL="http://localhost:3000" npx jest chat_socket.test.js
```

---

## 5. Run Performance & Load Test (k6)
Simulates up to 1,000 concurrent users hitting chat list and message history:
```bash
API_BASE_URL="http://localhost:3000" AUTH_TOKEN="Bearer <YOUR_JWT>" k6 run k6_load_test.js
```
Expected SLA:
- Chat list p(95) < 800ms
- Chat screen history p(95) < 400ms
- Error rate < 1%
