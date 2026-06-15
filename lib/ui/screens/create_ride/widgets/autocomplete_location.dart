import 'package:flutter/material.dart';
import 'package:ridechain_driiver/app/theme.dart';

import '../../../../core/core_constants/colors.dart';
import '../../../../data/models/location_model.dart';

class LocationAutocomplete extends StatefulWidget {
  final List<LocationModel> locations;
  final ValueChanged<LocationModel?>? onLocationSelected;
  final String? hintText;
  final LocationModel? initialValue;
  final InputDecoration? decoration;

  const LocationAutocomplete({super.key, required this.locations, this.onLocationSelected, this.hintText = 'Search location...', this.initialValue, this.decoration});

  @override
  State<LocationAutocomplete> createState() => _LocationAutocompleteState();
}

class _LocationAutocompleteState extends State<LocationAutocomplete> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<LocationModel>(
      // Initial value setup
      initialValue: widget.initialValue != null ? TextEditingValue(text: widget.initialValue!.name ?? '') : null,

      // Display string builder - shows name in dropdown
      displayStringForOption: (LocationModel option) => option.name ?? '',

      // Options builder - filters locations based on input
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return widget.locations;
        }

        return widget.locations.where((LocationModel location) {
          final searchText = textEditingValue.text.toLowerCase();
          final locationName = location.name?.toLowerCase() ?? '';
          return locationName.contains(searchText);
        });
      },

      // Selection handler - returns complete LocationModel object
      onSelected: (LocationModel selectedLocation) {
        widget.onLocationSelected?.call(selectedLocation);
        debugPrint('Selected Location: ${selectedLocation.name}');
        debugPrint('ID: ${selectedLocation.id}');
        debugPrint('Coordinates: ${selectedLocation.latitude}, ${selectedLocation.longitude}');
      },

      // Custom field builder for styling
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return ListenableBuilder(
          listenable: textEditingController,
          builder: (context, child) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration:
                  widget.decoration ??
                  InputDecoration(
                    hintText: widget.hintText,
                    labelStyle: AppThemes.inter(fontSize: 16, color: AppColors.black, fontWeight: FontWeight.w400),
                    hintStyle: AppThemes.inter(fontSize: 16, color: AppColors.greyAd, fontWeight: FontWeight.w400),
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.black),
                    suffixIcon: textEditingController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.black),
                            onPressed: () {
                              textEditingController.clear();
                              widget.onLocationSelected?.call(null);
                              setState(() {

                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textFieldBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textFieldBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textFieldBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
              onSubmitted: (String value) {
                onFieldSubmitted();
              },
            );
          }
        );
      },

      // Custom options builder for dropdown items
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<LocationModel> onSelected, Iterable<LocationModel> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 400),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final LocationModel location = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(location),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.place, color: AppColors.black, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.name ?? 'Unknown',
                                  style: AppThemes.inter(fontSize: 16, color: AppColors.black, fontWeight: FontWeight.w400),
                                ),
                                if (location.latitude != null && location.longitude != null)
                                  Text(
                                    '${location.latitude!.toStringAsFixed(4)}, ${location.longitude!.toStringAsFixed(4)}',
                                    style: AppThemes.inter(fontSize: 12, color: AppColors.greyAd, fontWeight: FontWeight.w400),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
