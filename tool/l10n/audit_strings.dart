// Dev-only audit script. `analyzer` comes in transitively (no pubspec change).
// ignore_for_file: depend_on_referenced_packages, curly_braces_in_flow_control_structures
// Localization audit: finds every string literal in lib/, classifies it by
// where it is used, and inventories the UI surfaces (screens, dialogs,
// sheets, snackbars/toasts, local notifications) and places where API data
// is rendered.
//
//   dart run tool/l10n/audit_strings.dart            # writes build/l10n_audit/
//   dart run tool/l10n/audit_strings.dart --check    # exit 1 if any user-facing
//                                                    # literal is left (Part 2 gate)
//
// Parses only (no type resolution), so classification is by syntax and
// context. Every "review" row was decided by a person; see the docs.
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

const outDir = 'build/l10n_audit';

/// Login + OTP stay in English (spec). Everything else is translated.
const excludedFiles = {
  'lib/app/modules/auth/Views/login_Page.dart',
  'lib/app/modules/auth/Views/Otp_Screen.dart',
  'lib/app/modules/auth/Controller/OtpController.dart',
  'lib/app/modules/auth/Controller/login_controller.dart',
};

const skipDirs = ['lib/gen/', 'lib/generated/', 'lib/l10n/'];

// ---------------------------------------------------------------- contexts

const logCallees = {
  'log',
  'print',
  'debugPrint',
  'developer.log',
  'dev.log',
  'debugLog',
  'AppLog.d',
  'AppLog.e',
  'AppLog.i',
  'AppLog.w',
  'AppLog.v',
  'logger.d',
  'logger.e',
  'logger.i',
  'logger.w',
  '_log',
  'Log.d',
  'Log.e',
  'printLog',
  'assert',
  'logPrint',
  'debugPrintStack',
  'FlutterError',
};

/// Calls whose string args are identifiers, keys, paths or formats.
const nonUiCalleeNames = {
  'setString',
  'getString',
  'setBool',
  'getBool',
  'setInt',
  'getInt',
  'setDouble',
  'getDouble',
  'remove',
  'containsKey',
  'get',
  'getBoolSync',
  'emit',
  'on',
  'off',
  'once',
  'emitWithAck',
  'toNamed',
  'offNamed',
  'offAllNamed',
  'offAndToNamed',
  'pushNamed',
  'parse',
  'tryParse',
  'RegExp',
  'DateFormat',
  'asset',
  'AssetImage',
  'Image.asset',
  'SvgPicture.asset',
  'Lottie.asset',
  'Key',
  'ValueKey',
  'ObjectKey',
  'GlobalKey',
  'PageStorageKey',
  'MethodChannel',
  'EventChannel',
  'BasicMessageChannel',
  'invokeMethod',
  'Locale',
  'replaceAll',
  'split',
  'contains',
  'startsWith',
  'endsWith',
  'indexOf',
  'replaceFirst',
  'join',
  'padLeft',
  'padRight',
  'Duration',
  'Uri',
  'Uri.parse',
  'http.get',
  'http.post',
  'post',
  'put',
  'patch',
  'delete',
  'getRequest',
  'postRequest',
  'sendRequest',
  'fetch',
  'add',
  'addAll',
  'Get.find',
  'Get.put',
  'Get.isRegistered',
  'Get.delete',
  'Get.lazyPut',
  'Permission',
  'MapEntry',
  'Color',
  'FontWeight',
  'TextStyle',
  'jsonDecode',
  'jsonEncode',
  'File',
  'Directory',
  'MultipartFile.fromFile',
  'FormData.fromMap',
  'Options',
  'Headers',
  'BaseOptions',
  'DateTime.parse',
  'launchUrl',
  'canLaunchUrl',
  'Hero',
  'heroTag',
  'NumberFormat',
  'NumberFormat.currency',
  'compareTo',
  'where',
  'firstWhere',
  'any',
  'cast',
  'containsValue',
  'putIfAbsent',
  'Intent',
  'AndroidIntent',
  'MarkerId',
  'PolylineId',
  'CircleId',
  'PolygonId',
  'BitmapDescriptor.fromAssetImage',
  'ScreenshotController',
  'SharedPreferences',
  'getAll',
  'setStringList',
  'getStringList',
  'Tag',
  'tag',
  'Topic',
  'subscribeToTopic',
  'unsubscribeFromTopic',
  'socket.emit',
  'emitEvent',
  'listenEvent',
  'io',
  'OptionBuilder',
  'setTransports',
  'setPath',
  'setQuery',
  'setExtraHeaders',
};

