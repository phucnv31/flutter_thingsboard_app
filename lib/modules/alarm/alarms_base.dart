import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/core/entity/entities_base.dart';
import 'package:thingsboard_app/utils/utils.dart';
import 'package:thingsboard_client/thingsboard_client.dart';


const Map<AlarmSeverity, Color> alarmSeverityColors = {
  AlarmSeverity.CRITICAL: Color(0xFFFF0000),
  AlarmSeverity.MAJOR: Color(0xFFFFA500),
  AlarmSeverity.MINOR: Color(0xFFFFCA3D),
  AlarmSeverity.WARNING: Color(0xFFABAB00),
  AlarmSeverity.INDETERMINATE: Color(0xFF00FF00),
};

Map<AlarmSeverity, String> alarmSeverityTranslations = {
  AlarmSeverity.CRITICAL: 'alarms_CRITICAL',
  AlarmSeverity.MAJOR: 'alarms_MAJOR',
  AlarmSeverity.MINOR: 'alarms_MINOR',
  AlarmSeverity.WARNING: 'alarms_WARNING',
  AlarmSeverity.INDETERMINATE: 'alarms_INDETERMINATE',
};

Map<AlarmStatus, String> alarmStatusTranslations = {
  AlarmStatus.ACTIVE_ACK: 'AlarmStatus.ACTIVE_ACK',
  AlarmStatus.ACTIVE_UNACK: 'AlarmStatus.ACTIVE_UNACK',
  AlarmStatus.CLEARED_ACK: 'AlarmStatus.CLEARED_ACK',
  AlarmStatus.CLEARED_UNACK: 'AlarmStatus.CLEARED_UNACK',
};

mixin AlarmsBase on EntitiesBase<AlarmInfo, AlarmQuery> {

  @override
  String get title => 'alarms'.tr().toString();

  @override
  String get noItemsFoundText => 'no_alarms_found'.tr().toString();

  @override
  Future<PageData<AlarmInfo>> fetchEntities(AlarmQuery query) {
    return tbClient.getAlarmService().getAllAlarms(query);
  }

  @override
  void onEntityTap(AlarmInfo alarm) {
    String? dashboardId = alarm.details?['dashboardId'];
    if (dashboardId != null) {
      var state = Utils.createDashboardEntityState(alarm.originator, entityName: alarm.originatorName);
      navigateToDashboard(dashboardId, dashboardTitle: alarm.originatorName, state: state);
    } else {
      if (tbClient.isTenantAdmin()) {
        showWarnNotification('mobile_dashboard_should_config_in_device_profile_alarm_rules'.tr().toString());
      }
    }
  }

  @override
  Widget buildEntityListCard(BuildContext context, AlarmInfo alarm) {
    return _buildEntityListCard(context, alarm);
  }

  Widget _buildEntityListCard(BuildContext context, AlarmInfo alarm) {
    return AlarmCard(tbContext, alarm: alarm);
  }
}

class AlarmQueryController extends PageKeyController<AlarmQuery> {

  AlarmQueryController({int pageSize = 20, String? searchText}) : super(AlarmQuery(TimePageLink(pageSize, 0, searchText, SortOrder('createdTime', Direction.DESC)), fetchOriginator: true));

  @override
  AlarmQuery nextPageKey(AlarmQuery pageKey) {
    return AlarmQuery(pageKey.pageLink.nextPageLink());
  }

  onSearchText(String searchText) {
    var query = value.pageKey;
    query.pageLink.page = 0;
    query.pageLink.textSearch = searchText;
    notifyListeners();
  }

}

class AlarmCard extends TbContextWidget {

  final AlarmInfo alarm;

  AlarmCard(TbContext tbContext, {required this.alarm}) : super(tbContext);

  @override
  _AlarmCardState createState() => _AlarmCardState(alarm);

}

class _AlarmCardState extends TbContextState<AlarmCard> {

  bool loading = false;
  AlarmInfo alarm;

  final entityDateFormat = DateFormat('yyyy-MM-dd');

  _AlarmCardState(this.alarm): super();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(AlarmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.loading = false;
    this.alarm = widget.alarm;
  }

