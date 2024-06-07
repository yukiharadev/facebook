import 'package:facebook/models/facebook/comment.model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/facebook/post.model.dart';
import '../models/users.model.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required DateTime birthDate,
    required File avatarFile,
  }) async {
    try {
      auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      TaskSnapshot snapshot = await _firebaseStorage
          .ref('avatars/$uid')
          .putFile(avatarFile);
      String avatarUrl = await snapshot.ref.getDownloadURL();

      User user = User(
        uid: uid,
        name: name,
        email: email,
        password: password,
        birthDate: birthDate,
        avatarUrl: avatarUrl,
      );

      await _firestore.collection('users').doc(uid).set(user.toJson());
    } on auth.FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<auth.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      auth.UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on auth.FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<User?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        return await getUserById(firebaseUser.uid);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> createPost({
    required String userId,
    required String content,
    required List<String> imageUrls,
  }) async {
    try {
      User? user = await getUserById(userId);
      if (user != null) {
        String postId = _firestore.collection('posts').doc().id;
        PostFacebookModel post = PostFacebookModel(
          postId: postId,
          content: content,
          userId: user.uid,
          imageUrls: imageUrls,
          createdAt: DateTime.now(),
          likes: 0,
          likesUserId: [],
        );

        await _firestore.collection('posts').doc(postId).set(post.toJson());
      }
    } catch (e) {
      throw e;
    }
  }

  Stream<List<PostFacebookModel>> getPosts() {
    return _firestore.collection('posts').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PostFacebookModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> createComment({
    required String newsId,
    required String userId,
    required String commentContent,
  }) async {
    try {
      CommentsFacebookModel comment = CommentsFacebookModel(
        commentsId: _firestore.collection('comments').doc().id,
        newsId: newsId,
        userId: userId,
        createdAt: DateTime.now(),
        commentContent: commentContent,
      );

      await _firestore.collection('comments').doc(comment.commentsId).set(comment.toJson());
    } catch (e) {
      throw e;
    }
  }

  Future<PostFacebookModel?> getPostById(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await _firestore.collection('posts').doc(postId).get();
      if (postSnapshot.exists) {
        return PostFacebookModel.fromJson(postSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }
  Stream<List<CommentsFacebookModel>> getComments(String newsId) {
    return _firestore.collection('comments').where('newsId', isEqualTo: newsId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CommentsFacebookModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

 Future<void> likePost({
  required String postId,
  required String userId,
}) async {
  try {
    DocumentSnapshot postSnapshot = await _firestore.collection('posts').doc(postId).get();
    if (postSnapshot.exists) {
      PostFacebookModel post = PostFacebookModel.fromJson(postSnapshot.data() as Map<String, dynamic>);
      if (post.likesUserId!.contains(userId)) {
        post.likesUserId?.remove(userId);
        post.likes--;
      } else {
        post.likesUserId?.add(userId);
        post.likes++;
      }
      await _firestore.collection('posts').doc(postId).update(post.toJson());
    }
  } catch (e) {
    throw e;
  }
}

}