/// Calls whose (positional) string args are shown to the user.
const uiCalleeNames = {
  'Text',
  'Text.rich',
  'TextSpan',
  'SelectableText',
  'Tooltip',
  'SnackBar',
  'Get.snackbar',
  'Get.rawSnackbar',
  'Fluttertoast.showToast',
  'showToast',
  'CommonDialog.errorMessage',
  'CommonDialog.ConfirmationDialog',
  'CommonDialog.sessionExpiredDialog',
  'AlertDialog',
  'Get.defaultDialog',
  'AutoSizeText',
  'Semantics',
  'Linkify',
  'SelectableLinkify',
  'Chip',
  'Tab',
  'BottomNavigationBarItem',
  'NavigationDestination',
  'PopupMenuItem',
  'DropdownMenuItem',
  'TextButton',
  'ElevatedButton',
};

/// Named args that carry user-visible text.
const uiNamedArgs = {
  'title',
  'subtitle',
  'subTitle',
  'label',
  'labelText',
  'hintText',
  'helperText',
  'errorText',
  'tooltip',
  'message',
  'msg',
  'content',
  'confirm',
  'cancel',
  'textConfirm',
  'textCancel',
  'middleText',
  'semanticLabel',
  'semanticsLabel',
  'buttonText',
  'text',
  'body',
  'description',
  'heading',
  'confirmText',
  'cancelText',
  'okText',
  'placeholder',
  'counterText',
  'prefixText',
  'suffixText',
  'hint',
  'titleText',
  'messageText',
  'subtitleText',
  'actionText',
  'btnText',
  'buttonLabel',
  'primaryText',
  'secondaryText',
  'emptyText',
  'errorMessage',
  'successMessage',
  'positiveText',
  'negativeText',
  'header',
  'caption',
  'channelName',
  'channelDescription',
  'ticker',
  'summaryText',
  'contentTitle',
  'bigText',
  'longText',
  'name',
  'tag',
  'subText',
  'info',
  'note',
  'confirmLabel',
  'cancelLabel',
  'emptyTitle',
  'emptySubtitle',
  'reason',
  'subtitleTxt',
  'titleTxt',
  'onConfirmText',
  'detail',
  'heroTitle',
  'badge',
  'chipText',
  'value',
  'textLabel',
  'labelTxt',
};

/// Named args that look textual but are identifiers.
const nonUiNamedArgs = {
  'fontFamily',
  'package',
  'routeName',
  'restorationId',
  'heroTag',
  'channelKey',
  'channelId',
  'groupKey',
  'icon',
  'largeIcon',
  'sound',
  'payload',
  'id',
  'key',
  'url',
  'imageUrl',
  'path',
  'filePath',
  'image',
  'asset',
  'assetPath',
  'type',
  'event',
  'locale',
  'pattern',
  'format',
  'method',
  'endpoint',
  'baseUrl',
  'contentType',
  'mimeType',
  'extension',
  'screenName',
  'screen_name',
  'source',
  'mode',
  'status',
  'action',
  'category',
  'groupId',
  'uuid',
  'handle',
  'appName',
  'avatar',
  'callerId',
  'number',
  'nameCaller',
  'textAccept',
  'textDecline',
  'subtitleCallkit',
};

// ---------------------------------------------------------------- model

class Row {
  Row(this.file, this.line, this.category, this.context, this.text,
      {this.where = ''});
  final String file;
  final int line;
  final String category;
  final String context;
  final String text;
  final String where;
}

final strings = <Row>[];
final surfaces = <Row>[];
final apiSinks = <Row>[];
final imports = <String, List<String>>{};

String moduleOf(String file) {
  final m = RegExp(r'^lib/app/modules/([^/]+)').firstMatch(file) ??
      RegExp(r'^lib/features/([^/]+)').firstMatch(file);
  if (m != null) {
    if (file.startsWith('lib/app/modules/') && m.group(1)!.endsWith('.dart')) {
      return 'common';
    }
    return m.group(1)!;
  }
  if (file.startsWith('lib/app/Data/')) return 'core (Data)';
  if (file.startsWith('lib/app/Core/')) return 'core (Core)';
  if (file.startsWith('lib/app/widgets/') ||
      file.startsWith('lib/app/global_widget/')) return 'core (widgets)';
  return 'core';
}

bool _hasLetter(String s) => RegExp(r'[A-Za-zऀ-෿]').hasMatch(s);

