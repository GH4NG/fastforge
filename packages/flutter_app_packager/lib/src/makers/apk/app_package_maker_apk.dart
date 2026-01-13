import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_app_packager/src/api/app_package_maker.dart';

class AppPackageMakerApk extends AppPackageMaker {
  @override
  String get name => 'apk';
  @override
  String get platform => 'android';
  @override
  String get packageFormat => 'apk';

  @override
  Future<MakeResult> make(MakeConfig config) {
    final artifacts = <FileSystemEntity>[];

    for (final file in config.buildOutputFiles) {
      final nameWithoutExt = p.basenameWithoutExtension(file.path);
      final parts = nameWithoutExt.split('-');
      final abi = parts.length >= 3 ? parts[1] : 'unknown';
      final ext = p.extension(file.path);
      final destPath = config.outputArtifactPath.replaceFirst(ext, '-$abi$ext');

      final dest = File(destPath);

      if (!dest.parent.existsSync()) {
        dest.parent.createSync(recursive: true);
      }

      file.copySync(dest.path);
      artifacts.add(dest);
    }

    final resolvedConfig = config.copyWith(config)
      ..buildOutputFiles = artifacts.whereType<File>().toList();
    return Future.value(
      resultResolver.resolve(
        resolvedConfig,
        artifacts: artifacts,
      ),
    );
  }
}