  @override
  Widget build(BuildContext context) {
    if (this.loading) {
      return Container( height: 134, alignment: Alignment.center, child: RefreshProgressIndicator());
    } else {
      bool hasDashboard = alarm.details?['dashboardId'] != null;
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerLeft,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: alarmSeverityColors[alarm.severity]!,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4))
                  ),
                )
            )
          ),
          Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(width: 4),
                Flexible(
                    fit: FlexFit.tight,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 16),
                                Flexible(
                                    fit: FlexFit.tight,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 12),
                                        Row(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                  fit: FlexFit.tight,
                                                  child: AutoSizeText(alarm.type,
                                                      maxLines: 2,
                                                      minFontSize: 8,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Color(0xFF282828),
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 14,
                                                          height: 20 / 14)
                                                  )
                                              ),
                                              Text(entityDateFormat.format(DateTime.fromMillisecondsSinceEpoch(alarm.createdTime!)),
                                                  style: TextStyle(
                                                      color: Color(0xFFAFAFAF),
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 12,
                                                      height: 16 / 12)
                                              )
                                            ]
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                  fit: FlexFit.tight,
                                                  child: Text(alarm.originatorName != null ? alarm.originatorName! : '',
                                                      style: TextStyle(
                                                          color: Color(0xFFAFAFAF),
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 12,
                                                          height: 16 / 12)
                                                  )
                                              ),
                                              Text(alarmSeverityTranslations[alarm.severity]!.tr().toString(),
                                                  style: TextStyle(
                                                      color: alarmSeverityColors[alarm.severity]!,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                      height: 16 / 12)
                                              )
                                            ]
                                        ),
                                        SizedBox(height: 12)],
                                    )
                                ),
                                SizedBox(width: 16),
                                if (hasDashboard) Icon(Icons.chevron_right, color: Color(0xFFACACAC)),
                                if (hasDashboard) SizedBox(width: 16),
                              ]
                          ),
                          Divider(height: 1),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 16),
                              Flexible(
                                  fit: FlexFit.tight,
                                  child: Text(alarmStatusTranslations[alarm.status]!.tr().toString(),
                                      style: TextStyle(
                                          color: Color(0xFF282828),
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          height: 20 / 14)
                                  )
                              ),
                              SizedBox(height: 32),
                              Row(
                                children: [
                                  if ([AlarmStatus.CLEARED_UNACK, AlarmStatus.ACTIVE_UNACK].contains(alarm.status))
                                    CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Color(0xffF0F4F9),
                                        child: IconButton(icon: Icon(Icons.done, size: 18), padding: EdgeInsets.all(7.0), onPressed: () => _ackAlarm(alarm))
                                    ),
                                  if ([AlarmStatus.ACTIVE_UNACK, AlarmStatus.ACTIVE_ACK].contains(alarm.status))
                                    Row(
                                        children: [
                                          SizedBox(width: 4),
                                          CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Color(0xffF0F4F9),
                                              child: IconButton(icon: Icon(Icons.clear, size: 18), padding: EdgeInsets.all(7.0), onPressed: () => _clearAlarm(alarm))
                                          )
                                        ]
                                    )
                                ],
                              ),
                              SizedBox(width: 8)
                            ],
                          ),
                          SizedBox(height: 8)
                        ]
                    )
                )
              ]
          )
        ],
      );
    }
  }

  _clearAlarm(AlarmInfo alarm) async {
    var res = await confirm(title: 'confirm_clear_alarm_title'.tr().toString(), message: 'confirm_clear_alarm_body'.tr().toString(), cancel: 'no'.tr().toString(), ok: 'yes'.tr().toString());
    if (res != null && res) {
      setState(() {
        loading = true;
      });
      await tbClient.getAlarmService().clearAlarm(alarm.id!.id!);
      var newAlarm = await tbClient.getAlarmService().getAlarmInfo(
          alarm.id!.id!);
      setState(() {
        loading = false;
        this.alarm = newAlarm!;
      });
    }
  }

  _ackAlarm(AlarmInfo alarm) async {
    var res = await confirm(title: 'confirm_ack_alarm_title'.tr().toString(), message: 'confirm_ack_alarm_body'.tr().toString(), cancel: 'no'.tr().toString(), ok: 'yes'.tr().toString());
    if (res != null && res) {
      setState(() {
        loading = true;
      });
      await tbClient.getAlarmService().ackAlarm(alarm.id!.id!);
      var newAlarm = await tbClient.getAlarmService().getAlarmInfo(
          alarm.id!.id!);
      setState(() {
        loading = false;
        this.alarm = newAlarm!;
      });
    }
  }

}
