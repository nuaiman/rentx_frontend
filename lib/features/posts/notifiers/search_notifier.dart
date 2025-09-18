import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// -----------------------------------------------------------------------------
final searchProvider = NotifierProvider<SearchNotifier, String>(
  SearchNotifier.new,
);
