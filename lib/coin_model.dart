class CoinModel {
  final String name;
  final String symbol;
  final String id;

  var marketcap;
  var average1Days;
  var average7Days;
  var average30Days;
  var image;
  var price;

  CoinModel(
      {this.name,
      this.symbol,
      this.id,
      this.image,
      this.price,
      this.average1Days,
      this.average7Days,
      this.average30Days,
      this.marketcap});
}
