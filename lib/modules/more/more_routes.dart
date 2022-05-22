import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/modules/main/main_page.dart';



class MoreRoutes extends TbRoutes {

  late var moreHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return MainPage(tbContext, path: '/more');
  });

  MoreRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define("/more", handler: moreHandler);
  }

}