/// Does a string with unknown context read like text for people?
bool looksHuman(String s) {
  final t = s.trim();
  if (t.isEmpty || !_hasLetter(t)) return false;
  if (RegExp(r'^(https?:|www\.|/|\.|#|\$|%|@)').hasMatch(t)) return false;
  if (RegExp(r'\.(png|jpe?g|svg|gif|webp|json|mp3|mp4|wav|ttf|otf|dart|pdf)$',
          caseSensitive: false)
      .hasMatch(t)) return false;
  if (RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(t)) return false; // camelCase
  if (RegExp(r'^[a-zA-Z0-9]+(_[a-zA-Z0-9]+)+$').hasMatch(t)) return false;
  if (RegExp(r'^[A-Z0-9_]+$').hasMatch(t) && t.length > 1) return false;
  if (RegExp(r'^[a-z0-9-]+(-[a-z0-9]+)+$').hasMatch(t)) return false;
  if (RegExp(r'^[a-zA-Z]+/[a-zA-Z.+-]+$').hasMatch(t)) return false; // mime
  if (RegExp(r'^[yMdHhmsaEZ:\-/., ]+$').hasMatch(t)) return false; // date fmt
  if (t.contains(' ')) return true;
  return RegExp(r'^[A-Z][a-z]{2,}[!?.]?$').hasMatch(t); // e.g. "Cancel"
}

/// Project helpers that render their string args (found in the first audit).
final uiHelperRe =
    RegExp(r'^(reausabletext|reusableText|fluttertoast|showGenericErrorMessage|'
        r'inputField|_?build[A-Z]\w*|_?show[A-Z]\w*(Error|Message|Toast|Snack|'
        r'Dialog|Sheet|Info|Success|Warning)\w*|_?(info|stat|label|section|'
        r'title|chip|pill|badge|step|row|tile|header|menu|option|action|button|'
        r'empty|error)[A-Z]?\w*)$');

/// Relaxed test for args of a known UI helper: allows "OK", "SOS", "May".
bool looksWordy(String s) {
  final t = s.trim();
  if (!_hasLetter(t)) return false;
  if (RegExp(r'^(https?:|www\.|assets/|/)').hasMatch(t)) return false;
  if (RegExp(r'\.(png|jpe?g|svg|gif|webp|json|mp3|mp4|ttf)$').hasMatch(t)) {
    return false;
  }
  if (RegExp(r'^[a-z]+(_[a-z0-9]+)+$').hasMatch(t)) return false;
  if (RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(t) &&
      t.length > 3 &&
      RegExp(r'[A-Z]').hasMatch(t)) {
    return false; // camelCase id
  }
  return true;
}

final stateRe = RegExp(
    r"\b(no [a-z]+|nothing|empty|loading|please wait|error|failed|"
    r"something went wrong|try again|retry|offline|no internet|"
    r"connection|not found|unable|couldn'?t|can'?t)\b",
    caseSensitive: false);

// ---------------------------------------------------------------- visitor

class Collector extends RecursiveAstVisitor<void> {
  Collector(this.file, this.unit);
  final String file;
  final CompilationUnit unit;

  int lineOf(AstNode n) => unit.lineInfo.getLocation(n.offset).lineNumber;

  String enclosing(AstNode n) {
    String? cls;
    String? member;
    for (AstNode? p = n.parent; p != null; p = p.parent) {
      if (member == null && p is MethodDeclaration) {
        member = p.name.lexeme;
      } else if (member == null && p is FunctionDeclaration) {
        member = p.name.lexeme;
      } else if (cls == null && p is ClassDeclaration) {
        cls = RegExp(r'class\s+(\w+)').firstMatch(p.toSource())?.group(1);
      } else if (cls == null && p is MixinDeclaration) {
        cls = RegExp(r'mixin\s+(\w+)').firstMatch(p.toSource())?.group(1);
      } else if (cls == null && p is ExtensionDeclaration) {
        cls = 'extension';
      }
    }
    return [cls, member].whereType<String>().join('.');
  }

  static String calleeOf(AstNode call) {
    if (call is MethodInvocation) {
      final t = call.target?.toSource();
      final name = call.methodName.name;
      if (t == null) return name;
      final shortT = t.length > 40 ? t.substring(t.length - 40) : t;
      return '$shortT.$name';
    }
    if (call is InstanceCreationExpression) {
      return call.constructorName.toSource().replaceAll(RegExp(r'<.*>'), '');
    }
    if (call is FunctionExpressionInvocation) return call.function.toSource();
    if (call is SuperConstructorInvocation) return 'super';
    if (call is RedirectingConstructorInvocation) return 'this';
    if (call is Annotation) return '@${call.name.toSource()}';
    return call.runtimeType.toString();
  }

