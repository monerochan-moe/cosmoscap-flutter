import 'package:cosmoscap/cosmos_respository.dart';
import 'package:cosmoscap/failure_model.dart';
import 'package:cosmoscap/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarEvents extends StatefulWidget {
  @override
  CalendarEventsState createState() => CalendarEventsState();
}

class CalendarEventsState extends State<CalendarEvents> {
  final ScrollController _scrollController = ScrollController();
  Future<List<Item>> _futureItems;
  int endTime;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureItems = CosmosRepository().getItems();
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300, minHeight: 200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              margin: EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
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
                                  margin: const EdgeInsets.all(8.0),
                                  /*
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  boxShadow: const [],
                                                                 
                                                                ),
                                                                 */
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
                                                '0d : 0h : 0m',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                              );
                                            } else if (time.days == null)
                                              return Text(
                                                '${time.hours}h : ${time.min}m',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                              );
                                            else if (time.hours == null)
                                              return Text(
                                                '${time.min}m',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                              );
                                            else
                                              return Text(
                                                '${time.days}d : ${time.hours}h : ${time.min}m',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                              );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
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
      ]),
    );
  }
}
