/**
 * PRODUCTION CHAT MODULE TEST DATA SEEDER
 * Generates:
 * - 1 Primary Test User (Target whose chat list will have 100+ chats)
 * - 120+ Private Chat Contacts
 * - 10+ Groups (including 2 large groups with 200+ members)
 * - 1000+ Messages in selected chats for pagination stress test
 * - Mixed message types (text, image, video, audio, document, location, contact, reply, edited, deleted)
 */

const mongoose = require('mongoose');

// DATABASE CONNECTION URI (Configurable via ENV)
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/fgtracker_chat_test';

// ------------------- SCHEMAS -------------------
const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  mobileNo: { type: String, required: true, unique: true },
  profileImage: { type: String, default: 'uploads/default_user.png' },
  isOnline: { type: Boolean, default: false },
  lastSeen: { type: Date, default: Date.now },
  createdAt: { type: Date, default: Date.now }
});

const ConversationSchema = new mongoose.Schema({
  chatType: { type: String, enum: ['private', 'group'], required: true },
  chatId: { type: Number, index: true },
  groupId: { type: Number, index: true },
  groupName: { type: String },
  groupProfile: { type: String },
  groupDesc: { type: String },
  creatorId: { type: Number },
  participants: [{
    userId: { type: Number, required: true },
    role: { type: String, default: 'member' },
    isPinned: { type: Boolean, default: false },
    pinnedAt: { type: Date },
    isMuted: { type: Boolean, default: false },
    isArchived: { type: Boolean, default: false },
    unreadCount: { type: Number, default: 0 }
  }],
  lastMessage: {
    messageId: { type: Number },
    senderId: { type: Number },
    messageType: { type: String, default: 'text' },
    content: { type: String },
    timestamp: { type: Date, default: Date.now },
    isDeletedForEveryone: { type: Boolean, default: false }
  },
  updatedAt: { type: Date, default: Date.now }
});

const MessageSchema = new mongoose.Schema({
  chatId: { type: Number, index: true },
  groupId: { type: Number, index: true },
  senderId: { type: Number, required: true, index: true },
  receiverId: { type: Number, index: true },
  messageType: {
    type: String,
    enum: ['text', 'image', 'video', 'audio', 'document', 'location', 'contact'],
    default: 'text'
  },
  content: { type: String, default: '' },
  images: [{ type: String }],
  videos: [{ videoUrl: String, thumbnail: String, duration: String }],
  caption: { type: String },
  replyId: { type: Number },
  replyMessage: { type: String },
  replyType: { type: String },
  replySenderName: { type: String },
  isEdited: { type: Boolean, default: false },
  editedAt: { type: Date },
  isDeleted: { type: Boolean, default: false },
  isDeletedForEveryone: { type: Boolean, default: false },
  isForwarded: { type: Boolean, default: false },
  status: { type: String, enum: ['sent', 'delivered', 'seen'], default: 'sent' },
  seenBy: [{ type: Number }],
  timestamp: { type: Date, default: Date.now, index: true }
});

const User = mongoose.model('User', UserSchema);
const Conversation = mongoose.model('Conversation', ConversationSchema);
const Message = mongoose.model('ChatMessage', MessageSchema);

