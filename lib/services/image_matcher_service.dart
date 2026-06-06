
import '../models/round_record.dart';

class ImageMatcherService {
  /// V2 base module.
  /// Future: crop result strip, compare with saved planet templates, return exact ResultType.
  /// Current source keeps this as a safe placeholder so app structure is ready.
  ResultType matchPlanetFromTemplateName(String templateName) {
    final key = templateName.toLowerCase();
    if (key.contains('purple') && key.contains('25')) return ResultType.purpleX25;
    if (key.contains('purple') && key.contains('50')) return ResultType.pinkPurpleX50;
    if (key.contains('purple')) return ResultType.purpleX5;
    if (key.contains('orange')) return ResultType.orangeX5;
    if (key.contains('light')) return ResultType.lightGreenX5;
    if (key.contains('teal')) return ResultType.tealGreenX5;
    if (key.contains('pink') && key.contains('10')) return ResultType.pinkX10;
    if (key.contains('yellow') || key.contains('15')) return ResultType.yellowX15;
    return ResultType.unknown;
  }
}
