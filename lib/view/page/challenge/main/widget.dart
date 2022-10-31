/* 챌린지 메인 위젯 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pistachio/global/date.dart';
import 'package:pistachio/global/theme.dart';
import 'package:pistachio/model/class/database/party.dart';
import 'package:pistachio/model/class/database/user.dart';
import 'package:pistachio/model/class/json/challenge.dart';
import 'package:pistachio/model/enum/enum.dart';
import 'package:pistachio/presenter/widget/loading.dart';
import 'package:pistachio/presenter/model/challenge.dart';
import 'package:pistachio/presenter/model/user.dart';
import 'package:pistachio/presenter/page/challenge/detail.dart';
import 'package:pistachio/presenter/page/challenge/main.dart';
import 'package:pistachio/presenter/page/challenge/party/main.dart';
import 'package:pistachio/view/widget/button/button.dart';
import 'package:pistachio/view/widget/widget/badge.dart';
import 'package:pistachio/view/widget/widget/text.dart';
import 'package:pistachio/view/widget/widget/card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChallengeMainView extends StatelessWidget {
  const ChallengeMainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ChallengeTabBar(),
        ChallengeTabView(),
      ],
    );
  }
}

class ChallengeTabBar extends StatelessWidget {
  const ChallengeTabBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChallengeMain>();

    return TabBar(
      controller: controller.tabCont,
      tabs: controller.tabs,
      indicatorColor: PTheme.black,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 1.5,
      labelPadding: const EdgeInsets.all(5.0),
      splashFactory: InkRipple.splashFactory,
    );
  }
}

class ChallengeTabView extends StatelessWidget {
  const ChallengeTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChallengeMain>();

    return Expanded(
      child: TabBarView(
        controller: controller.tabCont,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          ChallengeListView(),
          MyPartyListView(),
        ],
      ),
    );
  }
}

class ChallengeListView extends StatelessWidget {
  const ChallengeListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadingPresenter>(
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.0.r, 20.0.r, 20.0.r, 0.0),
          child: controller.loading
              ? ChallengeCardViewLoading(color: controller.color)
              : const ChallengeCardView(),
        );
      }
    );
  }
}

class ChallengeCardView extends StatelessWidget {
  const ChallengeCardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadingPresenter>(
      builder: (controller) {
        return SmartRefresher(
          controller: ChallengeMain.refreshCont,
          onRefresh: () async {
            ChallengeMain.toChallengeMain();
            ChallengeMain.refreshCont.refreshCompleted();
          },
          onLoading: () async {
            await Future.delayed(const Duration(milliseconds: 100));
            ChallengeMain.refreshCont.loadComplete();
          },
          header: const MaterialClassicHeader(
            color: PTheme.black,
            backgroundColor: PTheme.surface,
          ),
          child: ListView.separated(
            itemCount: ChallengePresenter.challenges.length,
            itemBuilder: (_, index) {
              return ChallengeCard(
                challenge: ChallengePresenter.challenges[index],
              );
            },
            separatorBuilder: (_, index) => SizedBox(height: 30.0.h),
          ),
        );
      }
    );
  }
}


class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final userP = Get.find<UserPresenter>();

    return Column(
      children: [
        Stack(
          children: [
            PCard(
              color: PTheme.background,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // ParallaxWidget(
                  //   background: Image.asset(
                  //     challenge.imageUrls['default'],
                  //     fit: BoxFit.fitHeight,
                  //   ),
                  //   child: Container(height: 200.0),
                  // ),
                  Image.asset(
                    challenge.imageUrls['default'],
                    height: 230.0.h,
                    fit: BoxFit.fitHeight,
                  ),
                  const Divider(height: 1.0, color: PTheme.black, thickness: 1.5),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PText(challenge.title ?? '',
                                  style: textTheme.headlineMedium,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 10.0.h),
                                PText('${today.month}월의 챌린지',
                                  style: textTheme.labelLarge,
                                  color: PTheme.grey,
                                ),
                              ],
                            ),
                            BadgeWidget(
                              size: 80.0.r,
                              badge: challenge.badges[Difficulty.hard],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.0.h),
                        PText(
                          challenge.descriptions['sub']!,
                          style: textTheme.titleSmall,
                          color: PTheme.black,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  userP.alreadyJoinedChallenge(challenge.id!) ? PButton(
                    onPressed: () => ChallengePartyMain.toChallengePartyMain(
                      userP.getPartyByChallengeId(challenge.id!)!
                    ),
                    text: '챌린지 이동하기',
                    stretch: true,
                  ) : PButton(
                    onPressed: () => ChallengeDetail.toChallengeDetail(challenge),
                    text: '알아보러 가기',
                    stretch: true,
                  ),
                ],
              ),
            ),
            if (challenge.locked)
            Positioned.fill(
              child: Container(
                color: PTheme.black.withOpacity(.5),
                child: const Icon(Icons.lock,
                  color: PTheme.black,
                  size: 70.0,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }
}

class ChallengeCardViewLoading extends StatelessWidget {
  const ChallengeCardViewLoading({
    Key? key,
    this.color = PTheme.black,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 2,
      itemBuilder: (_, index) => ChallengeCardLoading(color: color),
      separatorBuilder: (_, index) => SizedBox(height: 50.0.h),
    );
  }
}


class ChallengeCardLoading extends StatelessWidget {
  const ChallengeCardLoading({
    Key? key, this.color = PTheme.black,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
      color: color, borderRadius: BorderRadius.circular(15.0),
    );

    return PCard(
      borderType: BorderType.none,
      color: PTheme.background,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 230.0.h,
            decoration: decoration,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 20.0.r, 20.0.r, 20.0.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 200.0.w,
                          height: 70.0.h,
                          decoration: decoration,
                        ),
                        SizedBox(height: 20.0.h),
                        Container(
                          width: 200.0.w,
                          height: 15.0.h,
                          decoration: decoration,
                        ),
                      ],
                    ),
                    BadgeWidget(size: 80.0.r, color: color, border: false),
                  ],
                ),
                SizedBox(height: 20.0.h),
                Container(
                  width: 200.0.w,
                  height: 30.0.h,
                  decoration: decoration,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 48.0.h,
            decoration: decoration,
          ),
        ],
      ),
    );
  }
}

class MyPartyListView extends StatelessWidget {
  const MyPartyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userP = Get.find<UserPresenter>();
    PUser user = userP.loggedUser;

    return Stack(
      children: [
        if (user.parties.isEmpty)
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: PCard(
              color: PTheme.surface,
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.0.w, vertical: 150.0.h,
                    ),
                    child: PText('챌린지가 없습니다',
                      style: textTheme.displaySmall,
                    ),
                  ),
                  const Divider(
                    color: PTheme.black,
                    thickness: 1.5,
                    height: 0.0,
                  ),
                  GetBuilder<ChallengeMain>(
                    builder: (controller) {
                      return Row(
                        children: [
                          PButton(
                            text: '챌린지 살펴보기',
                            onPressed: () => controller.tabCont.index = 0,
                            stretch: true,
                            fill: false,
                            multiple: true,
                            border: false,
                          ),
                          PButton(
                            text: '챌린지 참여하기',
                            onPressed: controller.challengeJoinButtonPressed,
                            stretch: true,
                            multiple: true,
                            border: false,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ) else Padding(
          padding: EdgeInsets.all(20.0.h),
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                itemCount: user.parties.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) => MyPartyListTile(
                  party: user.parties.values.toList()[index],
                ),
                separatorBuilder: (_, index) => SizedBox(height: 20.0.h),
              ),
              SizedBox(height: 20.0.h),
              GetBuilder<ChallengeMain>(
                builder: (controller) {
                  return Row(
                    children: [
                      PButton(
                        text: '챌린지 살펴보기',
                        onPressed: () => controller.tabCont.index = 0,
                        stretch: true,
                        fill: false,
                        multiple: true,
                      ),
                      SizedBox(width: 20.0.w),
                      PButton(
                        text: '챌린지 참여하기',
                        onPressed: controller.challengeJoinButtonPressed,
                        stretch: true,
                        multiple: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const MyPartyListViewLoading(),
      ],
    );
  }
}

class MyPartyListTile extends StatelessWidget {
  const MyPartyListTile({
    Key? key,
    required this.party,
  }) : super(key: key);

  final Party party;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ChallengePartyMain.toChallengePartyMain(party),
        child: Container(
          height: 80.0.h,
          decoration: BoxDecoration(
            border: Border.all(color: PTheme.black, width: 1.5),
          ),
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Image.asset(
                  party.challenge!.imageUrls['focus'],
                  width: 100.0.w,
                  height: 100.0.h,
                ),
              ),
              const VerticalDivider(
                width: 1.5,
                thickness: 1.5,
                color: PTheme.black,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.0.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PText(party.challenge!.title!.replaceAll('\n', ' '),
                        style: textTheme.bodyLarge,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.people_alt, size: 14.0),
                                const SizedBox(width: 10.0),
                                PText('${party.members.length}/${
                                  party.challenge!.levels[party.difficulty.name]['maxMember']
                                }'),
                              ],
                            ),
                          ),
                          Expanded(child: PText('난이도 : ${party.difficulty.kr}')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 50.0.w,
                child: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPartyListViewLoading extends StatelessWidget {
  const MyPartyListViewLoading({
    Key? key, this.color = PTheme.black,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadingPresenter>(
      builder: (controller) {
        controller.mainColor = color;
        return controller.loading ? ListView.separated(
          shrinkWrap: true,
          itemCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          itemBuilder: (_, index) {
            return Container(
              color: PTheme.background,
              height: 80.0,
              child: Row(
                children: [
                  Container(width: 80.0, height: 80.0.h, color: controller.color),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 200.0, height: 20.0, color: controller.color),
                          Row(
                            children: [
                              Container(width: 80.0, height: 15.0, color: controller.color),
                              const SizedBox(width: 20.0),
                              Container(width: 100.0, height: 15.0, color: controller.color),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50.0,
                    child: Icon(Icons.arrow_forward_ios, color: controller.color),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, index) => const SizedBox(height: 20.0),
        ) : Container();
      },
    );
  }
}
