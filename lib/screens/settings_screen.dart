import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const SettingsScreen({super.key, required this.onThemeChanged, required this.isDarkMode});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(title: const Text("Dark Mode"),
            trailing: Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              widget.onThemeChanged(value);},
            ),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text("Language"),
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text("Feedback"),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About"),
          ),
          ListTile(
            leading: Icon(Icons.verified),
            title: Text("Version"),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy policy"),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text("Terms of use"),
          ),
        ],
      ),
    );
  }
}
