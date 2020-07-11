import 'package:bookie/components/book_card.dart';
import 'package:bookie/components/list_builder.dart';
import 'package:bookie/models/get_books.dart';
import 'package:bookie/screens/book_reader.dart';
import 'package:bookie/screens/download_screen.dart';
// import 'package:epub_kitty/epub_kitty.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:bookie/models/download_helper.dart';
import 'package:bookie/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:progress_indicators/progress_indicators.dart';

class DetailsScreen extends StatefulWidget {
  static String id = 'detailScreen';
  final bookToDisplay;

  DetailsScreen({@required this.bookToDisplay});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var downloadDB = DownloadsDB();
  final imagePlaceHolder =
      'https://lh3.googleusercontent.com/proxy/u8TYJjSEp6IjX6HF2BqR2PmM68Zf6uG-l_DamX5vNfO-euliRz4vfeIJvHlp6CZ1B0EGCW3SXBTEyLjdu2poFM16m0Dr1rMt';
  String imageLink;
  var id;
  var author; //some come as single strings and not list
  String title;
  String publishDate;
  String publisher;
  String description;
  var categories;
  var pageCount;
  String category;
  num rating;
  String downloadLink;
  ScrollController scrollController;
  int descriptonMaxLines = 10;
  bool _dialVisible = true;
  dynamic moreFromAuthorData;
  int listLenght = 0;
  String seeMore = 'View more';
  bool bookIsDownloaded = false;
  var displayBookDatabase;

  void getMoreData() async {
    try {
      var moreAuthor = author;
      moreFromAuthorData = await GetBooks().getAuthorBooks(moreAuthor);
      setState(() {});
      if (moreFromAuthorData['items'] != null) {
        moreFromAuthorData['items'].forEach((book) => listLenght++);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void displayResult(data) {
    var displayInfo = data['volumeInfo'];
    try {
      imageLink = displayInfo['imageLinks']['smallThumbnail'];
    } catch (e) {
      if (imageLink == null) {
        imageLink = imagePlaceHolder;
      }
      print(e);
    }
    id = data['id'];
    author = displayInfo['authors'] ?? 'Unavailable';
    author = author.runtimeType == [].runtimeType ? author[0] : author;
    title = displayInfo['title'] ?? 'Unavailable';
    publishDate = displayInfo['publishedDate'] ?? 'Unavailable';
    publisher = displayInfo['publisher'] ?? 'Unavailable';
    description = displayInfo['description'] ?? 'Unavailable';
    categories = displayInfo['categories'] ?? 'Unavailable';
    pageCount = displayInfo['pageCount'] ?? 'Unavailable';
    rating = displayInfo['averageRating'];
    downloadLink = data['accessInfo']['epub']['downloadLink'];
  }

  void isAlreadyDownloaded() async {
    displayBookDatabase = await downloadDB.check({'id': title});
    print('its already downloaded: ${!displayBookDatabase.isEmpty}');
    if (displayBookDatabase.isNotEmpty) {
      bookIsDownloaded = true;
    } else {
      bookIsDownloaded = false;
    }
    setState(() {});
  }

  String getCategory(var input) {
    String output = '';
    if (input == null) {
      return 'Unavailable';
    } else if (input.runtimeType == String) {
      return input;
    } else {
      input.forEach((element) => output += '| $element');
      return output;
    }
  }

  Widget getRating(num number) {
    if (number == null) {
      return Text(
        'No Rating',
      );
    } else {
      number = number.toInt();
      List<Icon> ratingCount = [];
      for (int i = 0; i < 5; i++) {
        if (i < number) {
          ratingCount.add(Icon(
            Icons.star,
            color: Colors.orange,
          ));
        } else {
          ratingCount.add(Icon(Icons.star_border));
        }
      }
      return Row(
        children: ratingCount,
      );
    }
  }

  void openBook(var path) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BookReader(
                bookPath: path,
              )),
    );
  }

  void setDailVisible(bool value) {
    setState(() {
      _dialVisible = value;
    });
  }

