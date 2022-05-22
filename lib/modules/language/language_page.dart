import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/core/entity/entities_base.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';

class LanguagePage extends TbPageWidget {
  final bool searchMode;

  LanguagePage(TbContext tbContext, {this.searchMode = false})
      : super(tbContext);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends TbPageState<LanguagePage> {
  final PageLinkController _pageLinkController = PageLinkController();

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar;
    if (widget.searchMode) {
      appBar = TbAppSearchBar(
        tbContext,
        onSearch: (searchText) => _pageLinkController.onSearchText(searchText),
      );
    } else {
      appBar = TbAppBar(
        tbContext,
        title: Text('language'.tr().toString()),
      );
    }
    return Scaffold(
        appBar: appBar,
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 10),
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      child: InkWell(
                    onTap: () {
                      print('Vietnamese');
                      setState(() {
                        context.setLocale(Locale('vi', 'VN'));
                      });
                      navigateTo('/more');
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('vietnamese'.tr().toString(),
                          style: TextStyle(
                              color: Color(0xFF282828),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14)),
                    ),
                  ))
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 2,
                thickness: 1,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      child: InkWell(
                    onTap: () {
                      print('English');
                      setState(() {
                        context.setLocale(Locale('en', 'US'));
                      });
                      navigateTo('/more');
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('english'.tr().toString(),
                          style: TextStyle(
                              color: Color(0xFF282828),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14)),
                    ),
                  ))
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 2,
                thickness: 1,
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    _pageLinkController.dispose();
    super.dispose();
  }
}
