import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'TwoCans',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: HomePage(),
      ),
    );
  }
}

Future<Product> fetchProduct(String barcode) async {
  String UPCRequest =
      'https://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=DDDAAC97-C007-4076-B078-7B263ECF287E&upc=';
  UPCRequest = UPCRequest + barcode;
  final response = await http.get(Uri.parse(UPCRequest));

  if (response.statusCode == 200) {
    return Product.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load product name');
  }
}

class Product {
  final String productName;

  const Product({
    required this.productName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['0']['productname'],
    );
  }
}

String getProductRecycleInfo(
    Product product, Map<String, List<dynamic>> recycleInfo) {
  String commonName = product.productName;
  // Generalize product name
  if (product.productName.contains(RegExp(r'can', caseSensitive: false))) {
    commonName = 'Pop can';
  } else if (product.productName
      .contains(RegExp(r'bottle', caseSensitive: false))) {
    commonName = 'Plastic bottle (beverage)';
  }

  final recycleInfoRow = recycleInfo[commonName];

  if (recycleInfoRow != null) {
    String specialInstructions = recycleInfo[commonName]?[6];
    if (specialInstructions != '') {
      return specialInstructions;
    }
  }

  return 'No special instructions.';
}

class MyAppState extends ChangeNotifier {
  var markerList = <Marker>{};
  Future _addMarkerLongPressed(LatLng latlong) async {
    final MarkerId markerId = MarkerId(latlong.toString());
    Marker marker = Marker(
      markerId: markerId,
      draggable: true,
      position:
          latlong, //With this parameter you automatically obtain latitude and longitude
      infoWindow: InfoWindow(
        title: "Recycling Location",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen), //Icon(Icons.recycling),
    );
    markerList.add(marker);
    print(markerList);
    notifyListeners();
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedPage = 0;
  String barcodeScanRes = '';

  // Get recycling info from csv
  Future<List<List<dynamic>>> initCSV() async {
    var result = await DefaultAssetBundle.of(context).loadString(
      './assets/Waste_Recycling_Material_List.csv',
    );
    return const CsvToListConverter().convert(result, eol: "\n");
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedPage) {
      case 0:
        page = FeedPage();
        break;
      case 1:
        page = const Placeholder();
        break;
      case 2:
        page = MapPage();
        break;
      case 3:
        page = const Placeholder();
        break;
      default:
        throw UnimplementedError('No widget for $selectedPage');
    }

    return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
            SafeArea(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                iconSize: 36.0,
                backgroundColor: Theme.of(context).colorScheme.background,
                // ignore: prefer_const_literals_to_create_immutables
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.map),
                    label: 'Map',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                selectedItemColor: Theme.of(context).colorScheme.onBackground,
                currentIndex: selectedPage,
                onTap: (index) {
                  setState(() {
                    selectedPage = index;
                  });
                },
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            print('Camera');

            // Process CSV
            final fields = await initCSV();
            Map<String, List<dynamic>> csvList = {};
            for (final row in fields) {
              csvList[row[1]] = row;
            }

            final newbarcode = await FlutterBarcodeScanner.scanBarcode(
                '#ff6666', 'Cancel', false, ScanMode.BARCODE);

            setState(() {
              barcodeScanRes = newbarcode;
            });

            var prodname = await fetchProduct(barcodeScanRes);
            print(prodname.productName);
            var recycleInstructions = getProductRecycleInfo(prodname, csvList);
            print(recycleInstructions);

            // Tell the user what they scanned and give any instructions
            // they may need
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(
                      'You scanned a ${prodname.productName}.\n\nFollow these instructions to recycle:\n${recycleInstructions}'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Okay'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.qr_code_scanner),
        ));
  }
}

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var messages = ['Hello', 'Aloha', 'message'];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(child: Text("Feed")),
            ),
            for (var msg in messages)
            Container(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(child: Text(msg)),
                ),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(39.329201, -82.101173);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var markers = appState.markerList;

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        body: SafeArea(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            onLongPress: (latlong) {
              appState._addMarkerLongPressed(latlong);
            },
            markers: markers,
          ),
        ),
      ),
    );
  }
}
