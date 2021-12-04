import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import 'package:highlight/util.dart';
import 'package:highlight/words.dart';

import 'database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // set the database path
  await setDatabasePath();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'hafs',
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: const HafsWordDB(),
      ),
    );
  }
}

class HafsWordDB extends StatefulWidget {
  const HafsWordDB({Key? key}) : super(key: key);

  @override
  _HafsWordDBState createState() => _HafsWordDBState();
}

class _HafsWordDBState extends State<HafsWordDB> {
  late final Database db;
  bool isDatabaseReady = false;
  bool databaseOpenError = false;
  @override
  void initState() {
    super.initState();
    // Open the database and store the reference.
    _openDataBase();
  }

  void _openDataBase() async {
    try {
      db = await getDatabase();
      setState(() {
        isDatabaseReady = true;
      });
    } catch (e) {
      databaseOpenError = true;
      print('error while opening database $e');
    }
  }

  // final Future<Database> database = getDatabasesPath().then((String path) {
  //   return openDatabase(join(path, 'hafs.db'));
  // });

  Future<List<Word>> gettingWords() async {
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM hafsData WHERE page IS NOT NULL ORDER BY page ASC');
    return List.generate(maps.length, (i) {
      return Word(
        // These values are page sensitive
        pageNum: maps[i]['page'], // this was 'Page' before and it's wrong
        verseNum: maps[i]['verse'],
        word: maps[i]['word'],
        surahName: maps[i]['surah'], // this was 'Surah' before and it's wrong
        details: maps[i]['explanation'],
        title: maps[i]['chapters'],
        // those are stored in the database as integers and real so it's confusing
        // convert everything to double
        x: (maps[i]['x'] as num).toDouble(),
        y: (maps[i]['y'] as num).toDouble(),
        w: (maps[i]['w'] as num).toDouble(),
        h: (maps[i]['h'] as num).toDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isDatabaseReady) {
      return const Center(child: CircularProgressIndicator());
    }

    if (databaseOpenError) {
      return const Center(child: Text('could not open the database'));
    }
    return FutureBuilder<List<Word>>(
      future: gettingWords(),
      builder: (context, AsyncSnapshot<List<Word>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('error querying the database ${snapshot.error}');
          return const Center(child: Text('could not query the database wrong'));
        } else {
          // this will make all the pages below as RTL
          return Directionality(textDirection: TextDirection.rtl, child: SurahsList(words: snapshot.data!));
        }
      },
    );
  }
}

class SurahsList extends StatefulWidget {
  final List<Word> words;
  const SurahsList({Key? key, required this.words}) : super(key: key);

  @override
  State<SurahsList> createState() => _SurahsListState();
}

class _SurahsListState extends State<SurahsList> {
  // This will return a map where each key correspends to the page number
  // and the value is a list of words in that page
  // so the results would be something like this:
  /*
    {
      "Page1": {
        [word1, word2, word3],
      },
       "Page163": {
        [word1, word2],
      },
       "Page503": {
        [word1, word2, word3, word4],
      }
    }
   */
  Map<SurahPage, List<Word>> groupPages(List<Word> words) {
    final pages = <SurahPage, List<Word>>{};
    pages.addAll(
      groupBy<Word, SurahPage>(
        words,
            (word) => SurahPage(
          pageNum: word.pageNum,
          surahName: word.surahName,
          title: word.title,
        ),
      ),
    );
    return pages;
  }

  late final pages = groupPages(widget.words);

  @override
  Widget build(BuildContext context) {
    final pageNumbers = pages.keys.toList();
    return ListView.builder(
      itemCount: pageNumbers.length,
      itemBuilder: (context, index) {
        final surahPage = pageNumbers[index];
        final words = pages[surahPage]!;
        return ListTile(
          title: Text('سورة ' + surahPage.surahName!),
          subtitle: Text('صفحة رقم: ${surahPage.pageNum}, عدد الكلمات: ${words.length}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ImagePage(
                    surahPage: surahPage,
                    words: words,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class ImagePage extends StatelessWidget {
  final SurahPage surahPage;
  final List<Word> words;

  const ImagePage({Key? key, required this.words, required this.surahPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ImageWidget(
        words: words,
        surahPage: surahPage,
      ),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final SurahPage surahPage;
  final List<Word> words;

  const ImageWidget({Key? key, required this.words, required this.surahPage}) : super(key: key);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isReady = false;
  bool imageLoadingError = false;
  late final String assetName = getAssetPath(widget.surahPage.pageNum!);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  List<Widget> getHighlightWidgets() {
    final highlightWidgets = <Widget>[];
    for (var word in widget.words) {
      final x = word.x;
      final y = word.y;
      final w = word.w;
      final h = word.h;
      highlightWidgets.add(
        Positioned(
          top: y,
          left: x,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.4),
                // borderRadius: BorderRadius.circular(20.0),
              ),
              height: h,
              width: w,
            ),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return DialogWidget(selectedWord: word);
                },
              );
            },
          ),
        ),
      );
    }
    return highlightWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        height: assetImageSize.height,
        width: assetImageSize.width,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image(
              height: assetImageSize.height,
              width: assetImageSize.width,
              image: AssetImage(assetName),
            ),
            ...getHighlightWidgets()
          ],
        ),
      ),
    );
  }
}

class DialogWidget extends StatelessWidget {
  final Word selectedWord;
  const DialogWidget({
    Key? key,
    required this.selectedWord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        content: Builder(builder: (context) {
          return SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(selectedWord.title!),
                const Divider(),
                Text(selectedWord.details!, maxLines: null, overflow: TextOverflow.visible),
              ],
            ),
          );
        }),
      ),
    );
  }
}
