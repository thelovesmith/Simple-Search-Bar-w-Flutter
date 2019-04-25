import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder> {
        "/search": (BuildContext context) => SearchBarExample(title: "Search Bar"),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {Navigator.pushNamed(context, '/search')},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class SearchBarExample extends StatefulWidget{
  SearchBarExample({Key key, this.title }) : super(key: key);
  @override
  _SearchBarExampleState createState() => _SearchBarExampleState();
  final String title;
}

class _SearchBarExampleState extends State<SearchBarExample>{
  final TextEditingController _filter = new TextEditingController();

  final dio = new Dio(); // for http requests

  String _searchText = "";

  List names = new List(); //names we get from the STarWars API 

  List filteredNames = new List(); // Names filteed by search text 

  Icon _searchIcon = new Icon(Icons.search);

  Widget _appBarTitle = new Text('Search Example');

  // We have to override the default TextController constructor for the state so that it listens for wether there is text in the search bar, and if there is, set the _searchText String to the TExtController input so we can filter the list accordingly. 
  _SearchBarExampleState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = '';
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }
  @override
  void initState() {
    this._getNames();
    super.initState();
  }


  // this function instantiates the lists when the page loads 
  //using dio you can easily make the api call then then use setState to override the initstate and assign our fetch results to the names and filteredNames lists 
  void _getNames() async {
  final response = await dio.get('https://swapi.co/api/people');
  List tempList = new List();
  for (var i = 0; i < response.data['results'].length; i++) {
    tempList.add(response.data['results'][i]);
  }
  setState(() {
    names = tempList;
    filteredNames = names;
    print(names);
  });
}

// this is the callback function for the Seacrh button in the scaffold app bar 
//Contains logic to activate textfield when search icon is pressed swicthes state based on that
void _searchPressed() {
  setState((){
    if (this._searchIcon.icon == Icons.search) {
      this._searchIcon = new Icon(Icons.close);
      this._appBarTitle = new TextField(
        controller: _filter,
        decoration: new InputDecoration(
          prefixIcon: new Icon(Icons.search),
          hintText: 'Search......'
        ),
      );
    } else {
      this._searchIcon = new Icon(Icons.search);
      this._appBarTitle = new Text('Search Example');
      filteredNames = names;
      _filter.clear();
    }
  });
}



  
  @override
  Widget build(BuildContext context){
    return Scaffold(
       
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: _searchPressed,
          ),
        title: _appBarTitle,
    ),
    body: Container(
      child: _buildList(),
    ),
    
    );
  }

  //THis widget builds a ListView with the resukts from filtering the list that we retrieve fron teh API fetch 
  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (int i = 0; i < filteredNames.length; i ++) {
        if(filteredNames[i]['name'].toLowerCase().contains(_searchText.toLowerCase())){
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(filteredNames[index]['name']),
          onTap: () => print(filteredNames[index]['name']),
        );
      },
    );
  }
  


}