  static bool calleeMatches(String callee, Set<String> names) {
    if (names.contains(callee)) return true;
    final last = callee.split('.').last;
    return names.contains(last);
  }

  /// Climbs from a literal to the node that decides its meaning.
  (String category, String context) classify(StringLiteral lit) {
    AstNode n = lit;
    String? named;
    while (true) {
      final p = n.parent;
      if (p == null) return ('review', 'top');
      if (p is Directive || p is Annotation) return ('skip', 'directive');
      if (p is ParenthesizedExpression ||
          p is AsExpression ||
          p is AdjacentStrings ||
          p is InterpolationExpression ||
          p is StringInterpolation ||
          p is AwaitExpression) {
        n = p;
        continue;
      }
      if (p is ConditionalExpression) {
        if (p.condition == n) return ('non-ui', 'condition');
        n = p;
        continue;
      }
      if (p is BinaryExpression) {
        final op = p.operator.lexeme;
        if (op == '+' || op == '??') {
          n = p;
          continue;
        }
        return ('non-ui', 'comparison $op');
      }
      if (p is MethodInvocation && p.target == n) {
        final m = p.methodName.name;
        if (m == 'tr' ||
            m == 'trArgs' ||
            m == 'toUpperCase' ||
            m == 'toLowerCase' ||
            m == 'trim') {
          n = p;
          continue;
        }
        return ('non-ui', '.$m()');
      }
      if (p is PropertyAccess && p.target == n) {
        final m = p.propertyName.name;
        if (m == 'tr' || m == 'capitalize' || m == 'capitalizeFirst') {
          n = p;
          continue;
        }
        return ('non-ui', '.$m');
      }
      if (p is IndexExpression) return ('non-ui', 'index key');
      if (p is MapLiteralEntry) {
        return p.key == n ? ('non-ui', 'map key') : _decideMapValue(p);
      }
      if (p is SwitchCase || p is ConstantPattern || p is SwitchPatternCase) {
        return ('non-ui', 'switch case');
      }
      if (p is NamedArgument) {
        named = p.name.lexeme;
        n = p;
        continue;
      }
      if (p is ArgumentList) {
        final call = p.parent!;
        final callee = calleeOf(call);
        final ctx = named == null ? callee : '$callee($named:)';
        final last = callee.split('.').last;
        if (calleeMatches(callee, logCallees) ||
            RegExp(r'^_?[a-zA-Z]*[lL]og$|^_ck$|^_dbg$|^_trace$')
                .hasMatch(last)) {
          return ('log', ctx);
        }
        // Project UI helpers (reausabletext, Utils().fluttertoast, _buildX,
        // _showX, …): any word-like text passed to them is shown to users.
        if (uiHelperRe.hasMatch(last) &&
            looksWordy(lit.stringValue ?? _interp(lit))) {
          return (_isNotification(callee) ? 'notification' : 'ui', ctx);
        }
        if (call is InstanceCreationExpression &&
            RegExp(r'(Exception|Error)$').hasMatch(callee)) {
          return ('exception', ctx);
        }
        if (named != null) {
          if (nonUiNamedArgs.contains(named)) return ('non-ui', ctx);
          if (uiNamedArgs.contains(named)) {
            return (_isNotification(callee) ? 'notification' : 'ui', ctx);
          }
        }
        if (calleeMatches(callee, nonUiCalleeNames)) return ('non-ui', ctx);
        if (calleeMatches(callee, uiCalleeNames)) return ('ui', ctx);
        if (_isNotification(callee)) return ('notification', ctx);
        return (
          looksHuman(lit.stringValue ?? _interp(lit)) ? 'review' : 'non-ui',
          ctx
        );
      }
      if (p is ThrowExpression) return ('exception', 'throw');
      if (p is VariableDeclaration) {
        final cls = enclosing(p).split('.').first;
        if (cls == 'AppText')
          return ('ui-constant', 'AppText.${p.name.lexeme}');
        return (
          looksHuman(lit.stringValue ?? _interp(lit)) ? 'review' : 'non-ui',
          'var ${p.name.lexeme}'
        );
      }
      if (p is AssignmentExpression) {
        final target = p.leftHandSide.toSource();
        return (
          looksHuman(lit.stringValue ?? _interp(lit)) ? 'review' : 'non-ui',
          '$target ='
        );
      }
      if (p is ReturnStatement || p is ExpressionFunctionBody) {
        final where = enclosing(p);
        if (_insideValidator(p)) return ('ui', 'validator');
        return (
          looksHuman(lit.stringValue ?? _interp(lit)) ? 'review' : 'non-ui',
          'return in $where'
        );
      }
      if (p is ListLiteral || p is SetOrMapLiteral) {
        return (
          looksHuman(lit.stringValue ?? _interp(lit)) ? 'review' : 'non-ui',
          'list item'
        );
      }
      if (p is FormalParameter) {
        return (
          looksHuman(lit.stringValue ?? _interp(lit)) ? 'review' : 'non-ui',
          'default param'
        );
      }
      return (
        looksHuman(lit.stringValue ?? _interp(lit)) ? 'review' : 'non-ui',
        p.runtimeType.toString()
      );
    }
  }

