import 'dart:async';
import 'dart:math';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:native_widgets/native_widgets.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/rockets/core_details.dart';
import '../../../models/rockets/launchpad.dart';
import '../../../models/rockets/spacex_home.dart';
import '../../../util/colors.dart';
import '../../../widgets/list_cell.dart';
import 'dialog_core.dart';
import 'dialog_launchpad.dart';
import 'page_launch.dart';

class SpacexHomeTab extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<Null> _onRefresh(SpacexHomeModel model) {
    Completer<Null> completer = Completer<Null>();
    model.refresh().then((_) => completer.complete());
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<SpacexHomeModel>(
      builder: (context, child, model) => Scaffold(
            key: _scaffoldKey,
            body: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () => _onRefresh(model),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.3,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        FlutterI18n.translate(
                          context,
                          'spacex.home.title',
                        ),
                      ),
                      background: (model.isLoading)
                          ? NativeLoadingIndicator(center: true)
                          : Swiper(
                              itemCount: model.getPhotosCount,
                              itemBuilder: _buildImage,
                              autoplay: true,
                              autoplayDelay: 6000,
                              duration: 750,
                              onTap: (index) => FlutterWebBrowser.openWebPage(
                                    url: model.getPhoto(index),
                                    androidToolbarColor: primaryColor,
                                  ),
                            ),
                    ),
                  ),
                  (model.isLoading)
                      ? SliverFillRemaining(
                          child: NativeLoadingIndicator(center: true),
                        )
                      : SliverToBoxAdapter(child: _buildBody())
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildBody() {
    return ScopedModelDescendant<SpacexHomeModel>(
      builder: (context, child, model) {
        return Column(
          children: <Widget>[
            Container(height: 16.0),
            model.launch.tentativeTime
                ? LaunchCountdown(model)
                : Text(
                    FlutterI18n.translate(
                      context,
                      'spacex.home.tab.no_countdown',
                      {'mission': model.launch.name},
                    ),
                    style: Theme.of(context).textTheme.headline,
                  ),
            Container(height: 16.0),
            const Divider(height: 0.0),
            ListCell(
              leading: const Icon(Icons.public, size: 42.0),
              title: model.vehicle(context),
              subtitle: model.payload(context),
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LaunchPage(model.launch)),
                  ),
            ),
            const Divider(height: 0.0, indent: 74.0),
            ListCell(
              leading: const Icon(Icons.event, size: 42.0),
              title: FlutterI18n.translate(
                context,
                'spacex.home.tab.date.title',
              ),
              subtitle: model.launchDate(context),
              onTap: model.launch.tentativeTime
                  ? () => Add2Calendar.addEvent2Cal(Event(
                        title: model.launch.name,
                        description: model.launch.details,
                        location: model.launch.launchpadName,
                        startDate: model.launch.launchDate,
                        endDate: model.launch.launchDate.add(Duration(
                          minutes: 30,
                        )),
                      ))
                  : null,
            ),
            const Divider(height: 0.0, indent: 74.0),
            ListCell(
              leading: const Icon(Icons.location_on, size: 42.0),
              title: FlutterI18n.translate(
                context,
                'spacex.home.tab.launchpad.title',
              ),
              subtitle: model.launchpad(context),
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScopedModel<LaunchpadModel>(
                            model: LaunchpadModel(
                              model.launch.launchpadId,
                              model.launch.launchpadName,
                            )..loadData(),
                            child: LaunchpadDialog(),
                          ),
                      fullscreenDialog: true,
                    ),
                  ),
            ),
            const Divider(height: 0.0, indent: 74.0),
            ListCell(
              leading: const Icon(Icons.timer, size: 42.0),
              title: FlutterI18n.translate(
                context,
                'spacex.home.tab.static_fire.title',
              ),
              subtitle: model.staticFire(context),
            ),
            const Divider(height: 0.0, indent: 74.0),
            ListCell(
              leading: const Icon(Icons.directions_boat, size: 42.0),
              title: FlutterI18n.translate(
                context,
                'spacex.home.tab.fairings.title',
              ),
              subtitle: model.fairings(context),
            ),
            const Divider(height: 0.0, indent: 74.0),
            ListCell(
              leading: const Icon(Icons.autorenew, size: 42.0),
              title: FlutterI18n.translate(
                context,
                'spacex.home.tab.first_stage.title',
              ),
              subtitle: model.landings(context),
              onTap: (model.launch.rocket.firstStage[0].id == null)
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScopedModel<CoreModel>(
                                model: CoreModel(
                                  model
                                      .launch
                                      .rocket
                                      .firstStage[Random().nextInt(model
                                          .launch.rocket.firstStage.length)]
                                      .id,
                                )..loadData(),
                                child: CoreDialog(),
                              ),
                          fullscreenDialog: true,
                        ),
                      ),
            ),
            model.launch.rocket.secondStage.payloads[0].isNasaPayload
                ? Column(
                    children: <Widget>[
                      ListCell(
                        leading: const Icon(Icons.directions_boat, size: 42.0),
                        title: FlutterI18n.translate(
                          context,
                          'spacex.home.tab.capsule.title',
                        ),
                        subtitle: model.fairings(context),
                      ),
                      const Divider(height: 0.0, indent: 74.0),
                    ],
                  )
                : Container()
          ],
        );
      },
    );
  }

  Widget _buildImage(BuildContext context, int index) {
    return ScopedModelDescendant<SpacexHomeModel>(
      builder: (context, child, model) => CachedNetworkImage(
            imageUrl: model.getPhoto(index),
            errorWidget: const Icon(Icons.error),
            fadeInDuration: Duration(milliseconds: 100),
            fit: BoxFit.cover,
          ),
    );
  }
}
