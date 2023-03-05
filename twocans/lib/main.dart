import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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

class MyAppState extends ChangeNotifier{

}

class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  var selectedPage = 0;
  String barcodeScanRes = '';

  @override
  Widget build(BuildContext context){
    Widget page;
    switch(selectedPage){
      case 0:
        page = const Placeholder();
        break;
      case 1:
        page = const Placeholder();
        break;
      case 2:
        page = const Placeholder();
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
            items:[
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
              setState((){
                selectedPage = index;
              });
            },

          ),
        ),
      ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          print('Camera');
          setState(() async {
            barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
              '#ff6666',
              'Cancel',
              false,
              ScanMode.BARCODE);
          });
        },
        child: const Icon(Icons.qr_code_scanner),
      )
    );
  }
}