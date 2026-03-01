/**
 * Firebase Cloud Functions for Streak Management
 * 
 * Deploy with: firebase deploy --only functions
 */

import {onSchedule} from 'firebase-functions/v2/scheduler';
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
  async () => {
    const now = admin.firestore.Timestamp.now();
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    
    const yesterdayStart = new Date(yesterday.getFullYear(), yesterday.getMonth(), yesterday.getDate());

    // Get all users with active streaks
    const usersSnapshot = await db.collection('users')
      .where('streak', '>', 0)
      .get();

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
            });
          } catch (err) {
            console.error('Failed to send notification:', err);
          }
        }
      }
    }
    
    console.log(`Streak check complete. Processed ${usersSnapshot.docs.length} users.`);
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
  async () => {
    const today = new Date();
    const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const todayEnd = new Date(todayStart);
    todayEnd.setDate(todayEnd.getDate() + 1);

    // Get users who haven't posted today but have active streaks
    const usersSnapshot = await db.collection('users')
      .where('streak', '>', 0)
      .get();

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
            });
          } catch (err) {
            console.error('Failed to send notification:', err);
          }
        }
      }
    }

    console.log('Final warnings sent.');
  }
);
