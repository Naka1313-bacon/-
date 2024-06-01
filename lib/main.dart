import 'package:flutter/material.dart';
import 'package:read_aloud/database_helper.dart';
import 'package:read_aloud/webview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:read_aloud/components/ad_mob.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _selectedAuthor;
  List<Book> _books = [];
  List<Book> _history = [];
  final MyAdManager _adMob = MyAdManager();
  @override
  void initState() {
    super.initState();
    _adMob.load();
    copyDatabaseToDocumentsDir();
    _loadHistory();
  }

  @override
  void dispose() {
    super.dispose();
    _adMob.dispose();
  }

  void _onAuthorChanged(String? newAuthor) {
    if (newAuthor == 'ホーム') {
      setState(() {
        _selectedAuthor = null; // 選択状態をクリア
        _books = []; // リストを空にすることで非表示に
      });
    } else if (newAuthor != null) {
      DatabaseHelper.getBooksByAuthor(newAuthor).then((books) {
        setState(() {
          _selectedAuthor = newAuthor;
          _books = books;
        });
      });
    }
  }

  void _loadHistory() async {
    final loadedHistory = await HistoryHelper.loadHistory();
    setState(() {
      _history = loadedHistory;
    });
  }

  void _addToHistory(Book book) async {
    // 履歴リストにBookオブジェクトを追加
    _history.add(book);
    // 履歴リストをそのままsaveHistoryメソッドに渡して保存
    await HistoryHelper.saveHistory(_history);
    // UIを更新
    setState(() {});
  }

  void _removeFromHistory(int index) async {
    _history.removeAt(index);
    await HistoryHelper.saveHistory(_history);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.greenAccent,
          title: Center(
            child: Text(
              '音    読    破',
              style: GoogleFonts.sawarabiMincho(
                fontSize: 24, // フォントサイズを24に設定
                fontWeight: FontWeight.bold, // フォントウェイトを太字に設定
                color: Colors.white, // 文字色を白に設定
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // 背景になる履歴リスト
            Positioned.fill(
              top: 200,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '履歴',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return Dismissible(
                          key: Key(item.id), // 各カードに一意のキーを割り当てます。
                          onDismissed: (direction) {
                            // アイテムをリストから削除する処理をここに書きます。
                            setState(() {
                              _removeFromHistory(index);
                            });

                            // スナックバーで削除の確認メッセージを表示
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${item.name}を削除しました")),
                            );
                          },
                          background: Container(
                              color: Color.fromARGB(
                                  255, 187, 105, 51)), // スワイプ時の背景色
                          child: Card(
                            color: const Color.fromARGB(255, 247, 234, 168),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(15),
                            child: ListTile(
                              leading: const Icon(Icons.book),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WebViewApp(
                                        id: item.id, name: item.name),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  FutureBuilder(
                    future: AdSize.getAnchoredAdaptiveBannerAdSize(
                        Orientation.portrait,
                        MediaQuery.of(context).size.width.truncate()),
                    builder: (BuildContext context,
                        AsyncSnapshot<AnchoredAdaptiveBannerAdSize?> snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          width: double.infinity,
                          child: _adMob.getAdBanner2(),
                        );
                      } else {
                        return Container(
                          height: _adMob.getAdBannerHeight(),
                          color: Colors.white,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            // タイマーウィジェットの位置調整（例：画面下部）
            // 前面に表示する著者リスト
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  FutureBuilder(
                    future: AdSize.getAnchoredAdaptiveBannerAdSize(
                        Orientation.portrait,
                        MediaQuery.of(context).size.width.truncate()),
                    builder: (BuildContext context,
                        AsyncSnapshot<AnchoredAdaptiveBannerAdSize?> snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          width: double.infinity,
                          child: _adMob.getAdBanner1(),
                        );
                      } else {
                        return Container(
                          height: _adMob.getAdBannerHeight(),
                          color: Colors.white,
                        );
                      }
                    },
                  ),
                  FutureBuilder<List<String>>(
                    future: DatabaseHelper.getAuthors(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('エラーが発生しました: ${snapshot.error}');
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        List<String?> authors = ['ホーム', ...?snapshot.data];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(top: 10),
                          // コンテナの内側にパディングを追加
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: const Color.fromARGB(255, 247, 234, 168),
                                width: 2),
                            borderRadius: BorderRadius.circular(30.0), // 角を丸くする
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true, // ドロップダウンボタンの幅を自動で拡張しない
                              hint: const Center(
                                child: Text(
                                  '著者一覧',
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 247, 234, 168),
                                      fontSize: 18),
                                ),
                              ),
                              value: _selectedAuthor,
                              onChanged: _onAuthorChanged,
                              items: authors.map<DropdownMenuItem<String?>>(
                                  (String? value) {
                                return DropdownMenuItem<String?>(
                                  value: value,
                                  child: Center(
                                    child: Text(
                                      value ?? '不明',
                                    ),
                                  ),
                                );
                              }).toList(),
                              // ドロップダウンメニューのスタイル調整

                              borderRadius: BorderRadius.circular(
                                  15.0), // ドロップダウンメニューの角を丸く
                            ),
                          ),
                        );
                      } else {
                        return const Text('著者のデータがありません。');
                      }
                    },
                  ),
                  SizedBox(
                    height: _books.isNotEmpty ? 800 : 0,
                    child: ListView.builder(
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.white.withOpacity(1),
                          child: ListTile(
                            title: Text(
                              _books[index].name,
                              textAlign: TextAlign.center,
                            ),
                            onTap: () {
                              _addToHistory(_books[index]);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewApp(
                                      id: _books[index].id,
                                      name: _books[index].name),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
// https://doc-hosting.flycricket.io/yin-du-po-privacy-policy/f835c87b-f48d-4656-9e90-726de4b85f79/privacy
// https://doc-hosting.flycricket.io/yin-du-po-terms-of-use/9647ad28-bdfa-4e50-8b51-453e947e7ebd/terms