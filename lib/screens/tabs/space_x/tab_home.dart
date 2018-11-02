import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:native_widgets/native_widgets.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/rockets/spacex_home.dart';
import '../../../util/colors.dart';
import '../../../widgets/spacex_home_detail.dart';

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
                      title: Text('Welcome to SpaceX'),
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
            Text(
              model.getCountdown,
              style: Theme.of(context).textTheme.headline,
            ),
            Container(height: 16.0),
            const Divider(height: 0.0),
            SpacexHomeDetail(Icons.public,
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
            const Divider(height: 0.0, indent: 74.0),
            SpacexHomeDetail(Icons.calendar_today,
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
            const Divider(height: 0.0, indent: 74.0),
            SpacexHomeDetail(Icons.location_on,
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
            const Divider(height: 0.0, indent: 74.0),
            SpacexHomeDetail(Icons.timer,
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
            const Divider(height: 0.0, indent: 74.0),
            SpacexHomeDetail(Icons.directions_boat,
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
            const Divider(height: 0.0, indent: 74.0),
            SpacexHomeDetail(Icons.flight_land,
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'),
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
