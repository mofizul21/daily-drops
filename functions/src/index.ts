/**
 * Firebase Cloud Functions for Streak Management
 *
 * Build: cd functions && npm run build
 * Deploy: firebase deploy --only functions
 */

import {onSchedule} from 'firebase-functions/v2/scheduler';
import {onRequest} from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

/**
 * Scheduled function to run every day at 9 PM
 * Checks for users at risk of losing their streak
 * and sends push notifications
 */
export const checkStreaksAndSendReminders = onSchedule(
  {
    schedule: '0 21 * * *', // Every day at 9 PM
    timeZone: 'UTC',
  },
  async (event) => {
    const now = admin.firestore.Timestamp.now();
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    const yesterdayStart = new Date(yesterday.getFullYear(), yesterday.getMonth(), yesterday.getDate());

    // Get all users with active streaks
    const usersSnapshot = await db.collection('users')
      .where('streak', '>', 0)
      .get();

    let notificationsSent = 0;
    let streaksReset = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const lastPostDate = userData.lastPostDate?.toDate();

      if (!lastPostDate) continue;

      const lastPostDay = new Date(lastPostDate.getFullYear(), lastPostDate.getMonth(), lastPostDate.getDate());
      const daysSinceLastPost = yesterdayStart.getTime() - lastPostDay.getTime();
      const daysDiff = Math.floor(daysSinceLastPost / (1000 * 60 * 60 * 24));

      // If user hasn't posted since before yesterday, reset streak
      if (daysDiff > 1) {
        await db.collection('users').doc(userDoc.id).update({
          streak: 0,
          streakResetAt: now,
        });
        streaksReset++;
      }
      // If user posted yesterday but not today, send reminder
      else if (daysDiff === 1) {
        const fcmToken = userData.fcmToken;
        if (fcmToken) {
          try {
            await admin.messaging().send({
              token: fcmToken,
              notification: {
                title: '🔥 Streak Alert!',
                body: `Don't lose your ${userData.streak}-day streak! Post a drop today.`,
              },
              data: {
                type: 'streak_warning',
                streak: userData.streak.toString(),
              },
              android: {
                priority: 'high',
                notification: {
                  channelId: 'streak_notifications',
                  sound: 'default',
                },
              },
              apns: {
                payload: {
                  aps: {
                    sound: 'default',
                  },
                },
              },
            });
            notificationsSent++;
          } catch (err) {
            console.error('Failed to send notification to user:', userDoc.id, err);
          }
        }
      }
    }

    console.log(`Streak check complete. Notifications sent: ${notificationsSent}, Streaks reset: ${streaksReset}`);
  }
);

/**
 * Scheduled function to run every day at 11:59 PM
 * Final warning before streak resets
 */
export const finalStreakWarning = onSchedule(
  {
    schedule: '59 23 * * *', // Every day at 11:59 PM
    timeZone: 'UTC',
  },
  async (event) => {
    const today = new Date();
    const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const todayEnd = new Date(todayStart);
    todayEnd.setDate(todayEnd.getDate() + 1);

    // Get users who haven't posted today but have active streaks
    const usersSnapshot = await db.collection('users')
      .where('streak', '>', 0)
      .get();

    let warningsSent = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const lastPostDate = userData.lastPostDate?.toDate();

      if (!lastPostDate) continue;

      const lastPostDay = new Date(lastPostDate.getFullYear(), lastPostDate.getMonth(), lastPostDate.getDate());
      const isToday = lastPostDay.getTime() >= todayStart.getTime() && lastPostDay.getTime() < todayEnd.getTime();

      // If user hasn't posted today, send final warning
      if (!isToday) {
        const fcmToken = userData.fcmToken;
        if (fcmToken) {
          try {
            await admin.messaging().send({
              token: fcmToken,
              notification: {
                title: '⏰ Last Chance!',
                body: `Only minutes left to save your ${userData.streak}-day streak!`,
              },
              data: {
                type: 'streak_final_warning',
                streak: userData.streak.toString(),
              },
              android: {
                priority: 'high',
                notification: {
                  channelId: 'streak_notifications',
                  sound: 'default',
                },
              },
              apns: {
                payload: {
                  aps: {
                    sound: 'default',
                  },
                },
              },
            });
            warningsSent++;
          } catch (err) {
            console.error('Failed to send final warning to user:', userDoc.id, err);
          }
        }
      }
    }

    console.log(`Final warnings sent: ${warningsSent}`);
  }
);

/**
 * Test function to send a notification to the current user
 * Call with: curl -X POST https://us-central1-daily-drop-ed693.cloudfunctions.net/testStreakNotification?token=FCM_TOKEN
 */
export const testStreakNotification = onRequest(
  async (request, response) => {
    const testToken = request.query.token as string;
    
    if (!testToken) {
      response.status(400).send('Missing token parameter');
      return;
    }

    try {
      await admin.messaging().send({
        token: testToken,
        notification: {
          title: '🔥 Test Notification',
          body: 'This is a test streak notification!',
        },
        data: {
          type: 'test_notification',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'streak_notifications',
            sound: 'default',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      });
      
      response.status(200).send('Test notification sent successfully!');
    } catch (err) {
      console.error('Test notification failed:', err);
      response.status(500).send(`Failed to send test notification: ${err}`);
    }
  }
);
