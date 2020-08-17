library firestore_orm;

import 'dart:async';
import 'dart:convert';

import 'package:building_blocs/building_blocs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

export 'package:cloud_firestore/cloud_firestore.dart' show FieldPath, SetOptions;

part 'src/query.dart';
part 'src/firestore_cache.dart';
part 'src/firestore_orm.dart';
part 'src/document.dart';
part 'src/conversion.dart';
part 'src/transaction.dart';
part 'src/timestamps.dart';
