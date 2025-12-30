import 'package:flutter/material.dart';
import '../services/api_serv.dart';
import 'package:geo_flutter/theme/colors.dart';

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

  String fallback(dynamic value) {
    if (value == null) return "No information retrieved";
    if (value is String && value.trim().isEmpty)
      return "No information retrieved";
    return value.toString();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getGeoLoc();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "IP Geolocation System",
          style: TextStyle(color: GeoColors.platinum),
        ),
        backgroundColor: GeoColors.grey,
        foregroundColor: GeoColors.platinum,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ipController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: "Enter IP address",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: GeoColors.aqua,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(GeoColors.lime),
                    foregroundColor: WidgetStatePropertyAll(GeoColors.grey),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: GeoColors.grey, width: 1.5),
                    ),
                  ),
                  onPressed: getGeoLoc,
                  child: const Text(
                    "Search",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(GeoColors.coral),
                    foregroundColor: WidgetStatePropertyAll(GeoColors.grey),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: GeoColors.grey, width: 1.5),
                    ),
                  ),
                  onPressed: clearSearch,
                  child: const Text(
                    "Clear",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  if (geoData != null) geoInfo(),

                  if (selectedIps.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: GeoColors.platinum,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GeoColors.aqua, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${selectedIps.length} selected",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: GeoColors.ember,
                            ),
                            onPressed: deleteSelected,
                          ),
                        ],
                      ),
                    ),

                  if (history.isNotEmpty)
                    CheckboxListTile(
                      title: const Text(
                        "Select all IP addresses",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      value: isAllSelected,
                      activeColor: GeoColors.olive,
                      onChanged: (checked) {
                        setState(() {
                          selectedIps = checked == true ? history.toSet() : {};
                        });
                      },
                    ),

                  ...history.map(
                    (ip) => CheckboxListTile(
                      title: Text(ip),
                      value: selectedIps.contains(ip),
                      activeColor: GeoColors.olive,
                      onChanged: (checked) {
                        setState(() {
                          checked == true
                              ? selectedIps.add(ip)
                              : selectedIps.remove(ip);
                        });
                      },
                      secondary: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          ipController.text = ip;
                          getGeoLoc();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget geoInfo() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GeoColors.platinum,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GeoColors.grey, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.public, color: GeoColors.ember),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "IP Address",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fallback(geoData!['ip']),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GeoColors.platinum,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GeoColors.grey, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.location_city, color: GeoColors.olive),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "City",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fallback(geoData!['city']),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GeoColors.platinum,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GeoColors.grey, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.map, color: GeoColors.ember),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Region",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fallback(geoData!['region']),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GeoColors.platinum,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GeoColors.grey, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.flag, color: GeoColors.olive),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Country",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fallback(geoData!['country']),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GeoColors.platinum,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.local_post_office,
                  color: GeoColors.ember,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Postal Code",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fallback(geoData!['postal']),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget historyList() {
    return ListView(
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
            activeColor: GeoColors.olive,
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
                getGeoLoc();
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  bool isValidIP(String ip) {
    final regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    return regex.hasMatch(ip);
  }

  Future<void> getGeoLoc() async {
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
    getGeoLoc();
  }

  void deleteSelected() {
    setState(() {
      history.removeWhere((ip) => selectedIps.contains(ip));
      selectedIps.clear();
    });
  }
}
