import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GroupMapPage extends StatefulWidget {
  @override
  State<GroupMapPage> createState() => _GroupMapPageState();
}

class _GroupMapPageState extends State<GroupMapPage> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = LatLng(23.8103, 90.4125); // Dhaka fallback

  // Dummy values
  String distance = "2.5 km";
  String time = "30 min";

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _locationRow("Pickup", "Ajmera Sikova,Ghatkopar", Colors.purple),
            SizedBox(height: 12),
            _locationRow("Dropoff", "Marol Metro, Andheri", Colors.orange),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _filterChip("All"),
                _filterChip("Friends"),
                _filterChip("Online"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _locationRow(String label, String address, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(address, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }

  Widget _filterChip(String label) {
    return Chip(
      backgroundColor: Colors.grey.shade200,
      label: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// MAP
          // GoogleMap(
          //   initialCameraPosition: CameraPosition(
          //     target: _initialPosition,
          //     zoom: 14,
          //   ),
          //   onMapCreated: (controller) {
          //     _mapController = controller;
          //   },
          //   myLocationEnabled: true,
          //   zoomControlsEnabled: false,
          // ),

          /// CUSTOM APPBAR
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                _roundButton(Icons.arrow_back, () {
                  Navigator.pop(context);
                }),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 42,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search name',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                _roundButton(Icons.person, () {}, bgColor: Colors.purple.shade100),
              ],
            ),
          ),



        ],
      ),
    );
  }

  Widget _walkStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        SizedBox(width: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap, {Color? bgColor}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