  (String, String) _decideMapValue(MapLiteralEntry e) {
    final key = e.key.toSource().replaceAll(RegExp(r'''['"]'''), '');
    final v = e.value is StringLiteral
        ? ((e.value as StringLiteral).stringValue ?? '')
        : '';
    if (RegExp(
            r'^(title|subtitle|label|message|msg|body|text|description|'
            r'name|hint|heading|content|cta|button)',
            caseSensitive: false)
        .hasMatch(key)) {
      return ('ui', 'map value [$key]');
    }
    return (looksHuman(v) ? 'review' : 'non-ui', 'map value [$key]');
  }

  static bool _isNotification(String callee) =>
      RegExp(r'Notification|AndroidNotification|NotificationContent|'
              r'NotificationChannel|DarwinNotification|showWalkieNotification|'
              r'LocalNotif|Plugin\.show|plugin\.show|_notifications?\.show')
          .hasMatch(callee);

  static bool _insideValidator(AstNode n) {
    for (AstNode? p = n.parent; p != null; p = p.parent) {
      if (p is NamedArgument && p.name.lexeme == 'validator') return true;
      if (p is MethodDeclaration &&
          p.name.lexeme.toLowerCase().contains('valid')) {
        return true;
      }
      if (p is FunctionDeclaration &&
          p.name.lexeme.toLowerCase().contains('valid')) {
        return true;
      }
      if (p is ClassDeclaration) return false;
    }
    return false;
  }

  static String _interp(StringLiteral lit) {
    if (lit is StringInterpolation) {
      return lit.elements.map((e) {
        if (e is InterpolationString) return e.value;
        final src = (e as InterpolationExpression).expression.toSource();
        return '{$src}';
      }).join();
    }
    if (lit is AdjacentStrings) {
      return lit.strings.map(_interp).join();
    }
    return lit.stringValue ?? lit.toSource();
  }

  void _record(StringLiteral lit) {
    final text = _interp(lit);
    if (text.trim().isEmpty) return;
    final (cat, ctx) = classify(lit);
    if (cat == 'skip') return;
    var category = cat;
    if (category == 'non-ui' && !_hasLetter(text)) category = 'non-ui';
    if ((category == 'ui' || category == 'review') && !_hasLetter(text)) {
      category = 'symbol';
    }
    strings.add(
        Row(file, lineOf(lit), category, ctx, text, where: enclosing(lit)));
  }

