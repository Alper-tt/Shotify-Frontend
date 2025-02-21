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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true,),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
          ),
          ListTile(
            leading: Icon(Icons.invert_colors_outlined),
            title: const Text("Change theme"),
            trailing: Switch(
              value: _isDarkMode,
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                if (_isDarkMode) {
                  return const Icon(Icons.dark_mode);
                }
                return Icon(Icons.light_mode);
              }),
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                widget.onThemeChanged(value);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("Feedback"),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text("Version"),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy policy"),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Terms of use"),
          ),
        ],
      ),
    );
  }
}
