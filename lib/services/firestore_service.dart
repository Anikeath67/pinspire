
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/pin.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  String get uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not signed in.');
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userRef {
    return _db.collection('users').doc(uid);
  }

  // ============================================================
  // SAVED / FAVORITES
  // ============================================================

  CollectionReference<Map<String, dynamic>> get favorites {
    return _userRef.collection('favorites');
  }

  Future<void> save(Pin pin) async {
    await favorites.doc(pin.id).set({
      ...pin.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> remove(String id) async {
    await favorites.doc(id).delete();
  }

  Future<bool> contains(String id) async {
    final doc = await favorites.doc(id).get();
    return doc.exists;
  }

  Stream<List<Pin>> watch() {
    return favorites
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Pin.fromMap(doc.data()),
          )
          .toList();
    });
  }

  Future<bool> isSaved(String pinId) async {
    final doc = await favorites.doc(pinId).get();
    return doc.exists;
  }

  Future<bool> toggleSave(Pin pin) async {
    final ref = favorites.doc(pin.id);
    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
      return false;
    }

    await ref.set({
      ...pin.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  Future<void> savePin(Pin pin) async {
    await favorites.doc(pin.id).set({
      ...pin.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unsavePin(String id) async {
    await favorites.doc(id).delete();
  }

  // ============================================================
  // LIKES
  // ============================================================

  CollectionReference<Map<String, dynamic>> get likes {
    return _userRef.collection('likes');
  }

  Future<bool> isLiked(String pinId) async {
    final doc = await likes.doc(pinId).get();
    return doc.exists;
  }

  Future<bool> toggleLike(Pin pin) async {
    final ref = likes.doc(pin.id);
    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
      return false;
    }

    await ref.set({
      ...pin.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return true;
  }

  Future<void> likePin(Pin pin) async {
    await likes.doc(pin.id).set({
      ...pin.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unlikePin(String pinId) async {
    await likes.doc(pinId).delete();
  }

  Stream<List<Pin>> watchLikes() {
    return likes
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Pin.fromMap(doc.data()),
          )
          .toList();
    });
  }

  // ============================================================
  // BOARDS
  // ============================================================

  CollectionReference<Map<String, dynamic>> get boards {
    return _userRef.collection('boards');
  }

  Future<String> createBoard(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw ArgumentError('Board name cannot be empty.');
    }

    final doc = await boards.add({
      'name': cleanName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getBoards() {
    return boards
        .orderBy('createdAt', descending: true)
        .get();
  }

  // ============================================================
  // ADD PIN TO BOARD
  // ============================================================

  Future<void> addToBoard(
    String boardId,
    Pin pin,
  ) async {
    await boards
        .doc(boardId)
        .collection('pins')
        .doc(pin.id)
        .set({
      ...pin.toMap(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REMOVE PIN FROM BOARD
  // ============================================================

  Future<void> removeFromBoard(
    String boardId,
    String pinId,
  ) async {
    await boards
        .doc(boardId)
        .collection('pins')
        .doc(pinId)
        .delete();
  }

  // ============================================================
  // CHECK PIN IN BOARD
  // ============================================================

  Future<bool> isInBoard(
    String boardId,
    String pinId,
  ) async {
    final doc = await boards
        .doc(boardId)
        .collection('pins')
        .doc(pinId)
        .get();

    return doc.exists;
  }

  // ============================================================
  // WATCH BOARD PINS
  // ============================================================

  Stream<List<Pin>> watchBoard(
    String boardId,
  ) {
    return boards
        .doc(boardId)
        .collection('pins')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Pin.fromMap(doc.data()),
          )
          .toList();
    });
  }

  // ============================================================
  // DELETE BOARD
  // ============================================================

  Future<void> deleteBoard(String boardId) async {
    final pins = await boards
        .doc(boardId)
        .collection('pins')
        .get();

    final batch = _db.batch();

    for (final doc in pins.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(boards.doc(boardId));

    await batch.commit();
  }

  // ============================================================
  // DOWNLOADS
  //
  // users/{uid}/downloads/{pinId}
  // ============================================================

  CollectionReference<Map<String, dynamic>> get downloads {
    return _userRef.collection('downloads');
  }

  /// Save a downloaded pin to Firestore.
  ///
  /// This does NOT download the actual image.
  /// DownloadService handles saving the image to the phone gallery.
  /// This only records that the user downloaded the pin.
  Future<void> recordDownload(Pin pin) async {
    await downloads.doc(pin.id).set({
      ...pin.toMap(),
      'downloadedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check whether this pin has previously been downloaded.
  Future<bool> isDownloaded(String pinId) async {
    final doc = await downloads.doc(pinId).get();
    return doc.exists;
  }

  /// Get all downloaded pins.
  Stream<List<Pin>> watchDownloads() {
    return downloads
        .orderBy(
          'downloadedAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Pin.fromMap(doc.data()),
          )
          .toList();
    });
  }

  /// Delete one download record.
  Future<void> removeDownload(String pinId) async {
    await downloads.doc(pinId).delete();
  }

  /// Remove all download records.
  Future<void> clearDownloads() async {
    final snapshot = await downloads.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ============================================================
  // RECENTLY VIEWED
  //
  // users/{uid}/recentlyViewed/{pinId}
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get recentlyViewed {
    return _userRef.collection('recentlyViewed');
  }

  /// Record that a user opened/viewed a pin.
  ///
  /// If the pin was already viewed, its viewedAt timestamp
  /// is updated so it moves back to the top of the history.
  Future<void> recordRecentlyViewed(Pin pin) async {
    await recentlyViewed.doc(pin.id).set({
      ...pin.toMap(),
      'viewedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Alias for easier use from PinDetailScreen.
  Future<void> addRecentlyViewed(Pin pin) async {
    await recordRecentlyViewed(pin);
  }

  /// Check whether a pin exists in recently viewed.
  Future<bool> isRecentlyViewed(String pinId) async {
    final doc = await recentlyViewed.doc(pinId).get();
    return doc.exists;
  }

  /// Watch recently viewed pins.
  Stream<List<Pin>> watchRecentlyViewed() {
    return recentlyViewed
        .orderBy(
          'viewedAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Pin.fromMap(doc.data()),
          )
          .toList();
    });
  }

  /// Remove one recently viewed pin.
  Future<void> removeRecentlyViewed(String pinId) async {
    await recentlyViewed.doc(pinId).delete();
  }

  /// Clear the complete recently viewed history.
  Future<void> clearRecentlyViewed() async {
    final snapshot = await recentlyViewed.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ============================================================
  // USER COUNTS
  // ============================================================

  Future<int> getLikesCount() async {
    final snapshot = await likes.get();
    return snapshot.size;
  }

  Future<int> getSavedCount() async {
    final snapshot = await favorites.get();
    return snapshot.size;
  }

  Future<int> getBoardsCount() async {
    final snapshot = await boards.get();
    return snapshot.size;
  }

  Future<int> getDownloadsCount() async {
    final snapshot = await downloads.get();
    return snapshot.size;
  }

  Future<int> getRecentlyViewedCount() async {
    final snapshot = await recentlyViewed.get();
    return snapshot.size;
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../models/pin.dart';

// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // ============================================================
//   // CURRENT USER
//   // ============================================================

//   String get uid {
//     final user = _auth.currentUser;

//     if (user == null) {
//       throw StateError('User is not signed in.');
//     }

//     return user.uid;
//   }

//   DocumentReference<Map<String, dynamic>> get _userRef {
//     return _db.collection('users').doc(uid);
//   }

//   // ============================================================
//   // FAVORITES / SAVED PINS
//   // ============================================================

//   CollectionReference<Map<String, dynamic>> get favorites {
//     return _userRef.collection('favorites');
//   }

//   Future<void> save(Pin pin) async {
//     await favorites.doc(pin.id).set({
//       ...pin.toMap(),
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> remove(String id) async {
//     await favorites.doc(id).delete();
//   }

//   Future<bool> contains(String id) async {
//     final doc = await favorites.doc(id).get();
//     return doc.exists;
//   }

//   Future<bool> isSaved(String pinId) async {
//     final doc = await favorites.doc(pinId).get();
//     return doc.exists;
//   }

//   Future<bool> toggleSave(Pin pin) async {
//     final ref = favorites.doc(pin.id);

//     final doc = await ref.get();

//     if (doc.exists) {
//       await ref.delete();
//       return false;
//     }

//     await ref.set({
//       ...pin.toMap(),
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     return true;
//   }

//   Future<void> savePin(Pin pin) async {
//     await favorites.doc(pin.id).set({
//       ...pin.toMap(),
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> unsavePin(String id) async {
//     await favorites.doc(id).delete();
//   }

//   Stream<List<Pin>> watch() {
//     return favorites
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) {
//             return snapshot.docs
//                 .map(
//                   (doc) => Pin.fromMap(
//                     doc.data(),
//                   ),
//                 )
//                 .toList();
//           },
//         );
//   }

//   // ============================================================
//   // SAVED PIN COUNT
//   // ============================================================

//   Stream<int> watchSavedPinsCount() {
//     return favorites.snapshots().map(
//       (snapshot) => snapshot.size,
//     );
//   }

//   // ============================================================
//   // LIKES
//   // ============================================================

//   CollectionReference<Map<String, dynamic>> get likes {
//     return _userRef.collection('likes');
//   }

//   Future<bool> isLiked(String pinId) async {
//     final doc = await likes.doc(pinId).get();
//     return doc.exists;
//   }

//   Future<bool> toggleLike(Pin pin) async {
//     final ref = likes.doc(pin.id);

//     final doc = await ref.get();

//     if (doc.exists) {
//       await ref.delete();
//       return false;
//     }

//     await ref.set({
//       ...pin.toMap(),
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     return true;
//   }

//   Future<void> likePin(Pin pin) async {
//     await likes.doc(pin.id).set({
//       ...pin.toMap(),
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> unlikePin(String pinId) async {
//     await likes.doc(pinId).delete();
//   }

//   Stream<List<Pin>> watchLikes() {
//     return likes
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) {
//             return snapshot.docs
//                 .map(
//                   (doc) => Pin.fromMap(
//                     doc.data(),
//                   ),
//                 )
//                 .toList();
//           },
//         );
//   }

//   // ============================================================
//   // LIKE COUNT
//   // ============================================================

//   Stream<int> watchLikesCount() {
//     return likes.snapshots().map(
//       (snapshot) => snapshot.size,
//     );
//   }

//   // ============================================================
//   // BOARDS
//   // ============================================================

//   CollectionReference<Map<String, dynamic>> get boards {
//     return _userRef.collection('boards');
//   }

//   Future<String> createBoard(String name) async {
//     final cleanName = name.trim();

//     if (cleanName.isEmpty) {
//       throw ArgumentError(
//         'Board name cannot be empty.',
//       );
//     }

//     final doc = await boards.add({
//       'name': cleanName,
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     return doc.id;
//   }

//   Future<QuerySnapshot<Map<String, dynamic>>> getBoards() {
//     return boards
//         .orderBy(
//           'createdAt',
//           descending: true,
//         )
//         .get();
//   }

//   // ============================================================
//   // BOARD COUNT
//   // ============================================================

//   Stream<int> watchBoardsCount() {
//     return boards.snapshots().map(
//       (snapshot) => snapshot.size,
//     );
//   }

//   // ============================================================
//   // ADD PIN TO BOARD
//   // ============================================================

//   Future<void> addToBoard(
//     String boardId,
//     Pin pin,
//   ) async {
//     await boards
//         .doc(boardId)
//         .collection('pins')
//         .doc(pin.id)
//         .set({
//       ...pin.toMap(),
//       'addedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   // ============================================================
//   // REMOVE PIN FROM BOARD
//   // ============================================================

//   Future<void> removeFromBoard(
//     String boardId,
//     String pinId,
//   ) async {
//     await boards
//         .doc(boardId)
//         .collection('pins')
//         .doc(pinId)
//         .delete();
//   }

//   // ============================================================
//   // CHECK PIN IN BOARD
//   // ============================================================

//   Future<bool> isInBoard(
//     String boardId,
//     String pinId,
//   ) async {
//     final doc = await boards
//         .doc(boardId)
//         .collection('pins')
//         .doc(pinId)
//         .get();

//     return doc.exists;
//   }

//   // ============================================================
//   // WATCH BOARD PINS
//   // ============================================================

//   Stream<List<Pin>> watchBoard(
//     String boardId,
//   ) {
//     return boards
//         .doc(boardId)
//         .collection('pins')
//         .orderBy(
//           'addedAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) {
//             return snapshot.docs
//                 .map(
//                   (doc) => Pin.fromMap(
//                     doc.data(),
//                   ),
//                 )
//                 .toList();
//           },
//         );
//   }

//   // ============================================================
//   // DELETE BOARD
//   // ============================================================

//   Future<void> deleteBoard(
//     String boardId,
//   ) async {
//     final pins = await boards
//         .doc(boardId)
//         .collection('pins')
//         .get();

//     final batch = _db.batch();

//     for (final doc in pins.docs) {
//       batch.delete(doc.reference);
//     }

//     batch.delete(
//       boards.doc(boardId),
//     );

//     await batch.commit();
//   }

//   // ============================================================
//   // DOWNLOADS
//   // ============================================================

//   CollectionReference<Map<String, dynamic>> get downloads {
//     return _userRef.collection('downloads');
//   }

//   Future<void> recordDownload(Pin pin) async {
//     await downloads.doc(pin.id).set({
//       ...pin.toMap(),
//       'downloadedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Stream<List<Pin>> watchDownloads() {
//     return downloads
//         .orderBy(
//           'downloadedAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) {
//             return snapshot.docs
//                 .map(
//                   (doc) => Pin.fromMap(
//                     doc.data(),
//                   ),
//                 )
//                 .toList();
//           },
//         );
//   }

//   // ============================================================
//   // RECENTLY VIEWED
//   // ============================================================

//   CollectionReference<Map<String, dynamic>>
//       get recentlyViewed {
//     return _userRef.collection('recentlyViewed');
//   }

//   Future<void> recordRecentlyViewed(
//     Pin pin,
//   ) async {
//     await recentlyViewed.doc(pin.id).set({
//       ...pin.toMap(),
//       'viewedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Stream<List<Pin>> watchRecentlyViewed() {
//     return recentlyViewed
//         .orderBy(
//           'viewedAt',
//           descending: true,
//         )
//         .snapshots()
//         .map(
//           (snapshot) {
//             return snapshot.docs
//                 .map(
//                   (doc) => Pin.fromMap(
//                     doc.data(),
//                   ),
//                 )
//                 .toList();
//           },
//         );
//   }

//   Future<void> clearRecentlyViewed() async {
//     final snapshot = await recentlyViewed.get();

//     final batch = _db.batch();

//     for (final doc in snapshot.docs) {
//       batch.delete(doc.reference);
//     }

//     await batch.commit();
//   }
// }