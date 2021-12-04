
import 'dart:ui';

import 'package:highlight/words.dart';

// the size of images in assets/QuranImg
const assetImageSize = Size(1024, 1656);

String getAssetPath(Word word) {
  return 'assets/QuranImg/${word.pageNum!.toString()}.png';
}