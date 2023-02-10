// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
//
// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);
//
//   @override
//   _HomeState createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   int _selectedIndex = 0;
//   static const TextStyle optionStyle =
//       TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
//   static const List<Widget> _widgetOptions = <Widget>[
//     Text(
//       'Index 0: Home',
//       style: optionStyle,
//     ),
//     Text(
//       'Index 1: Favourites',
//       style: optionStyle,
//     ),
//     Text(
//       'Index 2: Search',
//       style: optionStyle,
//     ),
//     Text(
//       'Index 3: Profile',
//       style: optionStyle,
//     ),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Demo Home Page'),
//       ),
//       body: Center(
//         // ignore: unnecessary_new
//         child: ListView(
//           scrollDirection: Axis.horizontal,
//           children: <Widget>[
//             Container(
//               width: 160.0,
//               color: Colors.blue,
//             ),
//             Container(
//               width: 160.0,
//               color: Colors.green,
//             ),
//             Container(
//               width: 160.0,
//               color: Colors.cyan,
//             ),
//             Container(
//               width: 160.0,
//               color: Colors.black,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
