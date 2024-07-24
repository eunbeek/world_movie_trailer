import 'package:flutter/material.dart';
import 'package:world_movie_trailer/layout/movie_list_page.dart';
import 'package:world_movie_trailer/common/constants.dart';

class CountryListPage extends StatelessWidget {
  const CountryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(countryAppBar),
      ),
      body: ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(countries[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieListPage(country: countries[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:world_movie_trailer/layout/movie_list_page.dart';
// import 'package:world_movie_trailer/common/constants.dart';

// class CountryListPage extends StatelessWidget {
//   const CountryListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(countryAppBar),
//       ),
//       body: FlutterMap(
//         options: MapOptions(
//           center: LatLng(20, 0),
//           zoom: 2,
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//             subdomains: ['a', 'b', 'c'],
//           ),
//           MarkerLayer(
//             markers: _buildMarkers(context),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Marker> _buildMarkers(BuildContext context) {
//     List<Marker> markers = [];
//     for (var country in countries) {
//       LatLng position = _getCountryPosition(country);
//       markers.add(
//         Marker(
//           width: 100.0,
//           height: 80.0,
//           point: position,
//           builder: (ctx) => GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => MovieListPage(country: country),
//                 ),
//               );
//             },
//             child: Column(
//               children: [
//                 Icon(
//                   Icons.location_on,
//                   color: Colors.red,
//                   size: 40.0,
//                 ),
//                 Container(
//                   child: Text(
//                     country,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     return markers;
//   }

//   LatLng _getCountryPosition(String country) {
//     switch (country) {
//       case 'Korea':
//         return LatLng(37.5665, 126.9780); // Seoul, South Korea
//       case 'Japan':
//         return LatLng(35.682839, 139.759455); // Tokyo, Japan
//       case 'North America':
//         return LatLng(37.0902, -95.7129); // Center of USA
//       case 'France':
//         return LatLng(48.8566, 2.3522); // Paris, France
//       default:
//         return LatLng(0, 0); // Default position
//     }
//   }
// }
