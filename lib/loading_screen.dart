import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    Key key,
    @required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        height: size.height,
        width: size.width,
        child: FluidLayout(
            child: Builder(
                builder: (BuildContext context) => CustomScrollView(slivers: <Widget>[
                      //SliverToBoxAdapter(child: Container()),
                      SliverFluidGrid(fluid: true, spacing: 0, children: [
                        FluidCell.withFluidHeight(
                            size: context.fluid(12, xs: 12, s: 12, m: 12),
                            heightSize: null,
                            child: Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                        Column(children: [
                                          Wrap(direction: Axis.horizontal, children: [
                                            Card(
                                                color: Colors.grey[100],
                                                child: TextButton(
                                                    onPressed: () async {
                                                      const url = 'https://twitter.com/amanuel_yosief';
                                                      if (await canLaunch(url)) {
                                                        await launch(url);
                                                      } else {
                                                        throw 'Could not launch $url';
                                                      }
                                                    },
                                                    child: Text(
                                                      "Contact dev ",
                                                      style: GoogleFonts.roboto(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold),
                                                    )))
                                          ])
                                        ])
                                      ])
                                    ])))),
                        FluidCell.withFluidHeight(
                            size: context.fluid(12, xs: 12, s: 12, m: 12),
                            heightSize: null,
                            child: Padding(
                                padding: const EdgeInsets.only(top: 100.0),
                                child: Container(
                                    //      shadowColor: Colors.grey,
                                    //      elevation: 3,
                                    decoration: BoxDecoration(
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
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Flexible(
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          AutoSizeText(
                                            "Cosmos Market Capitalization",
                                            style: TextStyle(fontSize: 40.0),
                                            maxLines: 2,
                                          ),
                                          InkWell(
                                              onTap: () => launch('https://cosmos.network/ecosystem'),
                                              hoverColor: Colors.white,
                                              child: RichText(
                                                  text: TextSpan(style: TextStyle(color: Colors.black), text: 'Over 200+ Projects within the Cosmos ecosystem:\n', children: <TextSpan>[
                                                TextSpan(text: 'Explore here', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ])))
                                        ]))
                                      ])
                                    ])))),
                        FluidCell.withFluidHeight(
                            size: context.fluid(12, xs: 12, s: 12, m: 12),
                            heightSize: 10,
                            child: Padding(
                                padding: const EdgeInsets.only(top: 100),
                                child: Column(children: [
                                  /*
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
                                      "assets/secretSwapPromo.png",
                                      width: 600,
                                    ),
                                    */
                                      ),*/
                                  SizedBox(
                                    height: 50,
                                  ),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                  Text(
                                    "Refresh if it takes longer than 10seconds",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ])))
                      ])
                    ]))));
  }
}
