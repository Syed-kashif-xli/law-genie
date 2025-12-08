const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();


/**
 * Triggers when a new user signs up via Firebase Authentication.
 * Creates a corresponding user document in Firestore.
 * uses set({ ... }, { merge: true }) to prevent overwriting if it runs multiple times.
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
    const { uid, email, displayName, photoURL } = user;

    const userData = {
        email: email || "",
        displayName: displayName || "New User",
        photoURL: photoURL || "",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        role: "user", // Default role
        userId: uid,
    };

    try {
        // using set with merge: true ensures we don't accidentally wipe data if this re-runs
        await admin.firestore().collection("users").doc(uid).set(userData, { merge: true });
        console.log("User profile created for:", uid);
    } catch (error) {
        console.error("Error creating user profile:", error);
    }
});

exports.onNewsCreate = functions.firestore
    .document("news/{newsId}")
    .onCreate(async (snapshot, context) => {
        const newsData = snapshot.data();
        const title = newsData.title || "New Legal Update";
        const body = newsData.summary || "Check out the latest legal news.";
        const imageUrl = newsData.imageUrl || "";

        const payload = {
            notification: {
                title: title,
                body: body,
                image: imageUrl,
            },
            topic: "news",
        };

        try {
            await admin.messaging().send(payload);
            console.log("News notification sent successfully:", context.params.newsId);
        } catch (error) {
            console.error("Error sending news notification:", error);
        }
    });

/**
 * Triggers when a document in 'certified_copies' is updated.
 * Checks if 'previewUrl' or 'finalFileUrl' has been added/changed.
 * Sends a notification to the specific user via their FCM token.
 * NOTE: This requires storing the user's FCM token in a 'users/{userId}' document
 * or directly in the order document.
 * Assuming for now we rely on client-side monitoring or topic per user.
 * But to be robust, let's assume we subscribe user to their own topic 'user_{userId}'
 * OR we look up their token.
 * For simplicity and robustness without requiring token DB updates:
 * We will send to topic 'user_{userId}'.
 * CLIENT SIDE MUST SUBSCRIBE TO 'user_{userId}' in NotificationService.
 */
exports.onOrderUpdate = functions.firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        const userId = newData.userId;
        const orderId = context.params.orderId;

        if (!userId) {
            console.log(`No userId found for order ${orderId}, skipping notification.`);
            return;
        }

        let title = "";
        let body = "";

        // Check for Preview availability
        if (newData.previewUrl && newData.previewUrl !== oldData.previewUrl) {
            title = "Certified Copy Preview Available";
            body = "A preview of your certified copy is ready for review.";
        }

        // Check for Final File availability
        if (newData.finalFileUrl && newData.finalFileUrl !== oldData.finalFileUrl) {
            title = "Certified Copy Ready";
            body = "Your certified copy is ready for download.";
        }

        if (title && body) {
            const payload = {
                notification: {
                    title: title,
                    body: body,
                },
                topic: `user_${userId}`,
            };

            try {
                await admin.messaging().send(payload);
                console.log(`Notification sent to topic user_${userId} for order ${orderId}: ${title}`);
            } catch (error) {
                console.error(`Error sending notification for order ${orderId}:`, error);
            }
        } else {
            console.log(`No relevant changes detected for order ${orderId}.`);
        }
    });
