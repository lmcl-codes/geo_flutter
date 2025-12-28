import 'package:flutter/material.dart';
import '../services/api_serv.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;

  const HomePage({super.key, required this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController ipController = TextEditingController();
  Map<String, dynamic>? geoData;
  List<String> history = [];
  Set<String> selectedIps = {};
  bool get isAllSelected =>
      history.isNotEmpty && selectedIps.length == history.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchGeo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IP Geolocation System"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: "Logout",
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(labelText: "Enter IP address"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: fetchGeo,
                  child: const Text("Search"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: clearSearch,
                  child: const Text("Clear"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (geoData != null) geoInfo(),
            if (selectedIps.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${selectedIps.length} selected",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: deleteSelected,
                    ),
                  ],
                ),
              ),

            const Divider(),
            if (history.isNotEmpty)
              CheckboxListTile(
                title: const Text("Select All"),
                value: isAllSelected,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedIps = history.toSet();
                    } else {
                      selectedIps.clear();
                    }
                  });
                },
              ),

            historyList(),
          ],
        ),
      ),
    );
  }

  Widget geoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("IP: ${geoData!['ip']}"),
        Text("City: ${geoData!['city']}"),
        Text("Region: ${geoData!['region']}"),
        Text("Country: ${geoData!['country']}"),
        Text("Postal: ${geoData!['postal']}"),
      ],
    );
  }

  Widget historyList() {
    return Expanded(
      child: ListView(
        children: history.map((ip) {
          return GestureDetector(
            onLongPress: () {
              setState(() {
                selectedIps.add(ip);
              });
            },
            child: CheckboxListTile(
              title: Text(ip),
              value: selectedIps.contains(ip),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedIps.add(ip);
                  } else {
                    selectedIps.remove(ip);
                  }
                });
              },
              secondary: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  ipController.text = ip;
                  fetchGeo();
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool isValidIP(String ip) {
    final regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    return regex.hasMatch(ip);
  }

  Future<void> fetchGeo() async {
    final ip = ipController.text.trim();

    if (ip.isNotEmpty && !isValidIP(ip)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid IP address")));
      return;
    }

    final data = await ApiService.getGeo(ip);

    if (data != null) {
      setState(() {
        geoData = data;
        if (ip.isNotEmpty && !history.contains(ip)) {
          history.add(ip);
        }
      });
    }
  }

  void clearSearch() {
    ipController.clear();
    fetchGeo();
  }

  void deleteSelected() {
    setState(() {
      history.removeWhere((ip) => selectedIps.contains(ip));
      selectedIps.clear();
    });
  }
}
