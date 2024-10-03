///**
// * Import function triggers from their respective submodules:
// *
// * const {onCall} = require("firebase-functions/v2/https");
// * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
// *
// * See a full list of supported triggers at https://firebase.google.com/docs/functions
// */
//
//const {onRequest} = require("firebase-functions/v2/https");
//const logger = require("firebase-functions/logger");
//
//// Create and deploy your first functions
//// https://firebase.google.com/docs/functions/get-started
//
//// exports.helloWorld = onRequest((request, response) => {
////   logger.info("Hello logs!", {structuredData: true});
////   response.send("Hello from Firebase!");
//// });
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK to access storage
admin.initializeApp();
const { getStorage } = require('firebase-admin/storage');

// Run this function every hour
exports.scheduledFileDeletion = functions.pubsub.schedule('every 1 hours').onRun(async (context) => {
    const bucket = getStorage().bucket();

    // Get files in the "databases/" folder (or replace with your folder path)
    const [files] = await bucket.getFiles({
        prefix: 'databases/'  // Path to the folder in storage
    });

    const now = Date.now();  // Current time
    const oneHourInMs = 60 * 60 * 1000;  // One hour in milliseconds

    // Loop through files and delete those older than one hour
    files.forEach(async file => {
        const [metadata] = await file.getMetadata();
        const uploadTime = new Date(metadata.metadata.uploadTime).getTime();

        // Delete the file if it's older than an hour
        if ((now - uploadTime) > oneHourInMs) {
            console.log(`Deleting file: ${file.name}`);
            await file.delete();
        }
    });

    return null;
});
