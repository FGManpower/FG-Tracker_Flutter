import 'dart:convert';
import 'dart:io';

void main() {
  const updates = {
    'chat_list.json': {
      'chatList_sectionGroups': 'ଗୋଷ୍ଠୀ',
    },
    'track_misc.json': {
      'track_groupsHeader': 'ଗୋଷ୍ଠୀ ({count})',
    },
    'chat_screen.json': {
      'voice_audioChip': 'ଅଡିଓ',
    },
    'walkie_plans.json': {
      'walkiePlan_orderNetBanking': 'ନେଟ୍ ବ୍ୟାଙ୍କିଙ୍ଗ୍',
      'walkiePlan_payMethodNetBanking': 'ନେଟ୍ ବ୍ୟାଙ୍କିଙ୍ଗ୍ ({bank})',
      'walkiePlan_successPaid': 'ପୈଠ କରାଗଲା',
    },
  };

  for (final entry in updates.entries) {
    final file = File('tool/l10n/fragments/${entry.key}');
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    for (final k in entry.value.keys) {
      if (data.containsKey(k)) {
        (data[k] as Map<String, dynamic>)['or'] = entry.value[k]!;
        print('Updated ${entry.key} -> $k to ${entry.value[k]}');
      }
    }
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }
}

