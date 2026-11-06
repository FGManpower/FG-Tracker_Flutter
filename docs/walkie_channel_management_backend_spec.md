# Walkie-Talkie Channel Management & Admin Alert — Backend Handoff Specification

## Executive Summary
This document provides the complete root-cause analysis, exact database queries, REST API contracts, and Socket.IO event specifications required from the **Backend Team** to complete the end-to-end functionality of the Walkie-Talkie Group Member Info & Admin Notification Alert feature.

The Flutter mobile application has completed and verified the entire UI and state management layer (fixed header layout, profile notification-off badges, 10-second countdown timer, and incoming alert dialogs). However, in live multi-device testing, parts of the feature remain incomplete because the **backend does not yet serve member channel preferences or forward admin alerts to offline/background devices via FCM Push Notifications**.

---

## 1. Why Requirements Appeared Incomplete in Testing

| # | Requirement | Frontend Status | Backend Root Cause | Impact on Real Devices |
|---|---|---|---|---|
| **1** | **Fixed Header Section** (Group name down to Group Members count fixed, only member list scrolls) | **Complete & Verified** | None (Client-side layout) | Fully working. Layout uses `Column` with `Flexible/ListView` to keep the header pinned while the member list scrolls smoothly underneath. |
| **2** | **Profile Notification-Off Badge** (Small red notification icon on avatar when member turned off notifications) | **Complete & Verified** | **Missing Data**: `GET /getMembers?groupId=$groupId` returns user rows from `Groupmembers` and `users`, but does **NOT** join or return `notifications_enabled` from `walkie_channel_preferences`. | Because the API returns `notifications_enabled: null` for remote members, the app cannot identify which members turned notifications off. Thus, the badge does not appear. |
| **3** | **Right-Side Notification Button** (Visible for members with notifications off; clickable only by Admin) | **Complete & Verified** | **Missing Data**: Linked to Requirement 2. Since `notifications_enabled` is not returned, the button cannot render for affected members. | Button is hidden because member channel status is unknown. |
| **4** | **Admin Sends Walkie Alert to Member** (Target user receives high-priority full-screen alert / heads-up notification with sound) | **Complete & Verified** | **Missing Endpoint & FCM Push Service**: The backend has no `POST /api/walkie/channels/:groupId/alert-member` endpoint, does not listen to socket event `admin_alert_walkie_member`, and does not dispatch FCM push notifications. | If the target member is in background or app is closed, they never receive any notification or wake-up alert. |
| **5** | **10-Second Timer for Admin** (Button converts to 10s countdown to prevent spam) | **Complete & Verified** | None (Client-side timer & lock) | Fully working. Tapping triggers a 10s non-retriggerable countdown with circular progress indicator. |

---

## 2. Backend Requirement 1: Return `notifications_enabled` in Group Members API

### The Problem
When the Walkie-Talkie screen loads members, it calls:
`GET /getMembers?groupId={groupId}` (or `GET /api/walkie/channels/:groupId/members`).
Currently, the backend SQL query does not join `walkie_channel_preferences`.

### Database Schema Reference
- `Groupmembers` (columns: `id`, `group_id`, `user_id`, `is_creator`, `role`, etc.)
- `users` (columns: `id`, `name`, `mobile_no`, `profile_image`, `is_online`, `last_seen`, etc.)
- `walkie_channel_preferences` (columns: `user_id`, `group_id`, `notifications_enabled`, `updated_at`)

### Required SQL Query Update
In your repository (e.g. `walkieChannel.repository.js` or `group.repository.js`):

```sql
SELECT 
    gm.id,
    gm.group_id AS groupId,
    gm.user_id AS userId,
    gm.is_creator AS isCreator,
    u.name AS name,
    u.mobile_no AS mobileNo,
    u.profile_image AS profileImage,
    u.is_online AS isOnline,
    u.last_seen AS lastSeen,
    u.chat_id AS chatId,
    -- CRITICAL ADDITION: Walkie notification preference for this specific group
    COALESCE(wcp.notifications_enabled, 1) AS notifications_enabled
FROM Groupmembers gm
INNER JOIN users u ON u.id = gm.user_id
LEFT JOIN walkie_channel_preferences wcp 
    ON wcp.user_id = gm.user_id AND wcp.group_id = gm.group_id
WHERE gm.group_id = :groupId
ORDER BY gm.is_creator DESC, u.name ASC;
```

> **Note**: If a member does not have an explicit row in `walkie_channel_preferences`, `COALESCE` defaults to `1` (enabled). If they turned it off, `notifications_enabled` is `0`.

### Required JSON Response Contract
```json
{
  "status": true,
  "message": "Group members fetched successfully",
  "memberData": [
    {
      "id": 12,
      "groupId": 168,
      "userId": 101,
      "name": "Alex Admin",
      "mobileNo": "+919876543210",
      "profileImage": "uploads/profiles/alex.jpg",
      "isCreator": true,
      "isOnline": true,
      "lastSeen": "2026-11-04T12:00:00.000Z",
      "chatId": 501,
      "notifications_enabled": 1
    },
    {
      "id": 13,
      "groupId": 168,
      "userId": 205,
      "name": "Sam Member",
      "mobileNo": "+919876543211",
      "profileImage": "uploads/profiles/sam.jpg",
      "isCreator": false,
      "isOnline": false,
      "lastSeen": "2026-11-04T11:45:00.000Z",
      "chatId": 502,
      "notifications_enabled": 0
    }
  ]
}
```

