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

const List<AppCategory> kCategories = [
  AppCategory(name: 'Gym Trainer', emoji: '🏋️', color: Color(0xFFE9D5FF)),
  AppCategory(name: 'Car Mechanic', emoji: '🔧', color: Color(0xFFDDD6FE)),
  AppCategory(name: 'Civil Engineer', emoji: '🏗️', color: Color(0xFFFCE7F3)),
  AppCategory(name: 'Electrician', emoji: '⚡', color: Color(0xFFFEF3C7)),
  AppCategory(name: 'Painting', emoji: '🎨', color: Color(0xFFD1FAE5)),
];
