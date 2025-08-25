
import 'package:fgtracker/app/Core/util/size_config.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Widget buildInput({
  required String hintText,
  required IconData icon,
  required TextEditingController controller,
  Widget? suffixIcon,
  bool obscureText = false,
  required String? Function(String?) validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockWidth * 4,
        vertical: SizeConfig.blockHeight * 2,
      ),
    ),
    style: TextStyle(fontSize: SizeConfig.getFont(14)),
  );
}

class GoogleMapPreview extends StatefulWidget {
  final double latitude;
  final double longitude;

  const GoogleMapPreview({
    required this.latitude,
    required this.longitude,
    Key? key,
  }) : super(key: key);

  @override
  State<GoogleMapPreview> createState() => _GoogleMapPreviewState();
}

class _GoogleMapPreviewState extends State<GoogleMapPreview> {
  GoogleMapController? _mapController;
  double _zoomLevel = 16.0;

  void _zoomIn() {
    if (_zoomLevel < 20) {
      setState(() => _zoomLevel += 1);
      _mapController?.moveCamera(CameraUpdate.zoomTo(_zoomLevel));
    }
  }

  void _zoomOut() {
    if (_zoomLevel > 5) {
      setState(() => _zoomLevel -= 1);
      _mapController?.moveCamera(CameraUpdate.zoomTo(_zoomLevel));
    }
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: _zoomLevel,
    );

    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent, width: 2),
          ),
          clipBehavior: Clip.hardEdge,
          child: GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: _initialPosition,
            mapType: MapType.satellite,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'zoom_in',
                mini: true,
                onPressed: _zoomIn,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                onPressed: _zoomOut,
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class GridMenuItem {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final double imageSize;

  GridMenuItem({
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.imageSize = 50.0,
  });
}

class ReusableGridMenu extends StatelessWidget {
  final List<GridMenuItem> items;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const ReusableGridMenu({
    Key? key,
    required this.items,
    this.crossAxisCount = 3,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: padding,
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.9, // Adjust as needed
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: item.onTap,
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.blueAccent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    item.imagePath,
                    width: item.imageSize,
                    height: item.imageSize,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  reausabletext(
                    item.label,
                   fontsize: 14,align: TextAlign.center)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


