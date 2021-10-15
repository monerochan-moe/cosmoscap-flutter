import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cosmoscap/calendar_events.dart';

import 'package:cosmoscap/coin_model.dart';
import 'package:cosmoscap/cosmos_respository.dart';
import 'package:cosmoscap/failure_model.dart';
import 'package:cosmoscap/item_model.dart';
import 'package:cosmoscap/services.dart';
import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  //await dotenv.load(fileName: '.env');

  setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmos Cap',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Item>> _futureItems;
  int endTime;
  double max = 0;
  double totalcrypto = 0;
  double btcprice = 0;
  double ethprice = 0;
  //final oCcy = new NumberFormat.simpleCurrency(locale: "en_US", decimalDigits: 0);

  bool _loading;
  List<CoinModel> coinInfo = [];
  Future<void> getCoinInformation() async {
    max = 0;
    InfoService coinAPI = InfoService();
    await coinAPI.getFutures().then((value) => {coinInfo = coinAPI.coinInfo, coinInfo.sort((a, b) => b.marketcap.compareTo(a.marketcap))});

    setState(() {
      _loading = false;
    });
    if (coinInfo != null && coinInfo.isNotEmpty) {
      coinInfo.forEach((e) {
        max = max + e.price['market_cap']['usd'];
      });
    }
    final response = await http.get('https://api.coingecko.com/api/v3/global');
    final btcresponse = await http.get("https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd");
    var btcJson = json.decode(btcresponse.body);
    //final ethereumresponse = await http.get("https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd");
    //var ethJson = json.decode(ethereumresponse.body);s
    //print(response.body);
    var jsonData = json.decode(response.body);
    setState(() {
      btcprice = btcJson['bitcoin']['usd'];
      // ethprice = ethJson['ethereum']['usd'];
      totalcrypto = jsonData['data']["total_market_cap"]['usd'];
    });
  }

  @override
  void initState() {
    super.initState();
    getCoinInformation();
    _loading = true;
    _futureItems = CosmosRepository().getItems();
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    formatNumber(dynamic myNumber) {
      // Convert number into a string if it was not a string previously
      String stringNumber = myNumber.toString();

      // Convert number into double to be formatted.
      // Default to zero if unable to do so
      double doubleNumber = double.tryParse(stringNumber) ?? 0;

      // Set number format to use
      NumberFormat numberFormat = new NumberFormat.compact();

      return numberFormat.format(doubleNumber);
    }

    bool sort = false;
    Size size = MediaQuery.of(context).size;

    onSortColum(int columnIndex, bool ascending) {
      if (columnIndex == 0) {
        if (ascending) {
          coinInfo.sort((b, a) => b.marketcap.compareTo(a.marketcap));
        } else {
          coinInfo.sort((b, a) => b.marketcap.compareTo(a.marketcap));
        }
      }

      if (columnIndex == 1) {
        if (ascending) {
          coinInfo.sort((a, b) => a.name.compareTo(b.name));
        } else {
          coinInfo.sort((a, b) => b.name.compareTo(a.name));
        }
      }
      if (columnIndex == 2) {
        if (ascending) {
          coinInfo.sort((a, b) => b.price['current_price']["usd"].compareTo(a.price['current_price']["usd"]));
        } else {
          coinInfo.sort((a, b) => a.price['current_price']["usd"].compareTo(b.price['current_price']["usd"]));
        }
      }
      if (columnIndex == 3) {
        if (ascending) {
          coinInfo.sort((a, b) => b.price['market_cap']['usd'].compareTo(a.price['market_cap']['usd']));
        } else {
          coinInfo.sort((a, b) => b.price['market_cap']['usd'].compareTo(a.price['market_cap']['usd']));
        }
      }
      if (columnIndex == 4) {
        if (ascending) {
          coinInfo.sort((a, b) => b.price['price_change_percentage_24h'].compareTo(a.price['price_change_percentage_24h']));
        } else {
          coinInfo.sort((a, b) => a.price['price_change_percentage_24h'].compareTo(b.price['price_change_percentage_24h']));
        }
      }
      if (columnIndex == 5) {
        if (ascending) {
          coinInfo.sort((a, b) => b.price['price_change_percentage_7d'].compareTo(a.price['price_change_percentage_7d']));
        } else {
          coinInfo.sort((a, b) => a.price['price_change_percentage_7d'].compareTo(b.price['price_change_percentage_7d']));
        }
      }
      if (columnIndex == 6) {
        if (ascending) {
          coinInfo.sort((a, b) => b.price['price_change_percentage_30d'].compareTo(a.price['price_change_percentage_30d']));
        } else {
          coinInfo.sort((a, b) => a.price['price_change_percentage_30d'].compareTo(b.price['price_change_percentage_30d']));
        }
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
            onRefresh: () async {
              getCoinInformation();
              _futureItems = CosmosRepository().getItems();
              setState(() {
                _loading = true;
              });
            },
            child: Container(
                color: Colors.white,
                height: size.height,
                width: size.width,
                //  set a background image here decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/ido_background.png"), fit: BoxFit.fill)),
                child: FluidLayout(
                    child: Builder(
                        builder: (BuildContext context) => CustomScrollView(slivers: <Widget>[
                              //SliverToBoxAdapter(child: Container()),
                              SliverFluidGrid(fluid: true, spacing: 0, children: [
                                FluidCell.withFluidHeight(
                                  size: context.fluid(12, xs: 12, s: 12, m: 12),
                                  heightSize: null,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                        onTap: () async {
                                                          const url = 'https://twitter.com/cosmos_cap/status/1363494326366535687';
                                                          if (await canLaunch(url)) {
                                                            await launch(url);
                                                          } else {
                                                            throw 'Could not launch $url';
                                                          }
                                                        },
                                                        child: Container()

                                                        /*
                                                        Image.asset(
                                                          "assets/secretSwapIcon.gif",
                                                          width: 150,
                                                        ),
                                                        */
                                                        ),
                                                    Text(
                                                      'cosmos-cap',
                                                      style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                                    ),
                                                    /*
                                                        Text(
                                                          '.com',
                                                          style: GoogleFonts.roboto(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w100,
                                                              color: Colors.white),
                                                        ),
                                                        */
                                                    /*
                                                    Spacer(),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          formatNumber(max),
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        Text(
                                                          "Market Cap",
                                                          style: TextStyle(color: Colors.grey),
                                                        )
                                                      ],
                                                    ),
                                                    Spacer(),
                             
                                                    Column(
                                                      children: [
                                                        Text(
                                                          ((max / totalcrypto) * 100)
                                                                  .toStringAsFixed(2) +
                                                              "%",
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        Text(
                                                          "Dominance",
                                                          style: TextStyle(color: Colors.grey),
                                                        )
                                                      ],]
                                                    
                                                    ),  */
                                                    Spacer(),
                                                    Column(
                                                      children: [
                                                        Wrap(
                                                          direction: Axis.horizontal,
                                                          children: [
                                                            /*
                                                              Container(
                                                                padding: EdgeInsets.all(13),
                                                                child: Text(
                                                                  "BTC " + btcprice.toString()
                                                                  //oCcy.format((btcprice))
                                                                  ,
                                                                  style: GoogleFonts.roboto(
                                                                    fontSize: 13,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                              */
                                                            OutlinedButton(
                                                              style: OutlinedButton.styleFrom(
                                                                side: BorderSide(color: Colors.black, width: 0.5),
                                                              ),
                                                              onPressed: () async {
                                                                const url = 'https://twitter.com/amanuel_yosief';
                                                                if (await canLaunch(url)) {
                                                                  await launch(url);
                                                                } else {
                                                                  throw 'Could not launch $url';
                                                                }
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text(
                                                                  "Contact dev ",
                                                                  style: GoogleFonts.roboto(color: Colors.black, fontSize: 13),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          /*
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                  coinInfo.length.toString() + ' out 200+ projects',
                                                  style: TextStyle(color: Colors.black)),
                                              Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: InkWell(
                                                    onTap: () =>
                                                        launch('https://cosmos.network/ecosystem'),
                                                    child: Icon(
                                                      Icons.launch_rounded,
                                                      size: 20,
                                                      color: Colors.grey,
                                                    )),
                                              )
                                            ],
                                          ),

                                          */
                                        ],
                                      )),
                                ),
                                FluidCell.withFluidHeight(
                                    size: context.fluid(12, xs: 12, s: 12, m: 12),
                                    heightSize: null,
                                    child: Padding(
                                        padding: const EdgeInsets.only(top: 20.0),
                                        child: Container(
                                            //      shadowColor: Colors.grey,
                                            //      elevation: 3,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          AutoSizeText(
                                                            formatNumber(max),
                                                            style: TextStyle(fontSize: 40.0),
                                                            maxLines: 2,
                                                          ),
                                                          Text(
                                                            "Market Cap",
                                                            style: TextStyle(color: Colors.grey),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    AutoSizeText(
                                                      ((max / totalcrypto) * 100).toStringAsFixed(2) + "%",
                                                      style: TextStyle(fontSize: 40.0),
                                                      maxLines: 2,
                                                    ),
                                                    Text(
                                                      "Dominance",
                                                      style: TextStyle(color: Colors.grey),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    AutoSizeText(
                                                      coinInfo.length.toString(),
                                                      style: TextStyle(fontSize: 40.0),
                                                      maxLines: 2,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "out 200+ projects",
                                                          style: TextStyle(color: Colors.grey),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(5.0),
                                                          child: InkWell(
                                                              onTap: () => launch('https://cosmos.network/ecosystem'),
                                                              child: Icon(
                                                                Icons.launch_rounded,
                                                                size: 15,
                                                                color: Colors.grey,
                                                              )),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
/*
                                                        
                                                        Column(children: [
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(35),
                                                            child: Container(
                                                              color: Colors.white,
                                                              padding: const EdgeInsets.all(4.0),
                                                              child: Text(
                                                                formatNumber(max),
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: 35,
                                                                    fontWeight: FontWeight.w500),
                                                              ),
                                                            ),
                                                          ),
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(35),
                                                            child: Container(
                                                              color: Colors.white,
                                                              padding: const EdgeInsets.all(4.0),
                                                              child: Text(
                                                                ((max / totalcrypto) * 100)
                                                                        .toStringAsFixed(2) +
                                                                    "%",
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: 35,
                                                                    fontWeight: FontWeight.w500),
                                                              ),
                                                            ),
                                                          ),
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(35),
                                                            child: Container(
                                                              color: Colors.white,
                                                              padding: const EdgeInsets.all(4.0),
                                                              child: Text(
                                                                ((max / totalcrypto) * 100)
                                                                        .toStringAsFixed(2) +
                                                                    "%",
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: 35,
                                                                    fontWeight: FontWeight.w500),
                                                              ),
                                                            ),
                                                          )
                                                        ])
*/
                                              ])
                                            ])))),

                                /*
                                    FluidCell.withFluidHeight(
                                        size: context.fluid(12, xs: 12, s: 12, m: 12),
                                        heightSize: null,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Wrap(
                                                  direction: Axis.horizontal,
                                                  spacing: 10,
                                                  alignment: WrapAlignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey.withOpacity(0.1),
                                                            spreadRadius: 2,
                                                            blurRadius: 7,
                                                            offset: Offset(0, 3),
                                                          ),
                                                        ],
                                                      ), // Add This
                                                      child: MaterialButton(
                                                        minWidth: 200, // set minWidth to maxFinite
                                                        // double.minPositive
                                                        onPressed: () {},
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Icon(
                                                              Icons.calendar_view_day_rounded,
                                                              size: 20,
                                                              color: Colors.black,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.all(20.0),
                                                              child: Text(
                                                                "Events",
                                                                style: TextStyle(color: Colors.black),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey.withOpacity(0.1),
                                                            spreadRadius: 2,
                                                            blurRadius: 7,
                                                            offset: Offset(0, 3),
                                                          ),
                                                        ],
                                                      ), // Add This
                                                      child: MaterialButton(
                                                        minWidth: 200, // set minWidth to maxFinite
                                                        // double.minPositive
                                                        onPressed: () {},
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Icon(
                                                              Icons.work_outline_rounded,
                                                              size: 20,
                                                              color: Colors.black,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.all(20.0),
                                                              child: Text(
                                                                "Jobs",
                                                                style: TextStyle(color: Colors.black),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Material(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
//Color.fromRGBO(20, 25, 34, 0.95)
                                                      color: Colors.white,
                                                      clipBehavior: Clip.antiAlias, // Add This
                                                      child: MaterialButton(
                                                        minWidth: 200, // set minWidth to maxFinite
                                                        // double.minPositive
                                                        onPressed: () {},
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(20.0),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.black,
                                                                  borderRadius: BorderRadius.circular(60),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.grey.withOpacity(0),
                                                                      spreadRadius: 5,
                                                                      blurRadius: 7,
                                                                      offset: Offset(0, 3), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Icon(
                                                                  Icons.calendar_view_day_rounded,
                                                                  size: 20,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                              Text(
                                                                "Events",
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ))),
                                            */
                                if (context.breakpoint.isSmallerThanL)
                                  FluidCell.withFluidHeight(
                                    size: context.fluid(12),
                                    heightSize: null,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.1),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ), // Add This
                                          child: MaterialButton(
                                            minWidth: 200, // set minWidth to maxFinite
                                            // double.minPositive
                                            onPressed: () {
                                              showModalBottomSheet(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                                  ),
                                                  isScrollControlled: true,
                                                  isDismissible: true,
                                                  backgroundColor: Colors.transparent,
                                                  context: context,
                                                  builder: (context) => CalendarEvents());
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.calendar_view_day_rounded,
                                                  size: 20,
                                                  color: Colors.black,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Text(
                                                    "Events",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: false,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromRGBO(7, 200, 248, 1),
                                                      Color.fromRGBO(134, 53, 213, 1),
                                                      Color.fromRGBO(85, 53, 214, 1),
                                                      Color.fromRGBO(7, 200, 248, 1),
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                ),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                  ),
                                                  onPressed: () async {
                                                    var url = 'https://app.osmosis.zone/';
                                                    if (await canLaunch(url)) {
                                                      await launch(url);
                                                    } else {
                                                      throw 'Could not launch $url';
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20.0),
                                                    child: Text(
                                                      "Osmosis Dex is Live",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (context.breakpoint.isLargerThanS)
                                  FluidCell.withFluidHeight(
                                      size: context.fluid(9, m: 12),
                                      heightSize: null,
                                      child: _loading
                                          ? SizedBox(
                                              height: 500,
                                              width: 500,
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                                                      ),
                                                      TextButton(onPressed: () {}, child: Text("5 seconds or click here to refresh", style: TextStyle(color: Colors.black)))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(minWidth: 700),
                                                        child: DataTable(
                                                          showCheckboxColumn: true,
                                                          columnSpacing: 0,
                                                          horizontalMargin: 0,
                                                          sortAscending: sort,
                                                          dataRowHeight: 50,
                                                          headingRowHeight: 40,
                                                          dividerThickness: 0,
                                                          columns: [
                                                            DataColumn(
                                                                label: Flexible(
                                                                  child: Text(
                                                                    "",
                                                                    style: TextStyle(
                                                                      color: Colors.grey,
                                                                      fontSize: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                                numeric: false,
                                                                onSort: (columnIndex, ascending) {
                                                                  setState(() {
                                                                    sort = !sort;
                                                                  });
                                                                  onSortColum(columnIndex, ascending);
                                                                }),
                                                            DataColumn(
                                                                label: Flexible(
                                                                  child: Text(
                                                                    "Token",
                                                                    style: TextStyle(
                                                                      color: Colors.grey,
                                                                      fontSize: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                                numeric: false,
                                                                onSort: (columnIndex, ascending) {
                                                                  setState(() {
                                                                    sort = !sort;
                                                                  });
                                                                  onSortColum(columnIndex, ascending);
                                                                }),
                                                            DataColumn(
                                                                label: Flexible(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        "Price",
                                                                        style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                numeric: true,
                                                                onSort: (columnIndex, ascending) {
                                                                  setState(() {
                                                                    sort = !sort;
                                                                  });
                                                                  onSortColum(columnIndex, ascending);
                                                                }),
                                                            DataColumn(
                                                                label: Flexible(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        "Marketcap",
                                                                        style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                numeric: true,
                                                                onSort: (columnIndex, ascending) {
                                                                  setState(() {
                                                                    sort = !sort;
                                                                  });
                                                                  onSortColum(columnIndex, ascending);
                                                                }),
                                                            DataColumn(
                                                                label: Flexible(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        "24hr",
                                                                        style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                numeric: true,
                                                                onSort: (columnIndex, ascending) {
                                                                  setState(() {
                                                                    sort = !sort;
                                                                  });
                                                                  onSortColum(columnIndex, ascending);
                                                                }),
                                                            DataColumn(
                                                                label: Flexible(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        "7 Day",
                                                                        style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                numeric: true,
                                                                onSort: (columnIndex, ascending) {
                                                                  setState(() {
                                                                    sort = !sort;
                                                                  });
                                                                  onSortColum(columnIndex, ascending);
                                                                }),
                                                            DataColumn(
                                                                label: Flexible(
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        "30 day",
                                                                        style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                numeric: true,
                                                                onSort: (columnIndex, ascending) {
                                                                  setState(() {
                                                                    sort = !sort;
                                                                  });
                                                                  onSortColum(columnIndex, ascending);
                                                                }),
                                                          ],
                                                          rows: coinInfo
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                                var token = entry.value;

                                                                return DataRow(
                                                                    color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                                                      // All rows will have the same selected color.

                                                                      if (states.contains(MaterialState.hovered)) return Colors.black;
                                                                      // Even rows will have a grey color.
                                                                      //return Colors.white.withOpacity(0.05);
                                                                      //Color.fromRGBO(246, 248, 250, 1); //make tha magic!
                                                                      return Colors.white;
                                                                    }),
                                                                    cells: [
                                                                      DataCell(
                                                                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                          MaterialButton(
                                                                            onPressed: () async {
                                                                              var url = 'https://www.coingecko.com/en/coins/${token.id}';
                                                                              if (await canLaunch(url)) {
                                                                                await launch(url);
                                                                              } else {
                                                                                throw 'Could not launch $url';
                                                                              }
                                                                            },
                                                                            child: CircleAvatar(
                                                                              maxRadius: 25,
                                                                              backgroundColor: Colors.white,
                                                                              child: CircleAvatar(maxRadius: 19, backgroundColor: Colors.white, child: Image.network(token.image.toString())),
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                      ),
                                                                      DataCell(Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          MaterialButton(
                                                                            onPressed: () async {
                                                                              var url = 'https://www.coingecko.com/en/coins/${token.id}';
                                                                              if (await canLaunch(url)) {
                                                                                await launch(url);
                                                                              } else {
                                                                                throw 'Could not launch $url';
                                                                              }
                                                                            },
                                                                            child: Row(
                                                                              children: [
                                                                                Text(
                                                                                  token.name,
                                                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                                                                  textAlign: TextAlign.left,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),

                                                                          /*
                                                                        Text(
                                                                          token.symbol.toUpperCase(),
                                                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.grey),
                                                                          textAlign: TextAlign.start,
                                                                        ),
                                                                        */
                                                                        ],
                                                                      )),
                                                                      DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                        Spacer(),
                                                                        if (double.parse(token.price['price_change_percentage_24h'].toString()).isNegative)
                                                                          Icon(
                                                                            Icons.trending_down,
                                                                            color: Colors.red,
                                                                          )
                                                                        else
                                                                          Icon(
                                                                            Icons.trending_up_rounded,
                                                                            color: Colors.green,
                                                                          ),
                                                                        Spacer(),
                                                                        Container(
                                                                          padding: const EdgeInsets.all(10.0),
                                                                          //decoration: BoxDecoration(shape: BoxShape.rectangle, color: double.parse(token.price['price_change_percentage_24h'].toString()).isNegative ? Color.fromRGBO(255, 233, 239, 1) : Color.fromRGBO(217, 249, 239, 1), borderRadius: BorderRadius.circular(20)),

                                                                          child: Text(
                                                                            "\$" + (token.price['current_price']["usd"].toStringAsFixed(2)),
                                                                            style: TextStyle(
                                                                              fontSize: 15,
                                                                              //fontWeight: FontWeight.bold,
                                                                              //color: double.parse(token.price['price_change_percentage_24h'].toString()).isNegative ? Color.fromRGBO(254, 0, 85, 1) : Color.fromRGBO(0, 180, 116, 1),
                                                                            ),
                                                                            textAlign: TextAlign.end,
                                                                          ),
                                                                        ),
                                                                      ])),
                                                                      DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                        Text(
                                                                          formatNumber((token.marketcap)),
                                                                          style: TextStyle(fontSize: 15),
                                                                          textAlign: TextAlign.end,
                                                                        ),
                                                                      ])),
                                                                      DataCell(Row(
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                        children: [
                                                                          Text(
                                                                            token.price['price_change_percentage_24h'].toStringAsFixed(2) + "%",
                                                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w100, color: Colors.grey),
                                                                            textAlign: TextAlign.end,
                                                                          ),
                                                                        ],
                                                                      )),
                                                                      DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                        Text(
                                                                          token.price['price_change_percentage_7d'].toStringAsFixed(2) + "%",
                                                                          style: TextStyle(fontSize: 15),
                                                                          textAlign: TextAlign.end,
                                                                        ),
                                                                      ])),
                                                                      DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                        Text(
                                                                          token.price['price_change_percentage_30d'].toStringAsFixed(2) + "%",
                                                                          style: TextStyle(fontSize: 15),
                                                                          textAlign: TextAlign.end,
                                                                        ),
                                                                      ])),
                                                                    ]);
                                                              })
                                                              .toSet()
                                                              .toList(),
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            )),
                                if (context.breakpoint.isLargerThanM)
                                  FluidCell.fit(
                                    size: context.fluid(3),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          height: 35,
                                        ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 10, bottom: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.1),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                ),
                                                onPressed: () async {
                                                  var url = 'https://app.emeris.com/';
                                                  if (await canLaunch(url)) {
                                                    await launch(url);
                                                  } else {
                                                    throw 'Could not launch $url';
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Text(
                                                    "Gravity Dex",
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 10, bottom: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                /*
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color.fromRGBO(7, 200, 248, 1),
                                                    Color.fromRGBO(134, 53, 213, 1),
                                                    Color.fromRGBO(85, 53, 214, 1),
                                                    Color.fromRGBO(7, 200, 248, 1),
                                                  ],
                                                 
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  
                                                ),
                                                 */
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.1),
                                                    spreadRadius: 2,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                ),
                                                onPressed: () async {
                                                  var url = 'https://app.osmosis.zone/';
                                                  if (await canLaunch(url)) {
                                                    await launch(url);
                                                  } else {
                                                    throw 'Could not launch $url';
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Text(
                                                    "Osmosis Dex",
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        /*
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 7,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ), // Add This
                                                child: MaterialButton(
                                                  minWidth: 200, // set minWidth to maxFinite
                                                  // double.minPositive
                                                  elevation: 1,
                                                  onPressed: () {},
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20.0),
                                                    child: Text(
                                                      "Osmosis is LIVE",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            */
                                      ],
                                    ),
                                  ),

                                /*
                                        
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxHeight: 200, minHeight: 200),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(25),
                                            child: RefreshIndicator(
                                              onRefresh: () async {
                                                _futureItems = CosmosRepository().getItems();
                                                setState(() {});
                                              },
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                physics: ScrollPhysics(),
                                                child: FutureBuilder<List<Item>>(
                                                  future: _futureItems,
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      // Show pie chart and list view of items.
                                                      final items = snapshot.data;
                                                      return Center(
                                                        child: ListView.builder(
                                                            physics: NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount: items.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              final item = items[index];
                                                              return Container(
                                                                color: Colors.black,
                                                                margin: const EdgeInsets.all(8.0),
                                                                /*
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                    boxShadow: const [],
                                                                   
                                                                  ),
                                                                   */
                                                                child: InkWell(
                                                                  onTap: () async {
                                                                    var url = '${item.link}';
                                                                    if (item.link != "?") if (await canLaunch(url)) {
                                                                      await launch(url);
                                                                    } else {
                                                                      throw 'Could not launch $url';
                                                                    }
                                                                  },
                                                                  child: ListTile(
                                                                    title: Row(
                                                                      children: [
                                                                        Flexible(
                                                                          child: Text(
                                                                            item.name,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: TextStyle(color: Colors.white, fontSize: 15),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    /*
                          subtitle: Row(
                            children: [
                              Text(
                                //${item.category} •
                                '${DateFormat.yMMMd().format(item.date)}',
                              ),
                              IconButton(
                                  onPressed: () async {
                                    var url = '${item.link}';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  icon: Icon(
                                    Icons.launch,
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
                          */
                                                                    trailing: Column(
                                                                      children: [
                                                                        Text(
                                                                            //'-\$${item.price.toStringAsFixed(2)}'
                                                                            ''),
                                                                        CountdownTimer(
                                                                          endTime: item.date.millisecondsSinceEpoch,
                                                                          widgetBuilder: (_, CurrentRemainingTime time) {
                                                                            if (time == null) {
                                                                              return Text(
                                                                                '0d : 0h : 0m',
                                                                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                                                              );
                                                                            } else if (time.days == null)
                                                                              return Text(
                                                                                '${time.hours}h : ${time.min}m',
                                                                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                                                              );
                                                                            else if (time.hours == null)
                                                                              return Text(
                                                                                '${time.min}m',
                                                                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                                                              );
                                                                            else
                                                                              return Text(
                                                                                '${time.days}d : ${time.hours}h : ${time.min}m',
                                                                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                                                              );
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      );
                                                    } else if (snapshot.hasError) {
                                                      // Show failure error message.
                                                      final failure = snapshot.error as Failure;
                                                      return Center(child: Text(failure.message));
                                                    }
                                                    // Show a loading spinner.
                                                    return const Center(child: CircularProgressIndicator());
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        */

                                if (context.breakpoint.isLargerThanM)
                                  FluidCell.fit(
                                    size: context.fluid(3),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text("Events"),
                                        Icon(Icons.horizontal_rule),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxHeight: 400, minHeight: 200),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(25),
                                            child: Container(
                                              height: double.infinity,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                              ),
                                              child: RefreshIndicator(
                                                onRefresh: () async {
                                                  _futureItems = CosmosRepository().getItems();
                                                  setState(() {});
                                                },
                                                child: FutureBuilder<List<Item>>(
                                                  future: _futureItems,
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      // Show pie chart and list view of items.
                                                      final items = snapshot.data;
                                                      return Center(
                                                          child: Scrollbar(
                                                        isAlwaysShown: true,
                                                        controller: _scrollController,
                                                        child: ListView.builder(
                                                            controller: _scrollController,
                                                            itemCount: items.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              final item = items[index];
                                                              return Container(
                                                                /*
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(10.0),
                                                                      boxShadow: const [],
                                                                      ),
                                                                     */
                                                                child: Card(
                                                                  elevation: 1.5,
                                                                  child: ListTile(
                                                                    title: Row(
                                                                      children: [
                                                                        Flexible(
                                                                          child: MaterialButton(
                                                                            onPressed: () async {
                                                                              var url = '${item.link}';
                                                                              if (item.link != "?") if (await canLaunch(url)) {
                                                                                await launch(url);
                                                                              } else {
                                                                                throw 'Could not launch $url';
                                                                              }
                                                                            },
                                                                            child: Text(
                                                                              item.name,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: Colors.black, fontSize: 13),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    /*
                          subtitle: Row(
                            children: [
                              Text(
                                //${item.category} •
                                '${DateFormat.yMMMd().format(item.date)}',
                              ),
                              IconButton(
                                  onPressed: () async {
                                    var url = '${item.link}';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  icon: Icon(
                                    Icons.launch,
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
                          */
                                                                    trailing: Column(
                                                                      children: [
                                                                        Text(
                                                                            //'-\$${item.price.toStringAsFixed(2)}'
                                                                            ''),
                                                                        CountdownTimer(
                                                                          endTime: item.date.millisecondsSinceEpoch,
                                                                          widgetBuilder: (_, CurrentRemainingTime time) {
                                                                            if (time == null) {
                                                                              return Text(
                                                                                '0d : 0h',
                                                                                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w300),
                                                                              );
                                                                            } else if (time.days == null)
                                                                              return Text(
                                                                                '${time.hours}h',
                                                                                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w300),
                                                                              );
                                                                            else if (time.hours == null)
                                                                              return Text(
                                                                                '${time.min}m',
                                                                                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w300),
                                                                              );
                                                                            else
                                                                              return Text(
                                                                                '${time.days}d : ${time.hours}h',
                                                                                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w300),
                                                                              );
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      ));
                                                    } else if (snapshot.hasError) {
                                                      // Show failure error message.
                                                      final failure = snapshot.error as Failure;
                                                      return Center(child: Text(failure.message));
                                                    }
                                                    // Show a loading spinner.
                                                    return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.black)));
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (context.breakpoint.isSmallerThanM)
                                  FluidCell.withFluidHeight(
                                      size: context.fluid(12),
                                      heightSize: null,
                                      child: _loading
                                          ? SizedBox(
                                              height: 500,
                                              width: 500,
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                                                      ),
                                                      TextButton(onPressed: () {}, child: Text("5 seconds or click here to refresh", style: TextStyle(color: Colors.black)))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.only(top: 10, bottom: 50),
                                              child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(minWidth: 700),
                                                    child: DataTable(
                                                      showCheckboxColumn: true,
                                                      columnSpacing: 0,
                                                      horizontalMargin: 0,
                                                      sortAscending: sort,
                                                      dataRowHeight: 50,
                                                      headingRowHeight: 40,
                                                      dividerThickness: 0,
                                                      columns: [
                                                        DataColumn(
                                                            label: Flexible(
                                                              child: Text(
                                                                "",
                                                                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                            numeric: false,
                                                            onSort: (columnIndex, ascending) {
                                                              setState(() {
                                                                sort = !sort;
                                                              });
                                                              onSortColum(columnIndex, ascending);
                                                            }),
                                                        DataColumn(
                                                            label: Flexible(
                                                              child: Text(
                                                                "Token",
                                                                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                            numeric: false,
                                                            onSort: (columnIndex, ascending) {
                                                              setState(() {
                                                                sort = !sort;
                                                              });
                                                              onSortColum(columnIndex, ascending);
                                                            }),
                                                        DataColumn(
                                                            label: Flexible(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text(
                                                                    "Price",
                                                                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            numeric: true,
                                                            onSort: (columnIndex, ascending) {
                                                              setState(() {
                                                                sort = !sort;
                                                              });
                                                              onSortColum(columnIndex, ascending);
                                                            }),
                                                        DataColumn(
                                                            label: Flexible(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text("Marketcap", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                                                                ],
                                                              ),
                                                            ),
                                                            numeric: true,
                                                            onSort: (columnIndex, ascending) {
                                                              setState(() {
                                                                sort = !sort;
                                                              });
                                                              onSortColum(columnIndex, ascending);
                                                            }),
                                                        DataColumn(
                                                            label: Flexible(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text("24hr", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                                                                ],
                                                              ),
                                                            ),
                                                            numeric: true,
                                                            onSort: (columnIndex, ascending) {
                                                              setState(() {
                                                                sort = !sort;
                                                              });
                                                              onSortColum(columnIndex, ascending);
                                                            }),
                                                        DataColumn(
                                                            label: Flexible(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text("7 Day", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                                                                ],
                                                              ),
                                                            ),
                                                            numeric: true,
                                                            onSort: (columnIndex, ascending) {
                                                              setState(() {
                                                                sort = !sort;
                                                              });
                                                              onSortColum(columnIndex, ascending);
                                                            }),
                                                        DataColumn(
                                                            label: Flexible(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Text("30 day", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                                                                ],
                                                              ),
                                                            ),
                                                            numeric: true,
                                                            onSort: (columnIndex, ascending) {
                                                              setState(() {
                                                                sort = !sort;
                                                              });
                                                              onSortColum(columnIndex, ascending);
                                                            }),
                                                      ],
                                                      rows: coinInfo
                                                          .asMap()
                                                          .entries
                                                          .map((entry) {
                                                            var token = entry.value;

                                                            return DataRow(
                                                                color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                                                  // All rows will have the same selected color.
                                                                  if (states.contains(MaterialState.hovered)) return Colors.black.withOpacity(0.05);
                                                                  // Even rows will have a grey color.
                                                                  return Colors.white.withOpacity(0.05);
                                                                }),
                                                                cells: [
                                                                  DataCell(
                                                                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                      MaterialButton(
                                                                        onPressed: () async {
                                                                          var url = 'https://www.coingecko.com/en/coins/${token.id}';
                                                                          if (await canLaunch(url)) {
                                                                            await launch(url);
                                                                          } else {
                                                                            throw 'Could not launch $url';
                                                                          }
                                                                        },
                                                                        child: CircleAvatar(
                                                                          maxRadius: 20,
                                                                          backgroundColor: Colors.white,
                                                                          child: CircleAvatar(maxRadius: 19, backgroundColor: Colors.white, child: Image.network(token.image.toString())),
                                                                        ),
                                                                      ),
                                                                    ]),
                                                                  ),
                                                                  DataCell(Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      MaterialButton(
                                                                        onPressed: () async {
                                                                          var url = 'https://www.coingecko.com/en/coins/${token.id}';
                                                                          if (await canLaunch(url)) {
                                                                            await launch(url);
                                                                          } else {
                                                                            throw 'Could not launch $url';
                                                                          }
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Text(
                                                                              token.name,
                                                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                                                              textAlign: TextAlign.left,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      /*
                                                                          Text(
                                                                            token.symbol
                                                                                .toUpperCase(),
                                                                            style: TextStyle(
                                                                                fontSize: 13,
                                                                                fontWeight:
                                                                                    FontWeight.w300,
                                                                                color: Colors.grey),
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                          ),
                                                                          */
                                                                    ],
                                                                  )),
                                                                  DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                    Spacer(),
                                                                    if (double.parse(token.price['price_change_percentage_24h'].toString()).isNegative)
                                                                      Icon(
                                                                        Icons.trending_down,
                                                                        color: Colors.red,
                                                                      )
                                                                    else
                                                                      Icon(
                                                                        Icons.trending_up_rounded,
                                                                        color: Colors.green,
                                                                      ),
                                                                    Spacer(),
                                                                    Text(
                                                                      "\$" + (token.price['current_price']["usd"].toStringAsFixed(2)),
                                                                      style: TextStyle(fontSize: 15),
                                                                      textAlign: TextAlign.end,
                                                                    ),
                                                                  ])),
                                                                  DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                    Text(
                                                                      formatNumber((token.marketcap)),
                                                                      style: TextStyle(fontSize: 15),
                                                                      textAlign: TextAlign.end,
                                                                    ),
                                                                  ])),
                                                                  DataCell(Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        token.price['price_change_percentage_24h'].toStringAsFixed(2) + "%",
                                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w100, color: Colors.grey),
                                                                        textAlign: TextAlign.end,
                                                                      ),
                                                                    ],
                                                                  )),
                                                                  DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                    Text(
                                                                      token.price['price_change_percentage_7d'].toStringAsFixed(2) + "%",
                                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w100, color: Colors.grey),
                                                                      textAlign: TextAlign.end,
                                                                    ),
                                                                  ])),
                                                                  DataCell(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                                    Text(
                                                                      token.price['price_change_percentage_30d'].toStringAsFixed(2) + "%",
                                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w100, color: Colors.grey),
                                                                      textAlign: TextAlign.end,
                                                                    ),
                                                                  ])),
                                                                ]);
                                                          })
                                                          .toSet()
                                                          .toList(),
                                                    ),
                                                  )),
                                            )),
                              ])
                            ]))))));
  }
}
