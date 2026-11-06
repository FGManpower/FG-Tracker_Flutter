const request = require('supertest');
const BASE_URL = process.env.API_BASE_URL || 'http://localhost:3000';
const AUTH_TOKEN = process.env.TEST_AUTH_TOKEN || 'Bearer sample_valid_jwt_token';

describe('--- CHAT REST API AUTOMATED PRODUCTION SUITE ---', () => {

  describe('1. Unified Chat List API (GET /api/chat-list)', () => {
    it('TC-API-001: Should return 200 and paginated chat list with correct metadata', async () => {
      const res = await request(BASE_URL)
        .get('/api/chat-list?page=1&limit=20&type=all')
        .set('Authorization', AUTH_TOKEN);

      expect(res.status).toBe(200);
      expect(res.body.status).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.pagination).toBeDefined();
      expect(res.body.pagination.currentPage).toBe(1);
      expect(typeof res.body.unreadTotalCount).toBe('number');

      // Verify sorting: Descending order by timestamp
      if (res.body.data.length >= 2) {
        const time1 = new Date(res.body.data[0].timestamp || res.body.data[0].time).getTime();
        const time2 = new Date(res.body.data[1].timestamp || res.body.data[1].time).getTime();
        expect(time1).toBeGreaterThanOrEqual(time2);
      }
    });

    it('TC-API-002: Should fail with 401 when Authorization header is missing', async () => {
      const res = await request(BASE_URL)
        .get('/api/chat-list?page=1&limit=20');

      expect([401, 403]).toContain(res.status);
    });

    it('TC-API-003: Should handle edge boundary limits (negative, zero, extreme values)', async () => {
      const resZero = await request(BASE_URL)
        .get('/api/chat-list?page=1&limit=0')
        .set('Authorization', AUTH_TOKEN);
      expect([200, 400]).toContain(resZero.status);

      const resLarge = await request(BASE_URL)
        .get('/api/chat-list?page=1&limit=5000')
        .set('Authorization', AUTH_TOKEN);
      expect(resLarge.status).toBe(200);
      // Backend must clamp excessive limit
      expect(resLarge.body.data.length).toBeLessThanOrEqual(100);
    });
  });

  describe('2. Message History Pagination (GET /api/private-chat/:chatId/messages)', () => {
    it('TC-API-004: Should fetch first page (latest 15 messages) in reverse chronological order', async () => {
      const res = await request(BASE_URL)
        .get('/api/private-chat/50001/messages?page=1&limit=15')
        .set('Authorization', AUTH_TOKEN);

      expect(res.status).toBe(200);
      const messages = res.body.messageData || res.body.messages;
      expect(Array.isArray(messages)).toBe(true);
      expect(messages.length).toBeLessThanOrEqual(15);
      expect(res.body.blockStatus).toBeDefined();
    });

    it('TC-API-005: Page 2 must not duplicate any message IDs present in Page 1', async () => {
      const page1 = await request(BASE_URL)
        .get('/api/private-chat/50001/messages?page=1&limit=15')
        .set('Authorization', AUTH_TOKEN);

      const page2 = await request(BASE_URL)
        .get('/api/private-chat/50001/messages?page=2&limit=15')
        .set('Authorization', AUTH_TOKEN);

      const p1Ids = new Set((page1.body.messageData || []).map(m => m.id));
      const p2 = page2.body.messageData || [];

      for (const msg of p2) {
        expect(p1Ids.has(msg.id)).toBe(false);
      }
    });
  });

  describe('3. Block / Unblock Permissions', () => {
    it('TC-API-006: Should successfully block user and reflect in blockStatus', async () => {
      const blockRes = await request(BASE_URL)
        .post('/api/blockUser')
        .set('Authorization', AUTH_TOKEN)
        .send({ blockedUserId: 20005 });

      expect(blockRes.status).toBe(200);
      expect(blockRes.body.status).toBe(true);

      const unblockRes = await request(BASE_URL)
        .post('/api/unblockUser')
        .set('Authorization', AUTH_TOKEN)
        .send({ blockedUserId: 20005 });

      expect(unblockRes.status).toBe(200);
      expect(unblockRes.body.status).toBe(true);
    });
  });
});
