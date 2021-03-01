import 'dart:ui';

var pageList = [
  PageModel(
      imageUrl: "assets/images/designer_.png",
      title: "COLLECT",
      body: "COLLECT YOUR WASTE",
      titleGradient: [Color(0xFF0EFFE8), Color(0xFF73FF00)]),
  PageModel(
      imageUrl: "assets/images/competition.png",
      title: "REQUEST",
      body: "REQUEST THE COLLECTOR",
      titleGradient: [Color(0xFF2008CC), Color(0xFF43CBFF)]),
  PageModel(
      imageUrl: "assets/images/online_store_.png",
      title: "DONE",
      body: "SIT BACK, RELAX",
      titleGradient: [Color(0xFFE2859F), Color(0xFFFCCF31)]),
];

class PageModel {
  String imageUrl;
  String title;
  String body;
  List<Color> titleGradient = [];
  PageModel({this.imageUrl, this.title, this.body, this.titleGradient});
}
