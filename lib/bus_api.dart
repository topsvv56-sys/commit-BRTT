import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BUS extends StatefulWidget {
  const BUS({super.key, required int total});

  @override
  State<BUS> createState() => _BUSState();
}

class _BUSState extends State<BUS> {
  Future<List<dynamic>>? _busFuture;

  void initState() {
    super.initState();
    _busFuture = fetchBus();
  }

  Future<List> fetchBus() async {
    final response = await http.get(
      Uri.parse('https://api.brt.co.id/v1/buses'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return data['user'];
    } else {
      throw Exception("Failed to load buses");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus API')),

      body: FutureBuilder<List>(
        future: _busFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Data"));
          }

          List bus = snapshot.data!;

          return ListView.builder(
            itemCount: bus.length,

            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(bus[index]['id'].toString()),
                  ),

                  title: Text(bus[index]['bus_name'] ?? 'No Name'),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Driver: ${bus[index]['driver'] ?? 'ບໍ່ມີຊື່ຄົນຂັບ'}",
                      ),

                      Text("Route: ${bus[index]['route'] ?? 'ບໍ່ມີເສັ້ນທາງ'}"),

                      Text("Time: ${bus[index]['time'] ?? 'ບໍ່ມີເວລາ'}"),

                      Text("Price: ${bus[index]['price']} Kip"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
