
import 'dart:ui';

import 'package:highlight/words.dart';

// the size of images in assets/QuranImg
const assetImageSize = Size(1024, 1656);

String getAssetPath(int pageNumber) {
  return 'assets/QuranImg/${pageNumber.toString()}.png';
}