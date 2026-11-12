import 'package:flutter/material.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;

import '../../../config/themes_data.dart';
import '../Controller/contact_picker_controller.dart';

class ContactPickerPage extends StatelessWidget {
  const ContactPickerPage({super.key});

  static const Color _primary = Color(0xFF6B4DFF);
  static const Color _background = Color(0xFFF8F9FD);

  @override
  Widget build(BuildContext context) {
    final ContactPickerController controller =
        Get.put(ContactPickerController());

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        centerTitle: true,
        title: Text(
          appL10n.chatList_shareContactTitle,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.loading.value) {
              return const SizedBox(width: 8);
            }

            return Center(
              child: Container(
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  appL10n.chatList_contactsCount(controller.filteredContacts.length),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
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
        return _buildSkeleton();
      }

      if (controller.errorMessage.value != null) {
        return _buildError(controller);
      }

      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller.searchController,
                  onChanged: controller.search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: appL10n.chatList_searchNameOrNumber,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: _primary,
                      size: 23,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        tooltip: appL10n.chatList_clearSearch,
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      );
                    }),
                    filled: true,
                    fillColor: _background,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _primary,
                        width: 1.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final contacts = controller.filteredContacts;

              if (contacts.isEmpty) {
                return _buildEmptyState(
                  controller.searchQuery.value.isNotEmpty,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: contacts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 5),
                itemBuilder: (_, index) {
                  final contact = contacts[index];
                  final thumbnail = contact.thumbnail;

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => controller.selectContact(contact),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  ToggleThemeData.Appcolor.withValues(
                                alpha: 0.12,
                              ),
                              backgroundImage: thumbnail != null
                                  ? MemoryImage(thumbnail)
                                  : null,
                              child: thumbnail == null
                                  ? Text(
                                      controller.getInitials(
                                        contact.displayName,
                                      ),
                                      style: TextStyle(
                                        color: ToggleThemeData.Appcolor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.displayName.trim().isEmpty
                                        ? appL10n.chatList_unnamedContact
                                        : contact.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF252538),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    contact.phones.first.number,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: _primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      );
    });
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFEAEBF2),
        highlightColor: Color(0xFFF8F8FC),
        duration: Duration(milliseconds: 1400),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appL10n.chatList_yourContacts,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(appL10n.chatList_chooseContactToShare),
                const SizedBox(height: 18),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (_, __) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Bone.circle(size: 50),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Bone.text(
                              words: 2,
                              fontSize: 15,
                            ),
                            const SizedBox(height: 8),
                            Bone.text(
                              words: 2,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                      const Bone.circle(size: 34),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 78,
              width: 78,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.contacts_rounded,
                size: 36,
                color: _primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isSearching ? appL10n.chatList_noContactsFound : appL10n.chatList_noContactsAvailable,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF252538),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              isSearching
                  ? appL10n.chatList_tryAnotherNameOrNumber
                  : appL10n.chatList_contactsWillAppear,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ContactPickerController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 54,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 14),
            Text(
              controller.permissionDenied.value
                  ? appL10n.chatList_contactsPermissionNeeded
                  : appL10n.chatList_unableToLoadContacts,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value ?? appL10n.chatList_pleaseTryAgain,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: controller.loadContacts,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(appL10n.common_tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Permanently denied: Try again can't show the prompt any more.
            if (controller.permissionDenied.value) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: openAppSettings,
                child: Text(appL10n.chatList_openSettings),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