  @override
  void visitAdjacentStrings(AdjacentStrings node) => _record(node);

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.parent is AdjacentStrings) return;
    _record(node);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    if (node.parent is AdjacentStrings) return;
    _record(node);
    super.visitStringInterpolation(node); // literals inside ${...}
  }

  // ---------------------------------------------------------- surfaces

  void _surface(AstNode n, String kind, String detail) {
    surfaces.add(Row(file, lineOf(n), kind, detail, '', where: enclosing(n)));
  }

  String _firstLiteralTitle(AstNode n) {
    String? found;
    n.accept(_FirstTitle((s) => found ??= s));
    return found ?? '';
  }

  void _maybeApiSink(Expression? e, String context, AstNode at) {
    if (e == null || e is StringLiteral) return;
    final src = e.toSource();
    if (src.length > 120) return;
    String? kind;
    if (RegExp(r'(\.message|\.msg|\[.message.\]|e\.toString\(\)|'
            r'error\.toString|\.error\b|\.errorMessage|response\.|res\.message|'
            r'result\.message|data\[.message.\])')
        .hasMatch(src)) {
      kind = 'server message / error';
    } else if (RegExp(
            r'(name|Name|title|Title|description|Description|label|Label|'
            r'tagline|badge|address|Address|mobile|phone|email|caption|'
            r'text|content|Content|message|Message|reason|planName|status)\b')
        .hasMatch(src)) {
      kind = 'API field';
    }
    if (kind == null) return;
    apiSinks
        .add(Row(file, lineOf(at), kind, context, src, where: enclosing(at)));
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final callee = calleeOf(node);
    final name = node.methodName.name;
    final target = node.target?.toSource() ?? '';
    if ({'showDialog', 'showCupertinoDialog', 'showGeneralDialog'}
            .contains(name) ||
        (target == 'Get' && (name == 'dialog' || name == 'defaultDialog')) ||
        (target == 'CommonDialog' && name != 'errorMessage')) {
      _surface(node, 'dialog', '$callee ${_firstLiteralTitle(node)}'.trim());
    } else if ({
          'showModalBottomSheet',
          'showBottomSheet',
          'showCupertinoModalPopup'
        }.contains(name) ||
        (target == 'Get' && name == 'bottomSheet')) {
      _surface(
          node, 'bottom sheet', '$callee ${_firstLiteralTitle(node)}'.trim());
    } else if ((target == 'Get' &&
            (name == 'snackbar' || name == 'rawSnackbar')) ||
        name == 'showSnackBar' ||
        callee == 'Fluttertoast.showToast' ||
        callee == 'CommonDialog.errorMessage' ||
        name == 'showToast') {
      _surface(node, 'snackbar / toast',
          '$callee ${_firstLiteralTitle(node)}'.trim());
      for (final a in node.argumentList.arguments) {
        _maybeApiSink(a.argumentExpression, callee, node);
      }
    } else if (name == 'createNotification' ||
        (name == 'show' &&
            RegExp(r'otification|plugin', caseSensitive: false)
                .hasMatch(target)) ||
        name == 'showWalkieNotification' ||
        name == 'createNotificationChannel') {
      _surface(node, 'local notification',
          '$callee ${_firstLiteralTitle(node)}'.trim());
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final callee = calleeOf(node);
    if ({
          'Text',
          'SelectableText',
          'AutoSizeText',
          'Linkify',
          'SelectableLinkify'
        }.contains(callee) &&
        node.argumentList.arguments.isNotEmpty) {
      final first = node.argumentList.arguments.first;
      if (first is! NamedArgument)
        _maybeApiSink(first.argumentExpression, callee, node);
    }
    if ({
      'AndroidNotificationChannel',
      'NotificationContent',
      'NotificationChannel'
    }.contains(callee)) {
      _surface(node, 'local notification', callee);
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final src = node.toSource();
    final header = src.split('{').first;
    final name = RegExp(r'class\s+(\w+)').firstMatch(header)?.group(1) ?? '?';
    final isWidget =
        RegExp(r'extends\s+(StatelessWidget|StatefulWidget|GetView|GetWidget|'
                r'State<)')
            .hasMatch(header);
    if (isWidget && src.contains('Scaffold(')) {
      var screen = name;
      final st = RegExp(r'extends\s+State<(\w+)>').firstMatch(header);
      if (st != null) screen = st.group(1)!;
      if (!surfaces.any((r) =>
          r.category == 'screen' && r.context == screen && r.file == file)) {
        surfaces.add(Row(file, lineOf(node), 'screen', screen, ''));
      }
    }
    super.visitClassDeclaration(node);
  }
}

class _FirstTitle extends RecursiveAstVisitor<void> {
  _FirstTitle(this.onFound);
  final void Function(String) onFound;
  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final v = node.value;
    if (looksHuman(v))
      onFound('"${v.length > 50 ? '${v.substring(0, 50)}…' : v}"');
  }
}

// ---------------------------------------------------------------- reachability

Set<String> reachableFrom(String entry, Map<String, List<String>> imports) {
  final seen = <String>{};
  final stack = [entry];
  while (stack.isNotEmpty) {
    final f = stack.removeLast();
    if (!seen.add(f)) continue;
    stack.addAll(imports[f] ?? const []);
  }
  return seen;
}

String? resolveUri(String from, String uri) {
  if (uri.startsWith('package:fgtracker/')) {
    return 'lib/${uri.substring('package:fgtracker/'.length)}';
  }
  if (uri.contains(':')) return null;
  final parts = from.split('/')..removeLast();
  for (final seg in uri.split('/')) {
    if (seg == '..') {
      parts.removeLast();
    } else if (seg != '.') {
      parts.add(seg);
    }
  }
  return parts.join('/');
}

// ---------------------------------------------------------------- output

const relevant = {
  'ui',
  'ui-constant',
  'notification',
  'review',
  'symbol',
  'exception',
};

String md(String s) => s
    .replaceAll('|', r'\|')
    .replaceAll('\n', ' ')
    .replaceAll('<', r'\<')
    .replaceAll('*', r'\*')
    .replaceAll('_', r'\_');

