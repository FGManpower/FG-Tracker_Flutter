import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Model/group_call_participant.dart';
import 'package:fgtracker/app/modules/mediaStream/Controller/group_calling_controller.dart';
import 'package:get/get.dart';

class GroupParticipantsSheetController extends GetxController {
  GroupParticipantsSheetController(this.callController);

  final GroupCallingController callController;

  final RxBool isLoading = false.obs;
  final RxList<GroupCallParticipant> inCallList = <GroupCallParticipant>[].obs;
  final RxList<GroupCallParticipant> notInCallList =
      <GroupCallParticipant>[].obs;

  Worker? _socketWorker;

  static final Set<String> _apiLoadedGroupIds = <String>{};

  @override
  void onInit() {
    super.onInit();

    _socketWorker = ever(callController.participantsUiTick, (_) {
      filterParticipants();
    });

    bootstrapMembers();
  }

  @override
  void onClose() {
    _socketWorker?.dispose();
    _socketWorker = null;
    super.onClose();
  }

  Future<void> bootstrapMembers() async {
    final groupId = callController.groupId;

    if (callController.memberData.isNotEmpty ||
        _apiLoadedGroupIds.contains(groupId)) {
      filterParticipants();
      return;
    }

    isLoading.value = true;
    try {
      final res = await GroupRepo.getMemberData(groupId);
      if (res.status == true) {
        callController.memberData.assignAll(res.memberData ?? []);
        _apiLoadedGroupIds.add(groupId);
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
      filterParticipants();
    }
  }

  void filterParticipants() {
    final myUserId = Global.storageServices.get(PrefConst.userId)?.toString();

    final activeIds = <String>{
      ...callController.activeParticipants.map((e) => e.userId),
      ...callController.sheetInCallParticipants.map((e) => e.userId),
    };
    if (myUserId != null && myUserId.isNotEmpty) {
      activeIds.add(myUserId);
    }

    final apiMembers = callController.memberData.toList();
    final newInCall = <GroupCallParticipant>[];
    final newNotInCall = <GroupCallParticipant>[];
    final seen = <String>{};

    for (final member in apiMembers) {
      final uid = (member.userId ?? member.id)?.toString() ?? '';
      if (uid.isEmpty || !seen.add(uid)) continue;

      final isInCall = activeIds.contains(uid);

      if (isInCall) {
        final live = callController.activeParticipants
                .firstWhereOrNull((e) => e.userId == uid) ??
            callController.sheetInCallParticipants
                .firstWhereOrNull((e) => e.userId == uid);

        newInCall.add(
          live ??
              GroupCallParticipant(
                userId: uid,
                name: member.name ?? 'User',
                profileImage: member.profileImage,
                isLocal: uid == myUserId,
                videoOn: false,
                connected: true,
              ),
        );
      } else {
        newNotInCall.add(
          GroupCallParticipant(
            userId: uid,
            name: member.name ?? 'User',
            profileImage: member.profileImage,
            isLocal: false,
            videoOn: false,
            connected: false,
          ),
        );
      }
    }

    for (final live in callController.activeParticipants) {
      if (seen.add(live.userId)) {
        newInCall.add(live);
      }
    }

    newInCall.sort((a, b) {
      if (a.isLocal != b.isLocal) return a.isLocal ? -1 : 1;
      return (a.name ?? '').compareTo(b.name ?? '');
    });
    newNotInCall.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    inCallList.assignAll(newInCall);
    notInCallList.assignAll(newNotInCall);
  }

  void notify(GroupCallParticipant participant) {
    callController.notifyParticipant(participant);
  }

  static void clearApiCacheFor(String groupId) {
    _apiLoadedGroupIds.remove(groupId);
  }
}