---

## 3. Backend Requirement 2: New Endpoint `POST /api/walkie/channels/:groupId/alert-member`

When an Admin taps the bell icon next to a member who has notifications turned off, the frontend makes an HTTP request to wake up and notify that member.

### Endpoint Details
- **Method**: `POST`
- **URL**: `/api/walkie/channels/:groupId/alert-member`
- **Headers**:
  - `Authorization: Bearer <Admin_User_Token>`
  - `Content-Type: application/json`

### Request Body
```json
{
  "groupId": "168",
  "targetUserId": "205",
  "adminId": "101"
}
```

### Backend Controller / Service Logic
1. **Authorization Check**:
   - Verify `adminId` is a creator/admin of `groupId`. If not, return HTTP `403 Forbidden` (`{ status: false, message: "Only group admins can send channel alerts" }`).
2. **Fetch Metadata**:
   - Fetch group name for `groupId`.
   - Fetch admin's display name (`adminName`) and profile image.
   - Fetch target user's FCM device push tokens.
3. **Real-Time Socket Emission (For Online / Foreground Devices)**:
   ```javascript
   const payload = {
     groupId: String(groupId),
     groupName: groupName,
     targetUserId: String(targetUserId),
     speakerId: String(adminId),
     speakerName: adminName,
     adminId: String(adminId),
     adminName: adminName,
     joinedCount: activeWalkieCount,
     timestamp: Date.now()
   };

   // Emit directly to target user's personal socket room
   io.to(`user_${targetUserId}`).emit('admin_alert_walkie_member', payload);
   io.to(`user_${targetUserId}`).emit('walkie_invite', payload);
   ```
4. **FCM Push Notification (For Background / Terminated Devices)**:
   This is critical. If the target member has the app closed, **only an FCM push notification can wake up their device**.
   
   **FCM Payload**:
   ```javascript
   const message = {
     token: targetUserFcmToken,
     notification: {
       title: `Walkie-Talkie: ${groupName}`,
       body: `${adminName} (Admin) is calling you into the channel.`
     },
     data: {
       type: "WALKIE_INVITE",
       groupId: String(groupId),
       groupName: groupName,
       speakerName: adminName,
       adminName: adminName,
       adminId: String(adminId),
       targetUserId: String(targetUserId),
       click_action: "FLUTTER_NOTIFICATION_CLICK"
     },
     android: {
       priority: "high",
       notification: {
         channelId: "walkie_call_channel",
         sound: "walkie_talkie",
         priority: "max",
         visibility: "public"
       }
     },
     apns: {
       headers: {
         "apns-priority": "10",
         "apns-push-type": "alert"
       },
       payload: {
         aps: {
           alert: {
             title: `Walkie-Talkie: ${groupName}`,
             body: `${adminName} (Admin) is calling you into the channel.`
           },
           sound: "walkie_talkie.caf",
           category: "walkie_invite_category", // Displays Accept & Cancel native buttons
           "content-available": 1
         }
       }
     }
   };

   await admin.messaging().send(message);
   ```
5. **Response**:
   ```json
   {
     "status": true,
     "message": "Alert notification successfully dispatched to member"
   }
   ```

---

## 4. Backend Requirement 3: Socket.IO Event Handlers

### 4.1 Admin Alert Event (`admin_alert_walkie_member`)
If the client emits via socket instead of REST:
```javascript
socket.on('admin_alert_walkie_member', async (data) => {
  try {
    const { groupId, targetUserId, adminId, groupName, speakerName } = data;
    if (!targetUserId || !groupId) return;

    // 1. Emit to target user's socket room
    io.to(`user_${targetUserId}`).emit('admin_alert_walkie_member', data);
    io.to(`user_${targetUserId}`).emit('walkie_invite', data);

    // 2. Dispatch FCM Push Notification (same helper as in REST endpoint)
    await sendWalkieFcmAlert(targetUserId, data);
  } catch (err) {
    console.error('Error handling admin_alert_walkie_member:', err);
  }
});
```

### 4.2 Real-Time Preference Sync (`walkie_member_notification_changed`)
When any user turns their channel notification ON or OFF (`PATCH /api/walkie/channels/:groupId/notifications`):
The backend should broadcast to the group socket room:
```javascript
io.to(`group_${groupId}`).emit('walkie_member_notification_changed', {
  groupId: parseInt(groupId),
  userId: parseInt(userId),
  notifications_enabled: enabled ? 1 : 0
});
```
This allows the Admin's device to instantly show or hide the notification bell icon without needing to close and re-open the Group Info sheet.

---

## 5. Summary Checklist for Backend Deployment

- [ ] **SQL Query**: Update `/getMembers?groupId=$groupId` (or `/walkie/channels/:groupId/members`) to `LEFT JOIN walkie_channel_preferences` and return `notifications_enabled` (0 or 1).
- [ ] **REST Endpoint**: Implement `POST /api/walkie/channels/:groupId/alert-member`.
- [ ] **FCM Push**: Ensure high-priority FCM notification is sent with `type: "WALKIE_INVITE"`, category `walkie_invite_category` (iOS), and channel `walkie_call_channel` (Android).
- [ ] **Socket Listener**: Bind `admin_alert_walkie_member` on socket server.
- [ ] **Socket Broadcast**: Emit `walkie_member_notification_changed` when channel notification preference is updated.
