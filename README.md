# News

Flutter application for browsing and searching news headlines from NewsAPI.

## Features

- Browse headlines by category and search or filter by title.
- Save articles to a local favorites list for later.
- Share article links and browse related stories from an article's detail page.

## Setup

1. Install Flutter and run `flutter pub get`.
2. Create a `.env` file in the project root and add your NewsAPI key:

   ```env
   NEWS_API_KEY=your_newsapi_key
   ```

3. Start the application with `flutter run`.

The `.env` file must exist when building because it is registered as a Flutter
asset. The app can start with an empty `NEWS_API_KEY`, but loading news requires
a valid key. A key bundled in a client app can be extracted; use a backend proxy
and key restrictions for production.