/// Human-readable appendix: every surface, every user-facing string, every
/// place API text is rendered. Regenerated on each run.
void writeInventory(Set<String> reachable) {
  bool live(Row r) => reachable.contains(r.file);
  final b = StringBuffer()
    ..writeln('# Language audit — full inventory (generated)')
    ..writeln()
    ..writeln('Generated by `dart run tool/l10n/audit_strings.dart`. '
        'Do not edit by hand. Summary and decisions: '
        '[../01_audit_and_changes.md](../01_audit_and_changes.md).')
    ..writeln()
    ..writeln('Only files reachable from `lib/main.dart` are listed. '
        'Login/OTP files are marked **(Login/OTP — stays English)**.')
    ..writeln();

  final modules = <String>{
    ...strings.where(live).map((r) => moduleOf(r.file)),
    ...surfaces.where(live).map((r) => moduleOf(r.file)),
  }.toList()
    ..sort();

  b.writeln('## Contents');
  for (final m in modules) {
    b.writeln(
        '- [$m](#${m.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 -]'), '').replaceAll(' ', '-')})');
  }
  b.writeln('- [API text rendered as-is](#api-text-rendered-as-is)');
  b.writeln(
      '- [Files not reachable from main.dart](#files-not-reachable-from-maindart)');
  b.writeln();

  for (final m in modules) {
    b.writeln('## $m');
    b.writeln();
    final surf =
        surfaces.where((r) => live(r) && moduleOf(r.file) == m).toList();
    if (surf.isNotEmpty) {
      b.writeln('### Surfaces');
      b.writeln();
      b.writeln('| Kind | Where | File:line | Detail |');
      b.writeln('|---|---|---|---|');
      for (final kind in [
        'screen',
        'dialog',
        'bottom sheet',
        'snackbar / toast',
        'local notification'
      ]) {
        for (final r in surf.where((r) => r.category == kind)) {
          final ex = excludedFiles.contains(r.file) ? ' (Login/OTP)' : '';
          b.writeln('| $kind | ${md(r.where)} | `${r.file}:${r.line}`$ex | '
              '${md(r.context)} |');
        }
      }
      b.writeln();
    }
    final rows = strings
        .where((r) =>
            live(r) &&
            moduleOf(r.file) == m &&
            {'ui', 'ui-constant', 'notification', 'review'}
                .contains(r.category))
        .toList();
    if (rows.isEmpty) continue;
    b.writeln('### Strings');
    b.writeln();
    String? lastFile;
    for (final r in rows) {
      if (r.file != lastFile) {
        lastFile = r.file;
        final ex = excludedFiles.contains(r.file)
            ? ' **(Login/OTP — stays English)**'
            : '';
        b.writeln();
        b.writeln('**`${r.file}`**$ex');
        b.writeln();
        b.writeln('| Line | Kind | Used in | Text |');
        b.writeln('|---|---|---|---|');
      }
      final kind = r.category == 'review' ? 'likely UI' : r.category;
      b.writeln('| ${r.line} | $kind | ${md(r.context)} | ${md(r.text)} |');
    }
    b.writeln();
  }

  b.writeln('## API text rendered as-is');
  b.writeln();
  b.writeln('Places where a value from the API (names, titles, server '
      'messages/errors) is put on screen. These stay exactly as received.');
  b.writeln();
  b.writeln('| Module | Kind | File:line | Shown by | Expression |');
  b.writeln('|---|---|---|---|---|');
  for (final r in apiSinks.where(live)) {
    b.writeln('| ${moduleOf(r.file)} | ${r.category} | `${r.file}:${r.line}` | '
        '${md(r.context)} | `${r.text.replaceAll('|', r'\|').replaceAll('`', "'")}` |');
  }
  b.writeln();

  b.writeln('## Files not reachable from main.dart');
  b.writeln();
  b.writeln('Not imported anywhere from the app entry point (dead code, '
      'backups, or only used by tests). Not translated.');
  b.writeln();
  final dead = imports.keys.where((f) => !reachable.contains(f)).toList()
    ..sort();
  for (final f in dead) {
    b.writeln('- `$f`');
  }

  File('$outDir/inventory.md').writeAsStringSync(b.toString());
}

String csv(List<Object?> cells) => cells.map((c) {
      final s = '$c'.replaceAll('\r', ' ').replaceAll('\n', r'\n');
      return '"${s.replaceAll('"', '""')}"';
    }).join(',');

