import 'package:flutter/material.dart';
import '../../../models/city.dart';

class CityPicker extends StatefulWidget {
  final Function(String) onCitySelected;

  const CityPicker({
    super.key,
    required this.onCitySelected,
  });

  @override
  State<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  final TextEditingController searchController = TextEditingController();
  List<City> filteredCities = List.from(turkishCities);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          const Text('Şehir Seçin'),
          const SizedBox(height: 8),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Şehir ara...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onChanged: (value) {
              setState(() {
                filteredCities = turkishCities
                    .where((city) => city.displayName
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredCities.length,
          itemBuilder: (context, index) {
            final city = filteredCities[index];
            return ListTile(
              title: Text(city.displayName),
              onTap: () {
                widget.onCitySelected(city.name);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
