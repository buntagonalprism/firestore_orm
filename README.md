# Firestore ORM

A wrapper around and extension to the [cloud_firestore](https://pub.dev/packages/cloud_firestore) library for using Firestore in Flutter. Firestore ORM provides the following features:
- Streamlined conversion of Firestore document data to Dart objects using JSON parsers
- Built-in conversion of Firestore data types to the types expected by [json_serializable](https://pub.dev/packages/json_serializable) parsers
- In-memory caching model that retains the data from recently-used queries
- Uses `DataStream` to provide cached data synchronously for a flicker-free UI on load 
- Compares fresh data from Firestore with the cache (on a background thread) to prevent unnecessary UI rebuilds
