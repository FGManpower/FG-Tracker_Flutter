import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/themes_data.dart';
import '../Controller/contact_picker_controller.dart';

class ContactPickerPage extends StatelessWidget {
  const ContactPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactPickerController controller =
        Get.put(ContactPickerController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Share Contact"),
        centerTitle: true,
        backgroundColor: ToggleThemeData.Appcolor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() {
            if (controller.loading.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  "${controller.filteredContacts.length} contacts",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildBody(ContactPickerController controller) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadContacts,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.search,
              decoration: InputDecoration(
                hintText: "Search Contact",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clearSearch,
                  );
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.filteredContacts.isEmpty) {
                return const Center(child: Text("No contacts found"));
              }

              return ListView.separated(
                itemCount: controller.filteredContacts.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (_, index) {
                  final contact = controller.filteredContacts[index];
                  final thumbnail = contact.thumbnail;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          ToggleThemeData.Appcolor.withValues(alpha: 0.15),
                      backgroundImage:
                          thumbnail != null ? MemoryImage(thumbnail) : null,
                      child: thumbnail == null
                          ? Text(
                              controller.getInitials(contact.displayName),
                              style: TextStyle(
                                color: ToggleThemeData.Appcolor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(contact.displayName),
                    subtitle: Text(contact.phones.first.number),
                    onTap: () => controller.selectContact(contact),
                  );
                },
              );
            }),
          ),
        ],
      );
    });
  }
}
