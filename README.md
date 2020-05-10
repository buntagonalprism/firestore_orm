# Firestore ORM

A wrapper around and extension to the [cloud_firestore](https://pub.dev/packages/cloud_firestore) library for using Firestore in Flutter. Firestore ORM adds a few additional features
- Built in object serializer and deserializer support that handle conversion of Firestore data types to expected JSON formats
- In-memory caching model to prevent recreating queries currently in use or recently used
- Use of DataStreams to provide cached data synchronously for a flicker-free UI loading 
- Background thread comparison of new data from Firestore with existing data to prevent unnecessary UI rebuilds
