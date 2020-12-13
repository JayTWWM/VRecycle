import 'dart:ui';

var pageList = [
  PageModel(
      imageUrl: "assets/images/designer_.png",
      title: "COLLECT",
      body: "COLLECT YOUR WASTE",
      titleGradient: [Color(0xFF9708CC), Color(0xFF43CBFF)]),
  PageModel(
      imageUrl: "assets/images/competition.png",
      title: "REQUEST",
      body: "REQUEST THE COLLECTOR",
      titleGradient: [Color(0xFFE2859F), Color(0xFFFCCF31)]),
  PageModel(
      imageUrl: "assets/images/online_store_.png",
      title: "DONE",
      body: "SIT BACK, RELAX",
      titleGradient: [Color(0xFF5EFCE8), Color(0xFF736EFE)]),
];

class PageModel {
  String imageUrl;
  String title;
  String body;
  List<Color> titleGradient = [];
  PageModel({this.imageUrl, this.title, this.body, this.titleGradient});
}
