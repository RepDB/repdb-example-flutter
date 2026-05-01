import 'package:flutter/material.dart';
import 'data/bundle.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(const RepDbExampleApp());
}

class RepDbExampleApp extends StatelessWidget {
  const RepDbExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2563EB); // sky-blue accent, same family as the Next.js demo
    return MaterialApp(
      title: 'RepDB · Exercise Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      home: const _BundleLoader(),
    );
  }
}

class _BundleLoader extends StatefulWidget {
  const _BundleLoader();

  @override
  State<_BundleLoader> createState() => _BundleLoaderState();
}

class _BundleLoaderState extends State<_BundleLoader> {
  late final Future<Bundle> _future = Bundle.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Bundle>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load bundle:\n${snap.error}'),
              ),
            ),
          );
        }
        return CatalogScreen(bundle: snap.data!);
      },
    );
  }
}
