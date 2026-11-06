import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 100 },  // Ramp-up to 100 users
    { duration: '1m', target: 500 },   // Stress test at 500 concurrent users
    { duration: '30s', target: 1000 }, // Peak burst at 1000 users
    { duration: '30s', target: 0 },    // Ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<800'], // 95% of requests must complete < 800ms
    http_req_failed: ['rate<0.01'],   // Error rate < 1%
  },
};

const BASE_URL = __ENV.API_BASE_URL || 'http://localhost:3000';
const AUTH_TOKEN = __ENV.AUTH_TOKEN || 'Bearer test_jwt_token_sample';

export default function () {
  const headers = {
    Authorization: AUTH_TOKEN,
    'Content-Type': 'application/json',
  };

  // 1. Fetch Chat List (100+ conversations)
  const chatListRes = http.get(`${BASE_URL}/api/chat-list?page=1&limit=20&type=all`, { headers });
  check(chatListRes, {
    'chat list status is 200': (r) => r.status === 200,
    'chat list response time < 800ms': (r) => r.timings.duration < 800,
  });

  sleep(1);

  // 2. Fetch Chat History (15 messages)
  const historyRes = http.get(`${BASE_URL}/api/private-chat/50001/messages?page=1&limit=15`, { headers });
  check(historyRes, {
    'history status is 200': (r) => r.status === 200,
    'history response time < 400ms': (r) => r.timings.duration < 400,
  });

  sleep(1);
}
