import 'package:cosmoscap/coin_model.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

//https://api.coingecko.com/api/v3/coins/list
var cosmosFirst = [
  // "bitcoin",
  //"ethereum",
  "kucoin-shares",
  "cosmos",
  "terra-luna",
  "binancecoin",
  "okb",
  "crypto-com-chain",
  "thorchain",
  "band-protocol",
  /*
  "injective-protocol",
  "kava",
  "oasis-network",
  "secret",
R
  "fetch-ai",
  "iris-network",
  "mirror-protocol",
  "bluzelle",
  "hard-protocol",
  "certik",
  "sentinel-group",
  "likecoin",
  "kira-network",
  "starname",
  "akash-network",
  "switcheo",
  "foam-protocol",
  "oraichain-token"
  */
  "aragon"
];

var cosmosSecond = [
  // "bitcoin",
  //"ethereum",
  /*
  "kucoin-shares",
  "cosmos",
  "terra-luna",
  "binancecoin",
  "okb",
  "crypto-com-chain",
  "thorchain",
  "band-protocol",
      */
  "injective-protocol",

  "kava",
  "oasis-network",
  "secret",

  "fetch-ai",
  "iris-network",
  "mirror-protocol",
  "bluzelle",
/*
  "hard-protocol",
  "certik",
  "sentinel-group",
  "likecoin",
  "kira-network",
  "starname",
  "akash-network",
  "switcheo",
  "foam-protocol",
  "oraichain-token"
    */
  "anchor-protocol",
  "sifchain",
  "bitsong"
];

var cosmosThird = [
  // "bitcoin",
  //"ethereum",
  /*
  "kucoin-shares",
  "cosmos",
  "terra-luna",
  "binancecoin",
  "okb",
  "crypto-com-chain",
  "thorchain",
  "band-protocol",
  "injective-protocol",
 
  "kava",
  "oasis-network",
  "secret",

  "fetch-ai",
  "iris-network",
  "mirror-protocol",
  "bluzelle",
       */
  "hard-protocol",

  "certik",
  "sentinel",
  "likecoin",
  "kira-network",
  "starname",
  "akash-network",
  "switcheo",
  "foam-protocol",
  "oraichain-token",
  "e-money",

  ///
  "terrausd",
  "persistence",
  "osmosis",
  "ion",
  "secret-finance"
];

class InfoService {
  List<CoinModel> coinInfo = [];

  Future<void> getFutures() async {
    await Future.wait([
      getCoinInfo(),
      getCoinSecondInfo(),
      getCoinThirdInfo(),
      getCyberInfo(),
      //getEmoneyInfo()
    ]);
  }

  Future<void> getCoinInfo() async {
    try {
      for (var value in cosmosFirst) {
        final response = await http.get('https://api.coingecko.com/api/v3/coins/$value');
        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          CoinModel coin = CoinModel(name: jsonData['name'], symbol: jsonData['symbol'], image: jsonData['image']['small'], price: jsonData['market_data'], marketcap: jsonData['market_data']['market_cap']['usd'], id: value);
          coinInfo.add(coin);
        } else {
          print('Error fetching $value');
        }
        coinInfo.sort((a, b) => a.marketcap.compareTo(b.marketcap));
      }
      coinInfo.sort((a, b) => a.marketcap.compareTo(b.marketcap));
    } catch (e) {}
  }

  Future<void> getCoinSecondInfo() async {
    try {
      for (var value in cosmosSecond) {
        final response = await http.get('https://api.coingecko.com/api/v3/coins/$value');
        var jsonData = json.decode(response.body);
        if (response.statusCode == 200) {
          CoinModel coin = CoinModel(name: jsonData['name'], symbol: jsonData['symbol'], image: jsonData['image']['small'], price: jsonData['market_data'], marketcap: jsonData['market_data']['market_cap']['usd'], id: value);
          coinInfo.add(coin);
        } else {
          print('Error fetching $value');
        }
        coinInfo.sort((a, b) => a.marketcap.compareTo(b.marketcap));
      }
      coinInfo.sort((a, b) => a.marketcap.compareTo(b.marketcap));
    } catch (e) {}
  }

  Future<void> getCoinThirdInfo() async {
    try {
      for (var value in cosmosThird) {
        final response = await http.get('https://api.coingecko.com/api/v3/coins/$value');
        var jsonData = json.decode(response.body);
        if (response.statusCode == 200) {
          CoinModel coin = CoinModel(name: jsonData['name'], symbol: jsonData['symbol'], image: jsonData['image']['small'], price: jsonData['market_data'], marketcap: jsonData['market_data']['market_cap']['usd'], id: value);

          coinInfo.add(coin);
        } else {
          print('Error associated with fetching $value');
        }
        coinInfo.sort((a, b) => a.marketcap.compareTo(b.marketcap));
      }
      coinInfo.sort((a, b) => a.marketcap.compareTo(b.marketcap));
    } catch (e) {}
  }

  Future<void> getCyberInfo() async {
    try {
      final response = await http.get('https://market-data.cybernode.ai/api/coins/cyb');
      var jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        CoinModel coin = CoinModel(
          name: jsonData['name'],
          symbol: jsonData['symbol'],
          image: 'https://cyb.ai/blue-circle.a8fa89beb0.png',
          price: jsonData['market_data'],
          marketcap: jsonData['market_data']['market_cap']['usd'],
        );
        coinInfo.add(coin);
      } else {
        print('Error associated with CyberDev API');
      }
      coinInfo.sort((a, b) => a.marketcap.compareTo(b.marketcap));
    } catch (e) {}
  }
}
