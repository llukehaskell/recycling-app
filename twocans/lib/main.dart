import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context){
    Widget page;
    switch(selectedPage){
      case 0:
        page = Placeholder();
        break;
      case 1:
        page = Placeholder();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = Placeholder();
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
            items:[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                // backgroundColor: Theme.of(context).colorScheme.onBackground,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
                // backgroundColor: Theme.of(context).colorScheme.onBackground,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Map',
                // backgroundColor: Theme.of(context).colorScheme.onBackground,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                // backgroundColor: Theme.of(context).colorScheme.onBackground,
              ),
            ],
            // selectedItemColor: Theme.of(context).colorScheme.onBackground,
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
        onPressed: (){
          print('Camera');
        },
        child: Icon(Icons.photo_camera),
      )
    );
  }
}