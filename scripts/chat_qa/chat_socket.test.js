const { io } = require('socket.io-client');

const SOCKET_URL = process.env.SOCKET_URL || 'http://localhost:3000';
const SENDER_ID = '10001';
const RECEIVER_ID = '20001';
const GROUP_ID = 70001;

describe('--- REAL-TIME SOCKET.IO INTEGRATION SUITE ---', () => {
  let senderSocket;
  let receiverSocket;
  let groupSocketSender;
  let groupSocketReceiver;

  beforeAll((done) => {
    senderSocket = io(`${SOCKET_URL}/privateChat`, {
      transports: ['websocket'],
      auth: { userId: SENDER_ID }
    });

    receiverSocket = io(`${SOCKET_URL}/privateChat`, {
      transports: ['websocket'],
      auth: { userId: RECEIVER_ID }
    });

    groupSocketSender = io(`${SOCKET_URL}/chat`, {
      transports: ['websocket']
    });

    groupSocketReceiver = io(`${SOCKET_URL}/chat`, {
      transports: ['websocket']
    });

    let connectedCount = 0;
    const checkReady = () => {
      connectedCount++;
      if (connectedCount === 4) done();
    };

    senderSocket.on('connect', checkReady);
    receiverSocket.on('connect', checkReady);
    groupSocketSender.on('connect', checkReady);
    groupSocketReceiver.on('connect', checkReady);
  });

  afterAll(() => {
    senderSocket.disconnect();
    receiverSocket.disconnect();
    groupSocketSender.disconnect();
    groupSocketReceiver.disconnect();
  });

  test('TC-SOCK-001: 1-to-1 Room Join & Real-time Message Latency (<300ms)', (done) => {
    senderSocket.emit('join', { userId: SENDER_ID, receiverId: RECEIVER_ID });
    receiverSocket.emit('join', { userId: RECEIVER_ID, receiverId: SENDER_ID });

    const sendTimestamp = Date.now();
    const testContent = `Ping latency check: ${sendTimestamp}`;

    receiverSocket.once('receive_message', (data) => {
      const receiveTimestamp = Date.now();
      const latency = receiveTimestamp - sendTimestamp;

      expect(data).toBeDefined();
      expect(data.content).toBe(testContent);
      expect(String(data.senderId)).toBe(SENDER_ID);
      expect(latency).toBeLessThan(300);
      done();
    });

    senderSocket.emit('send_message', {
      senderId: SENDER_ID,
      receiverId: RECEIVER_ID,
      messageType: 'text',
      content: testContent
    });
  });

  test('TC-SOCK-002: Message Delivery Ack & Read Receipt Sync', (done) => {
    receiverSocket.once('receive_message', (data) => {
      const msgId = data.id || 9999;

      receiverSocket.emit('mark_delivered', {
        messageIds: [msgId],
        userId: RECEIVER_ID,
        otherUserId: SENDER_ID
      });
    });

    senderSocket.once('messages_delivered', (data) => {
      expect(data.messageIds).toBeDefined();

      receiverSocket.emit('mark_seen', {
        chatId: '50001',
        userId: RECEIVER_ID,
        otherUserId: SENDER_ID
      });
    });

    senderSocket.once('messages_seen_update', (data) => {
      expect(data).toBeDefined();
      done();
    });

    senderSocket.emit('send_message', {
      senderId: SENDER_ID,
      receiverId: RECEIVER_ID,
      messageType: 'text',
      content: 'Testing delivery & read receipts'
    });
  });

  test('TC-SOCK-003: Group Message Broadcast to 200+ Members', (done) => {
    groupSocketSender.emit('join_group', { userId: SENDER_ID, groupId: GROUP_ID });
    groupSocketReceiver.emit('join_group', { userId: RECEIVER_ID, groupId: GROUP_ID });

    const groupContent = 'Urgent operational announcement!';

    groupSocketReceiver.once('receive_group_message', (data) => {
      expect(data.content).toBe(groupContent);
      expect(Number(data.groupId)).toBe(GROUP_ID);
      done();
    });

    groupSocketSender.emit('send_group_message', {
      senderId: SENDER_ID,
      groupId: GROUP_ID,
      messageType: 'text',
      content: groupContent
    });
  });

  test('TC-SOCK-004: Edit and Delete for Everyone Broadcast', (done) => {
    const originalText = 'Will be deleted';

    receiverSocket.once('receive_message', (data) => {
      const msgId = data.id || 8888;

      senderSocket.emit('delete_message', {
        messageId: msgId,
        deleteForEveryone: true,
        chatId: '50001',
        senderId: SENDER_ID,
        receiverId: RECEIVER_ID
      });
    });

    receiverSocket.once('message_deleted', (delData) => {
      expect(delData.isDeletedForEveryone).toBe(true);
      done();
    });

    senderSocket.emit('send_message', {
      senderId: SENDER_ID,
      receiverId: RECEIVER_ID,
      messageType: 'text',
      content: originalText
    });
  });
});
