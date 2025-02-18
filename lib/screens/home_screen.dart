import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shotify")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
                onPressed: (){},
                child: const Text("Upload a photo")),
          ),
          
          Expanded(
              child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index){
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage("assets/singer_placeholder.png"),
                      ),
                      title: const Text("Song name"),
                      subtitle: const Text("Singer Name"),
                    );
                  }))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index){
          },
          items: const [
            BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home"),

          BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: "History"),

          BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "settings"),
          ]),
    );
  }
}