  @override
  void initState() {
    super.initState();

    displayResult(widget.bookToDisplay);
    isAlreadyDownloaded();
    category = getCategory(categories);
    scrollController = ScrollController()
      ..addListener(() {
        setDailVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
    getMoreData();
  }

  @override
  void dispose() {
    super.dispose();
    moreFromAuthorData = null;
    displayBookDatabase = null;
    bookIsDownloaded = false;
  }

  IconData addBook = Icons.library_add;
  IconData like = Icons.favorite_border;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
        ),
        actions: <Widget>[
          Icon(
            Icons.more_horiz,
            size: 30,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 15, right: 10),
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Hero(
                    tag: 'bookImage',
                    child: BookCard(
                      imgHeight: 260,
                      imgWidth: 180,
                      imageLink: imageLink,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: kCursiveHeading,
                        ),
                        SizedBox(height: 5),
                        getRating(rating),
                        SizedBox(height: 5),
                        Text(
                          'By $author\nPublish Date: $publishDate\nPublisher: $publisher\nCategory: $category\nPages: $pageCount',
                          overflow: TextOverflow.fade,
                          style: kSearchResultTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              'About This Book',
              textAlign: TextAlign.center,
              style: kCursiveHeading,
            ),
            SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: descriptonMaxLines,
              softWrap: true,
              overflow: TextOverflow.fade,
              style: TextStyle(fontFamily: 'Source Sans Pro', fontSize: 16),
            ),
            SizedBox(height: 5),
            GestureDetector(
              child: Text(
                seeMore,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: kBlueAccent,
                ),
              ),
              onTap: () {
                setState(() {
                  seeMore == 'View more'
                      ? seeMore = 'View less'
                      : seeMore = 'View more';
                  descriptonMaxLines == 10
                      ? descriptonMaxLines = null
                      : descriptonMaxLines = 10;
                });
              },
            ),
            SizedBox(height: 5),
            Text(
              'More from the author',
              textAlign: TextAlign.start,
              style: kCursiveHeading,
            ),
            SizedBox(height: 5),
            Container(
                height: 180,
                child: moreFromAuthorData == null
                    ? Center(
                        child: GlowingProgressIndicator(
                          child: Icon(Icons.book, color: kBlueAccent, size: 30),
                        ),
                      )
                    : ListBuilder(
                        data: moreFromAuthorData, listLenght: listLenght)),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        visible: _dialVisible,
        overlayOpacity: 0.5,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          bookIsDownloaded
              ? SpeedDialChild(
                  child: Icon(FlutterIcons.book_reader_faw5s),
                  onTap: () async{
                    var path = await displayBookDatabase[0]['path'];
                    print('path is $path');
                    openBook(path);
                    // EpubKitty.setConfig(
                    //     'androidBook', '#06d6a7', 'vertical', true);
                    // EpubKitty.open(path);
                  })
              : SpeedDialChild(
                  backgroundColor:
                      downloadLink == null ? Colors.red : Colors.green,
                  child: Icon(Icons.file_download),
                  onTap: () async {
                    if (downloadLink != null) {
                      bool downloaded = await (showModalBottomSheet(
                        isScrollControlled: false,
                        isDismissible: false,
                        context: context,
                        builder: (context) => DownloadScreen(
                          url: downloadLink,
                          bookInfo: widget.bookToDisplay,
                        ),
                      ));
                      if (downloaded) {
                        print('this is what i got back: $downloaded');
                        setState(() {
                          bookIsDownloaded = true;
                        });
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.green,
                            content: Text('Download successful'),
                            action: SnackBarAction(
                              textColor: Colors.white,
                              label: 'Open',
                              onPressed: () {},
                            ),
                          ),
                        );
                      } else {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.red,
                            content: Text('Could not download'),
                            action: SnackBarAction(
                              textColor: Colors.white,
                              label: 'Try again',
                              onPressed: () {},
                            ),
                          ),
                        );
                      }
                    } else {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Unavailable for download'),
                        ),
                      );
                    }
                  }),
          SpeedDialChild(
            child: Icon(Icons.library_add),
          ),
          SpeedDialChild(
            child: Icon(Icons.favorite),
          ),
        ],
      ),
    );
  }
}
