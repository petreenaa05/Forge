# Professional Chat Interface - Forge Marketplace

## Overview
A professional, marketplace-grade chat interface designed specifically for Client-Freelancer communication on confirmed jobs in the Forge women-only service marketplace.

## Architecture

### 📁 File Structure
```
lib/
├── screens/
│   └── chat/
│       └── professional_chat_page.dart       # Main chat screen
└── widgets/
    └── chat/
        ├── chat_header.dart                   # Header with user info
        ├── job_context_card.dart              # Job details card
        └── professional_message_bubble.dart   # Message components
```

## Features

### ✨ UI Components

1. **ChatHeader** - Professional header bar
   - User profile with verification badge
   - Online/offline status
   - Job reference subtitle
   - Back navigation

2. **JobContextCard** - Contextual job information
   - Job title
   - Scheduled date
   - Status badge (Confirmed/In Progress/Completed)
   - Professional card styling

3. **ProfessionalMessageBubble** - Animated message bubbles
   - Smooth fade and slide animations
   - Client messages (light red tinted)
   - Freelancer messages (white with shadow)
   - Seen indicators
   - Timestamps

4. **Message Input Area**
   - Rounded text field
   - Attachment button
   - Animated send button with gradient
   - Auto-scroll on send

5. **Typing Indicator** - Three-dot animation

6. **System Messages** - For job events

### 🎨 Design System

**Colors:**
- Primary: `#A82323` (Maroon - headers, send button)
- Secondary: `#FEFFD3` (Cream - background gradient)
- Tertiary: `#6D9E51` (Green - success, verified)
- Neutral grays for text and borders

**Spacing:**
- Message bubbles: 16px horizontal padding
- Vertical spacing: 12-16px between messages
- Generous internal padding for readability

**Typography:**
- Message text: 15px
- Timestamps: 11px
- Headers: 16px bold

**Effects:**
- Smooth animations (300ms)
- Subtle shadows on cards
- Soft gradient backgrounds
- Micro-interactions on buttons

### 📱 Responsive Design

**Desktop (>900px):**
- Chat centered with max-width 800px
- Optimal reading experience

**Mobile:**
- Full-width layout
- Touch-optimized buttons
- Safe area padding

## Usage

### Basic Integration

Add to your routes in `main.dart`:

```dart
routes: {
  '/professional-chat': (context) => const ProfessionalChatPage(),
  // ... other routes
}
```

### Navigate to Chat

```dart
Navigator.pushNamed(
  context,
  '/professional-chat',
  arguments: {
    'jobId': 'job_123',
    'userId': 'user_456',
    'userName': 'Priya Sharma',
    'isVerified': true,
    'jobTitle': 'Home Electrical Repair',
    'scheduledDate': '25 Mar 2026, 2:00 PM',
    'status': 'Confirmed',
  },
);
```

### Customization

The chat page uses a data model `ChatMessage` that you can replace with your own backend model:

```dart
class ChatMessage {
  final String id;
  final String message;
  final String timestamp;
  final bool isMe;
  final bool isSeen;
}
```

### Connect to Backend

Replace the demo `_messages` list with:

1. **Firebase/Firestore:**
   ```dart
   StreamBuilder<QuerySnapshot>(
     stream: FirebaseFirestore.instance
       .collection('chats')
       .doc(chatId)
       .collection('messages')
       .orderBy('timestamp')
       .snapshots(),
     // ... build messages
   )
   ```

2. **REST API:**
   ```dart
   Future<void> _loadMessages() async {
     final response = await http.get('/api/chats/$chatId/messages');
     final messages = (json.decode(response.body) as List)
       .map((m) => ChatMessage.fromJson(m))
       .toList();
     setState(() => _messages = messages);
   }
   ```

3. **WebSocket:**
   ```dart
   final channel = IOWebSocketChannel.connect('ws://...');
   channel.stream.listen((message) {
     // Add new message to list
   });
   ```

## Widgets API

### ChatHeader

```dart
ChatHeader(
  userName: 'Priya Sharma',
  userImage: 'https://...', // optional
  isVerified: true,
  isOnline: true,
  lastSeen: '5m ago', // optional
  jobReference: 'Job: Home Electrical Repair | 25 Mar 2026',
  onBackPressed: () => Navigator.pop(context),
)
```

### JobContextCard

```dart
JobContextCard(
  jobTitle: 'Home Electrical Repair',
  scheduledDate: '25 Mar 2026, 2:00 PM',
  status: 'Confirmed', // or 'In Progress', 'Completed'
)
```

### ProfessionalMessageBubble

```dart
ProfessionalMessageBubble(
  message: 'Hello! I\'m on my way.',
  timestamp: '10:30 AM',
  isMe: false, // true for sent messages
  isSeen: true,
  showSeenIndicator: true, // show on last message only
)
```

### SystemMessageWidget

```dart
SystemMessageWidget(
  message: 'Job Confirmed',
)
```

## Animation Details

- **Message Entry:** 300ms fade + slide
- **Send Button:** 150ms scale animation
- **Typing Indicator:** 1400ms looping dot animation
- **Scroll:** 300ms smooth scroll to bottom

## Best Practices

1. **Performance:**
   - Use `ListView.builder` for large message lists
   - Implement pagination for old messages
   - Dispose controllers in `dispose()` method

2. **Accessibility:**
   - All interactive elements have proper touch targets (48x48)
   - Text contrast meets WCAG AA standards
   - Semantic labels on icons

3. **User Experience:**
   - Auto-scroll on new message
   - Show typing indicator for real-time feel
   - Haptic feedback on send (optional)
   - Message delivery status

4. **Security:**
   - Validate all user inputs
   - Sanitize messages before display
   - Use secure WebSocket connections (wss://)

## Testing

### Unit Tests
```dart
testWidgets('Message bubble renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProfessionalMessageBubble(
        message: 'Test message',
        timestamp: '10:00 AM',
        isMe: true,
        isSeen: false,
      ),
    ),
  );
  expect(find.text('Test message'), findsOneWidget);
});
```

### Integration Tests
- Test message sending flow
- Verify scroll behavior
- Check animation performance

## Future Enhancements

- [ ] Voice message support
- [ ] Image/file attachments
- [ ] Message reactions
- [ ] Read receipts
- [ ] Push notifications
- [ ] Message search
- [ ] Chat archive
- [ ] Block/report functionality

## Dependencies

Required packages (add to `pubspec.yaml`):
```yaml
dependencies:
  flutter:
    sdk: flutter
  # No additional dependencies required for basic functionality
```

Optional for advanced features:
```yaml
  # For image attachments
  image_picker: ^1.0.0
  cached_network_image: ^3.3.0
  
  # For real-time chat
  cloud_firestore: ^4.13.0
  # or
  socket_io_client: ^2.0.3
```

## License

Part of the Forge marketplace application.

---

**Created:** March 2026  
**Version:** 1.0.0  
**Status:** Production Ready
