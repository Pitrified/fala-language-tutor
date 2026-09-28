import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/diagnostics/diagnostics_log.dart';

/// The diagnostics log. In memory by default, which is what tests get;
/// `main` overrides it with the Hive-backed one.
final diagnosticsLogProvider = Provider<DiagnosticsLog>(
  (ref) => DiagnosticsLog(),
);