void main(List<String> args) {
  final check = args.contains('--check');
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.replaceAll(r'\', '/'))
      .where((p) => p.endsWith('.dart'))
      .where((p) => !skipDirs.any(p.startsWith))
      .toList()
    ..sort();

  imports.clear();
  for (final path in files) {
    final result = parseFile(
        path: File(path).absolute.path,
        featureSet: FeatureSet.latestLanguageVersion(),
        throwIfDiagnostics: false);
    final unit = result.unit;
    imports[path] = [
      for (final d in unit.directives)
        if (d is UriBasedDirective && d.uri.stringValue != null)
          if (resolveUri(path, d.uri.stringValue!) case final r?) r,
    ];
    unit.accept(Collector(path, unit));
  }
  final reachable = reachableFrom('lib/main.dart', imports);

  bool translatable(Row r) =>
      !excludedFiles.contains(r.file) && reachable.contains(r.file);

  if (check) {
    final left = strings
        .where((r) => translatable(r))
        .where(
            (r) => {'ui', 'ui-constant', 'notification'}.contains(r.category))
        .toList();
    for (final r in left) {
      stdout.writeln('${r.file}:${r.line}  [${r.context}]  ${r.text}');
    }
    stdout.writeln('${left.length} user-facing literal(s) left.');
    exit(left.isEmpty ? 0 : 1);
  }

  Directory(outDir).createSync(recursive: true);

  File('$outDir/strings.csv').writeAsStringSync([
    csv([
      'module',
      'file',
      'line',
      'category',
      'context',
      'where',
      'login_otp_excluded',
      'reachable',
      'text'
    ]),
    // Logs, JSON/map keys, comparisons etc. are counted in summary.json only.
    for (final r in strings)
      if (relevant.contains(r.category))
        csv([
          moduleOf(r.file),
          r.file,
          r.line,
          r.category,
          r.context,
          r.where,
          excludedFiles.contains(r.file),
          reachable.contains(r.file),
          r.text
        ]),
  ].join('\n'));

  File('$outDir/surfaces.csv').writeAsStringSync([
    csv([
      'module',
      'kind',
      'file',
      'line',
      'where',
      'detail',
      'reachable',
      'login_otp_excluded'
    ]),
    for (final r in surfaces)
      csv([
        moduleOf(r.file),
        r.category,
        r.file,
        r.line,
        r.where,
        r.context,
        reachable.contains(r.file),
        excludedFiles.contains(r.file)
      ]),
  ].join('\n'));

  File('$outDir/api_sinks.csv').writeAsStringSync([
    csv([
      'module',
      'kind',
      'file',
      'line',
      'where',
      'shown_by',
      'expression',
      'reachable'
    ]),
    for (final r in apiSinks)
      csv([
        moduleOf(r.file),
        r.category,
        r.file,
        r.line,
        r.where,
        r.context,
        r.text,
        reachable.contains(r.file)
      ]),
  ].join('\n'));

  writeInventory(reachable);

  // Summary
  final modules = <String>{...strings.map((r) => moduleOf(r.file))}.toList()
    ..sort();
  final summary = <String, Object>{};
  for (final m in modules) {
    final rows = strings.where((r) => moduleOf(r.file) == m && translatable(r));
    final cats = <String, int>{};
    for (final r in rows) {
      cats[r.category] = (cats[r.category] ?? 0) + 1;
    }
    final uniqueUi = rows
        .where((r) => {'ui', 'ui-constant', 'notification', 'review'}
            .contains(r.category))
        .map((r) => r.text.trim())
        .toSet()
        .length;
    final surf = <String, int>{};
    for (final r
        in surfaces.where((r) => moduleOf(r.file) == m && translatable(r))) {
      surf[r.category] = (surf[r.category] ?? 0) + 1;
    }
    summary[m] = {
      'categories': cats,
      'unique_ui_or_review_texts': uniqueUi,
      'surfaces': surf,
      'api_sinks': apiSinks
          .where((r) => moduleOf(r.file) == m && translatable(r))
          .length,
    };
  }
  final unreachable = files.where((f) => !reachable.contains(f)).toList();
  summary['_unreachable_files'] = unreachable;
  summary['_excluded_login_otp_files'] = excludedFiles.toList();
  summary['_totals'] = {
    'files': files.length,
    'reachable_files': files.where(reachable.contains).length,
    'literals': strings.length,
    'surfaces': surfaces.length,
    'api_sinks': apiSinks.length,
  };
  File('$outDir/summary.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(summary));

  stdout.writeln('files: ${files.length}  reachable: '
      '${files.where(reachable.contains).length}  literals: ${strings.length}  '
      'surfaces: ${surfaces.length}  api sinks: ${apiSinks.length}');
}
