import 'package:flutter/material.dart';

class AppCollections {
  static const String users = 'users';
  static const String jobs = 'jobs';
  static const String reviews = 'reviews';
  static const String chats = 'chats';
  static const String messages = 'messages';
}

class JobStatus {
  static const String requested = 'requested';
  static const String confirmed = 'confirmed';
  static const String completed = 'completed';
  static const String rejected = 'rejected';
}

class UserRole {
  static const String freelancer = 'freelancer';
  static const String client = 'client';
}

class AppCategory {
  final String name;
  final String emoji;
  final Color color;
  const AppCategory({required this.name, required this.emoji, required this.color});
}

// Soft pastels derived from the Forge palette
//  Primary  #7D938A · Secondary #ADA0A6 · Tertiary #DED6D6
const List<AppCategory> kCategories = [
  AppCategory(name: 'Gym Trainer',    emoji: '🏋️', color: Color(0xFFD6DED9)), // primary tint
  AppCategory(name: 'Car Mechanic',   emoji: '🔧', color: Color(0xFFDDD8DB)), // secondary tint
  AppCategory(name: 'Civil Engineer', emoji: '🏗️', color: Color(0xFFE2DCDC)), // tertiary tint
  AppCategory(name: 'Electrician',    emoji: '⚡', color: Color(0xFFD4DFDA)), // primary-light tint
  AppCategory(name: 'Painting',       emoji: '🎨', color: Color(0xFFDAD5D7)), // secondary-light tint
];
