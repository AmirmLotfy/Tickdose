/**
 * Cloud Functions for Tickdose App
 * 
 * These functions handle:
 * - Batch account deletion cleanup
 * - Caregiver notifications
 * - Data export/backup jobs
 * - Automated reports
 */

const {onCall, onDocumentCreated} = require('firebase-functions/v2/firestore');
const {onCall: onCallHttp} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const {getMessaging} = require('firebase-admin/messaging');

admin.initializeApp();

/**
 * Deletes all user data in batches (called when user account is deleted)
 * This is a callable function to be invoked from the client
 */
exports.deleteUserData = onCallHttp(async (request) => {
  const context = request.auth;
  // Verify authentication
  if (!context) {
    const {HttpsError} = require('firebase-functions/v2/https');
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to delete account'
    );
  }

  const userId = context.uid;

  try {
    const db = admin.firestore();
    const storage = admin.storage();
    const batch = db.batch();

    // Delete Firestore data in batches
    const collections = [
      'medicines',
      'reminders',
      'logs',
      'side_effects'
    ];

    for (const collectionName of collections) {
      const snapshot = await db
        .collection('users')
        .doc(userId)
        .collection(collectionName)
        .get();
      
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
    }

    // Delete I Feel conversations
    const conversationsSnapshot = await db
      .collection('iFeelConversations')
      .where('userId', '==', userId)
      .get();
    
    for (const doc of conversationsSnapshot.docs) {
      // Delete messages subcollection
      const messagesSnapshot = await doc.ref.collection('messages').get();
      messagesSnapshot.docs.forEach((msgDoc) => {
        batch.delete(msgDoc.ref);
      });
      batch.delete(doc.ref);
    }

    // Delete caregiver relationships
    const caregiversSnapshot = await db
      .collection('caregivers')
      .where('userId', '==', userId)
      .get();
    
    caregiversSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Delete caregiver invitations
    const invitationsSnapshot = await db
      .collection('caregiver_invitations')
      .where('userId', '==', userId)
      .get();
    
    invitationsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Delete user document
    batch.delete(db.collection('users').doc(userId));

    // Commit batch
    await batch.commit();

    // Delete Storage files
    const bucket = storage.bucket();
    
    // Delete user directory
    const userPath = `users/${userId}/`;
    const [files] = await bucket.getFiles({ prefix: userPath });
    await Promise.all(files.map((file) => file.delete()));

    // Delete voice recordings
    const voicePath = `voice/${userId}/`;
    const [voiceFiles] = await bucket.getFiles({ prefix: voicePath });
    await Promise.all(voiceFiles.map((file) => file.delete()));

    // Delete voice messages
    const voiceMessagesPath = `voice_messages/${userId}/`;
    const [voiceMessageFiles] = await bucket.getFiles({ prefix: voiceMessagesPath });
    await Promise.all(voiceMessageFiles.map((file) => file.delete()));

    return { success: true };
  } catch (error) {
    console.error('Error deleting user data:', error);
    const {HttpsError} = require('firebase-functions/v2/https');
    throw new HttpsError(
      'internal',
      'Failed to delete user data',
      error.message
    );
  }
});

/**
 * Triggers when a caregiver invitation is created
 * Sends FCM notification to caregiver if they have an account
 */
