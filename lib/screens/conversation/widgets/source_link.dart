import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../build_info.dart';

/// "Source: fala" in the drawer, in the grey of the version line, with "fala"
/// underlined. Tapping it opens [sourceRepoUrl] in the browser.
class SourceLink extends StatelessWidget {
  const SourceLink({super.key});

  @override
  Widget build(BuildContext context) {
    final grey = Theme.of(context).disabledColor;
    return ListTile(
      dense: true,
      title: Text.rich(
        TextSpan(
          text: 'Source: ',
          style: TextStyle(color: grey),
          children: [
            TextSpan(
              text: 'fala',
              style: TextStyle(
                color: grey,
                decoration: TextDecoration.underline,
                decorationColor: grey,
              ),
            ),
          ],
        ),
      ),
      onTap: () => launchUrl(
        Uri.parse(sourceRepoUrl),
        mode: LaunchMode.externalApplication,
      ),
    );
  }
}
