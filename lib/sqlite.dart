//
// class HafsWordDB extends StatefulWidget {
//   const HafsWordDB({Key? key}) : super(key: key);
//
//   @override
//   _HafsWordDBState createState() => _HafsWordDBState();
// }
//
// class _HafsWordDBState extends State<HafsWordDB> {
//
//
//   @override
//   void initState() {
//     WidgetsFlutterBinding.ensureInitialized();
//     // Open the database and store the reference.
//   }
//
//   final Future<Database> database = getDatabasesPath().then((String path) {
//     return openDatabase(join(path, 'hafs.db'));
//   });
//
//   Future<List<Word>> gettingWords() async {
//     // Get a reference to the database.
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('hafsData');
//     return List.generate(maps.length, (i) {
//       return Word(
//         pageNum: maps[i]['Page'],
//         verseNum: maps[i]['verse'],
//         word: maps[i]['word'],
//         surahName: maps[i]['Surah'],
//         details: maps[i]['explanation'],
//         title: maps[i]['chapters'],
//         x: maps[i]['x'],
//         y: maps[i]['y'],
//         w: maps[i]['w'],
//         h: maps[i]['h'],
//       );
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future:gettingWords(),
//         builder: (context, AsyncSnapshot snapshot) {
//           if (!snapshot.hasData) {
//             return CircularProgressIndicator();
//           } else {
//             return Column(
//               children: [
//                 for ( var i in snapshot.data)
//                   Text(i.toString())
//               ],
//             );
//           }
//         } );
//           }
// }
//
//
//