async function seedDatabase() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(MONGO_URI);
    console.log('Connected! Purging previous chat test data...');

    await User.deleteMany({});
    await Conversation.deleteMany({});
    await Message.deleteMany({});

    console.log('--- 1. Creating Users ---');
    const primaryUserId = 10001;

    await User.create({
      _id: new mongoose.Types.ObjectId('64f000000000000000010001'),
      name: 'Primary QA Tester',
      mobileNo: '9999900001',
      profileImage: 'uploads/profiles/tester.jpg',
      isOnline: true
    });

    const peerUsers = [];
    for (let i = 1; i <= 250; i++) {
      const uId = 20000 + i;
      peerUsers.push({
        _id: new mongoose.Types.ObjectId(`64f0000000000000000${uId}`),
        name: `Test Contact ${i}`,
        mobileNo: `98888${String(i).padStart(5, '0')}`,
        profileImage: i % 4 === 0 ? '' : `uploads/profiles/user_${i}.jpg`,
        isOnline: i % 3 === 0,
        lastSeen: new Date(Date.now() - (i * 3600000))
      });
    }
    await User.insertMany(peerUsers);
    console.log(`Created Primary User (${primaryUserId}) + 250 Peer Contacts.`);

    console.log('--- 2. Seeding 100+ Private Conversations ---');
    const privateConversations = [];
    for (let i = 1; i <= 105; i++) {
      const peerId = 20000 + i;
      const chatId = 50000 + i;
      const isPinned = i <= 3;
      const isMuted = i === 4;
      const isArchived = i > 100;
      const unreadCount = i % 5 === 0 ? (i % 7) + 1 : 0;
      const lastMsgDate = new Date(Date.now() - (i * 120000));

      privateConversations.push({
        chatType: 'private',
        chatId: chatId,
        participants: [
          {
            userId: primaryUserId,
            role: 'member',
            isPinned: isPinned,
            pinnedAt: isPinned ? new Date() : null,
            isMuted: isMuted,
            isArchived: isArchived,
            unreadCount: unreadCount
          },
          {
            userId: peerId,
            role: 'member',
            unreadCount: 0
          }
        ],
        lastMessage: {
          messageId: 900000 + i,
          senderId: peerId,
          messageType: 'text',
          content: `Hey QA! This is message from Contact ${i}`,
          timestamp: lastMsgDate,
          isDeletedForEveryone: false
        },
        updatedAt: lastMsgDate
      });
    }
    await Conversation.insertMany(privateConversations);
    console.log('Created 105 Private Conversations for Primary User.');

    console.log('--- 3. Seeding 10 Groups (Including 2 Large 200+ Member Groups) ---');
    const groupConversations = [];

    for (let g = 1; g <= 10; g++) {
      const gId = 70000 + g;
      const isLargeGroup = (g === 1 || g === 2);
      const memberCount = isLargeGroup ? 215 : 25;

      const groupMembers = [
        {
          userId: primaryUserId,
          role: g === 1 ? 'admin' : 'member',
          isPinned: g === 1,
          unreadCount: g % 2 === 0 ? 4 : 0
        }
      ];

      for (let m = 1; m <= memberCount; m++) {
        groupMembers.push({
          userId: 20000 + m,
          role: m === 1 ? 'admin' : 'member',
          unreadCount: 0
        });
      }

      const groupLastMsgDate = new Date(Date.now() - (g * 60000));

      groupConversations.push({
        chatType: 'group',
        groupId: gId,
        groupName: isLargeGroup ? `Enterprise Fleet Operations #${g} (200+ Members)` : `Local Operations Team #${g}`,
        groupProfile: `uploads/groups/group_${g}.jpg`,
        groupDesc: `Official group channel for QA load testing. Total members: ${memberCount + 1}`,
        creatorId: g === 1 ? primaryUserId : 20001,
        participants: groupMembers,
        lastMessage: {
          messageId: 800000 + g,
          senderId: 20001,
          messageType: 'text',
          content: `Status update posted in group #${g}`,
          timestamp: groupLastMsgDate
        },
        updatedAt: groupLastMsgDate
      });
    }
    await Conversation.insertMany(groupConversations);
    console.log('Created 10 Groups (Groups #70001 & #70002 contain 216 members each).');

    console.log('--- 4. Seeding 1,000+ Deep Message History for Stress & Pagination ---');
    const deepMessages = [];
    const baseTime = Date.now() - (1200 * 60000);

    for (let m = 1; m <= 1100; m++) {
      const isFromPrimary = m % 2 === 0;
      const sId = isFromPrimary ? primaryUserId : 20001;
      const rId = isFromPrimary ? 20001 : primaryUserId;
      const msgTime = new Date(baseTime + (m * 60000));

      let mType = 'text';
      let content = `Test Message #${m} - automated seed`;
      let images = [];
      let videos = [];
      let isEdited = false;
      let isDeleted = false;

      if (m % 50 === 0) {
        mType = 'image';
        content = 'Photo attachment';
        images = ['https://picsum.photos/800/600'];
      } else if (m % 100 === 0) {
        mType = 'video';
        content = 'Video clip';
        videos = [{ videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4', thumbnail: 'https://picsum.photos/300/200', duration: '0:15' }];
      } else if (m % 75 === 0) {
        mType = 'audio';
        content = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      } else if (m % 60 === 0) {
        isEdited = true;
        content = `Edited version of message #${m}`;
      } else if (m % 90 === 0) {
        isDeleted = true;
        content = 'This message was deleted';
      }

      deepMessages.push({
        chatId: 50001,
        senderId: sId,
        receiverId: rId,
        messageType: mType,
        content: content,
        images: images,
        videos: videos,
        isEdited: isEdited,
        editedAt: isEdited ? new Date(msgTime.getTime() + 30000) : null,
        isDeletedForEveryone: isDeleted,
        status: m > 1050 ? 'delivered' : 'seen',
        timestamp: msgTime
      });
    }

    await Message.insertMany(deepMessages);
    console.log('Successfully seeded 1,100 sequential messages in Chat #50001 for Pagination testing!');

    console.log('\n=========================================');
    console.log('✅ CHAT TEST DATASET SEEDED SUCCESSFULLY');
    console.log('=========================================');
    console.log(`- Primary User ID: ${primaryUserId}`);
    console.log(`- Total Chats in List: 115 (105 Private + 10 Groups)`);
    console.log(`- 200+ Member Groups: Group #70001 & #70002`);
    console.log(`- 1000+ Pagination Chat ID: 50001`);
    process.exit(0);
  } catch (err) {
    console.error('❌ SEEDING FAILED:', err);
    process.exit(1);
  }
}

seedDatabase();
