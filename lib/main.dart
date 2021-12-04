import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:highlight/util.dart';
import 'package:highlight/words.dart';
import 'package:sqflite/sqflite.dart';

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
        print('we get the database');
        isDatabaseReady = true;
      });
    } catch (e) {
      databaseOpenError = true;
      print('There is an error $e');
    }
  }

  // final Future<Database> database = getDatabasesPath().then((String path) {
  //   return openDatabase(join(path, 'hafs.db'));
  // });

  Future<List<Word>> gettingWords() async {
    final List<Map<String, dynamic>> maps = await db.query('hafsData');
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
      print('database is not ready');
      return const Center(child: CircularProgressIndicator());
    }

    if (databaseOpenError) {
      return const Center(child: Text('could not open the database'));
    }
    return FutureBuilder<List<Word>>(
      future: gettingWords(),
      builder: (context, AsyncSnapshot<List<Word>> snapshot) {
        if (!snapshot.hasData) {
          print('snapshot has no data');
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

class SurahsList extends StatelessWidget {
  final List<Word> words;
  const SurahsList({Key? key, required this.words}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return ListTile(
          title: Text('سورة ' + word.surahName!),
          subtitle: Text(word.details!),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ImagePage(
                    selectedWord: word,
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
  final Word selectedWord;

  const ImagePage({Key? key, required this.selectedWord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ImageWidget(selectedWord: selectedWord),
    );
  }
}

class ImageWidget extends StatefulWidget {
  final Word selectedWord;

  const ImageWidget({Key? key, required this.selectedWord}) : super(key: key);

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isReady = false;
  bool imageLoadingError = false;
  late final String assetName = getAssetPath(widget.selectedWord);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void loadAssetImage() {}

  @override
  Widget build(BuildContext context) {
    final x = widget.selectedWord.x;
    final y = widget.selectedWord.y;
    final w = widget.selectedWord.w;
    final h = widget.selectedWord.h;
    return FittedBox(
      child: SizedBox(
        height: assetImageSize.height,
        width: assetImageSize.width,
        child: Stack(
          children: [
            Container(
              child: Image(
                height: assetImageSize.height,
                width: assetImageSize.width,
                image: AssetImage(assetName),
              ),
            ),
            Positioned(
              top: y,
              left: x,
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration:
                  BoxDecoration(color: Colors.red.withOpacity(0.4), borderRadius: BorderRadius.circular(20.0)),
                  height: h,
                  width: w,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return DialogWidget(selectedWord: widget.selectedWord);
                    },
                  );
                },
              ),
            ),
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