exports.onCaregiverInvitationCreated = onDocumentCreated(
  'caregiver_invitations/{invitationId}',
  async (event) => {
    const invitationData = event.data.data();
    const caregiverEmail = invitationData.caregiverEmail;
    const token = invitationData.token;
    const userId = invitationData.userId;

    if (!caregiverEmail || !token) {
      console.log('Invitation missing email or token');
      return null;
    }

    try {
      const db = admin.firestore();
      
      // Find user by email to check if they have an account
      const userSnapshot = await db
        .collection('users')
        .where('email', '==', caregiverEmail.toLowerCase())
        .limit(1)
        .get();

      if (userSnapshot.empty) {
        console.log(`No user found with email: ${caregiverEmail}`);
        return null;
      }

      const caregiverUserDoc = userSnapshot.docs[0];
      const caregiverUserId = caregiverUserDoc.id;
      const caregiverUserData = caregiverUserDoc.data();
      const fcmToken = caregiverUserData.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token found for caregiver: ${caregiverUserId}`);
        return null;
      }

      // Get patient's display name
      const patientDoc = await db.collection('users').doc(userId).get();
      const patientName = patientDoc.exists ? (patientDoc.data().displayName || 'Someone') : 'Someone';

      // Generate invitation URL
      const invitationUrl = `https://tickdose.app/invite?token=${token}`;

      // Send FCM notification
      const messaging = getMessaging();
      await messaging.send({
        token: fcmToken,
        notification: {
          title: 'New Caregiver Invitation',
          body: `${patientName} has invited you to be their caregiver`,
        },
        data: {
          type: 'caregiver_invitation',
          invitationToken: token,
          patientUserId: userId,
          patientName: patientName,
          invitationUrl: invitationUrl,
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'caregiver_invitations',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      });

      console.log(`FCM notification sent to caregiver: ${caregiverUserId}`);
    } catch (error) {
      console.error('Error sending FCM notification for invitation:', error);
      // Don't throw - invitation creation should still succeed
    }

    return null;
  }
);

/**
 * Triggers when a caregiver is assigned
 * Sends notification to caregiver
 */
exports.onCaregiverAssigned = onDocumentCreated(
  'caregivers/{caregiverId}',
  async (event) => {
    const caregiverRecord = event.data.data();
    const caregiverUserId = caregiverRecord.caregiverUserId;
    const userId = caregiverRecord.userId;

    if (!caregiverUserId) {
      console.log('No caregiverUserId found in caregiver data');
      return null;
    }

    try {
      const db = admin.firestore();
      const messaging = getMessaging();

      // Get patient's display name
      const patientDoc = await db.collection('users').doc(userId).get();
      const patientName = patientDoc.exists ? (patientDoc.data().displayName || 'Someone') : 'Someone';

      // Get caregiver's FCM token
      const caregiverDoc = await db.collection('users').doc(caregiverUserId).get();
      if (!caregiverDoc.exists) {
        console.log(`Caregiver user document not found: ${caregiverUserId}`);
        return null;
      }

      const caregiverUserData = caregiverDoc.data();
      const fcmToken = caregiverUserData.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token found for caregiver: ${caregiverUserId}`);
        return null;
      }

      // Send FCM notification to caregiver
      await messaging.send({
        token: fcmToken,
        notification: {
          title: 'Caregiver Assignment',
          body: `You have been assigned as a caregiver for ${patientName}`,
        },
        data: {
          type: 'caregiver_assigned',
          userId: userId,
          patientName: patientName,
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'caregiver_notifications',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      });

      console.log(`FCM notification sent to caregiver: ${caregiverUserId}`);
    } catch (error) {
      console.error('Error sending FCM notification for caregiver assignment:', error);
      // Don't throw - caregiver assignment should still succeed
    }

    return null;
  }
);

/**
 * Triggers when a medicine is missed
 * Notifies caregivers if configured
 */
exports.onMedicineMissed = onDocumentCreated(
  'users/{userId}/logs/{logId}',
  async (event) => {
    const logData = event.data.data();
    const userId = event.params.userId;
    
    if (logData.status !== 'missed') {
      return null;
    }

    try {
      const db = admin.firestore();
      const messaging = getMessaging();

      // Get user's display name and medicine name
      const userDoc = await db.collection('users').doc(userId).get();
      const userName = userDoc.exists ? (userDoc.data().displayName || 'Patient') : 'Patient';
      
      const medicineId = logData.medicineId;
      let medicineName = 'medicine';
      if (medicineId) {
        const medicineDoc = await db
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .doc(medicineId)
          .get();
        if (medicineDoc.exists) {
          medicineName = medicineDoc.data().name || 'medicine';
        }
      }

      // Get user's caregivers who should be notified
      const caregiversSnapshot = await db
        .collection('caregivers')
        .where('userId', '==', userId)
        .where('notifyOnMissed', '==', true)
        .get();

      if (caregiversSnapshot.empty) {
        console.log(`No caregivers to notify for user: ${userId}`);
        return null;
      }

      // Send FCM notifications to all caregivers
      const notificationPromises = caregiversSnapshot.docs.map(async (caregiverDoc) => {
        const caregiverData = caregiverDoc.data();
        const caregiverUserId = caregiverData.caregiverUserId;

        if (!caregiverUserId) {
          return null;
        }

        // Get caregiver's FCM token
        const caregiverUserDoc = await db.collection('users').doc(caregiverUserId).get();
        if (!caregiverUserDoc.exists) {
          console.log(`Caregiver user document not found: ${caregiverUserId}`);
          return null;
        }

        const caregiverUserData = caregiverUserDoc.data();
        const fcmToken = caregiverUserData.fcmToken;

        if (!fcmToken) {
          console.log(`No FCM token found for caregiver: ${caregiverUserId}`);
          return null;
        }

        // Send FCM notification
        try {
          await messaging.send({
            token: fcmToken,
            notification: {
              title: 'Medicine Missed',
              body: `${userName} missed their ${medicineName} dose`,
            },
            data: {
              type: 'medicine_missed',
              userId: userId,
              userName: userName,
              medicineId: medicineId || '',
              medicineName: medicineName,
              logId: event.params.logId,
            },
            android: {
              priority: 'high',
              notification: {
                channelId: 'caregiver_notifications',
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          });

          console.log(`FCM notification sent to caregiver: ${caregiverUserId}`);
          return true;
        } catch (error) {
          console.error(`Error sending FCM to caregiver ${caregiverUserId}:`, error);
          return false;
        }
      });

      await Promise.all(notificationPromises);
      console.log(`Medicine missed notifications sent to ${caregiversSnapshot.size} caregivers`);
    } catch (error) {
      console.error('Error processing medicine missed notification:', error);
      // Don't throw - log creation should still succeed
    }

    return null;
  }
);
