# 📰 News App

A modern, beautiful Flutter news application with a calming sage green theme. Stay updated with the latest news from multiple categories, bookmark your favorite articles, and enjoy a seamless reading experience.

## ✨ Features

- **📱 Multi-Platform Support**: Works on Android, iOS, Web, Linux, macOS, and Windows
- **🎨 Beautiful UI**: Modern Material Design 3 with a calming sage green color scheme
- **🌓 Dark Mode**: Toggle between light and dark themes
- **📰 News Categories**: Browse news from different categories:
  - General
  - Business
  - Entertainment
  - Health
  - Science
  - Sports
  - Technology
- **🔍 Search**: Search for news articles by keywords
- **⭐ Bookmarks**: Save articles to read later
- **📤 Share**: Share articles with friends and family
- **🖼️ Image Caching**: Efficient image loading with caching
- **📱 Responsive Design**: Optimized for all screen sizes
- **🔄 Pull to Refresh**: Refresh news by pulling down
- **♾️ Infinite Scroll**: Automatically load more articles as you scroll

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (for iOS development) or Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/p013.git
   cd p013
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

- **http**: ^1.2.0 - For making HTTP requests to the news API
- **cached_network_image**: ^3.3.1 - For efficient image loading and caching
- **intl**: ^0.19.0 - For date formatting and internationalization
- **url_launcher**: ^6.2.5 - For opening URLs in external browsers
- **shared_preferences**: ^2.2.2 - For local storage of bookmarks and settings
- **share_plus**: ^7.2.1 - For sharing articles

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── news_article.dart     # News article data model
├── screens/
│   ├── home_screen.dart       # Main navigation screen
│   ├── news_list_screen.dart  # News list with categories
│   ├── news_detail_screen.dart # Article detail view
│   └── bookmarks_screen.dart  # Saved bookmarks
├── services/
│   ├── news_service.dart      # News API service
│   ├── bookmark_service.dart   # Bookmark management
│   └── theme_service.dart     # Theme preferences
└── utils/
    └── constants.dart         # App constants and color palette
```

## 🎨 Color Scheme

The app uses a beautiful sage green color palette:

- **Sage Green**: `#9CAF88` - Primary color
- **Sage Green Light**: `#B2B5A0` - Light variant
- **Sage Green Dark**: `#87AE73` - Dark variant
- **Sage Green Lighter**: `#D4D9C8` - Very light variant
- **Sage Green Darker**: `#6B8E5A` - Very dark variant

## 📱 Usage

### Viewing News

1. Open the app to see the latest news
2. Swipe between category tabs to browse different news categories
3. Tap on any article to read the full story

### Searching News

1. Tap the search icon in the app bar
2. Type your search query
3. Results will appear automatically as you type

### Bookmarking Articles

1. Tap the bookmark icon on any news card or detail screen
2. Bookmarked articles are saved locally
3. Access your bookmarks from the Bookmarks tab
4. Remove bookmarks by tapping the bookmark icon again

### Sharing Articles

1. Tap the share icon on any news card or detail screen
2. Choose your preferred sharing method

### Dark Mode

1. Toggle dark mode from the news list screen (if implemented)

## 🔧 Configuration

### API Key Setup

To use the news API, you'll need to:

1. Get an API key from [NewsAPI](https://newsapi.org/)
2. Update the API key in `lib/services/news_service.dart`

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📱 Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

## 🛠️ Development

### Code Style

This project follows Flutter's recommended linting rules. Run:
```bash
flutter analyze
```

### Formatting

Format your code with:
```bash
flutter format .
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- NewsAPI for providing the news data
- Flutter team for the amazing framework
- Material Design for the design guidelines

## 📞 Support

If you have any questions or issues, please open an issue on GitHub.

---

Made with ❤️ using Flutter
