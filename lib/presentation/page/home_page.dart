import 'package:tes/config/app_color.dart';
import 'package:tes/config/session.dart';
import 'package:tes/presentation/page/auth/login_page.dart';
import 'package:tes/presentation/page/history/history_page.dart';
import 'package:d_chart/d_chart.dart';
import 'package:d_view/d_view.dart';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import '../../config/app_asset.dart';
import '../../config/app_format.dart';
import '../controller/c_home.dart';
import '../controller/c_user.dart';
import 'history/add_history_page.dart';
import 'history/detail_history_page.dart';
import 'history/income_outcome_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final cUser = Get.put(CUser());
  final cHome = Get.put(CHome());
  final GlobalKey<AnimatedFloatingActionButtonState> fabKey = GlobalKey();

  @override
  void initState() {
    cHome.getAnalysis(cUser.data.idUser!);
    super.initState();
  }

  Future<void> logout() async {
    // Clear session data
    await Session.clearUser();

    // Navigate to the login page
    Get.offAll(() => LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //Row baris paling atas ada profil dan icon hamburger
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            child: Row(
              children: [
                Image.asset(AppAsset.profile),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hi,',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Obx(() {
                        return Text(
                          cUser.data.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ],
            ),
          ),
          //-------------------------------Start Details-----------------------------------------------
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                cHome.getAnalysis(cUser.data.idUser!);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  Text(
                    'Pengeluaran Hari Ini',
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  DView.spaceHeight(),
                  //--------------------------Card Details--------------------------------------
                  cardToday(context),
                  //--------------------------Card Details--------------------------------------
                  DView.spaceHeight(30),
                  //--------------------------Box Decoration------------------------------------
                  Center(
                    child: Container(
                      height: 5,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColor.bg,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  //--------------------------Box Decoration------------------------------------
                  DView.spaceHeight(30),

                  Text(
                    'Pengeluaran Minggu Ini',
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  DView.spaceHeight(),

                  weekly(),

                  DView.spaceHeight(30),
                  Text(
                    'Perbandingan Bulan Ini',
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  DView.spaceHeight(),

                  monthly(context),
                ],
              ),
            ),
          ),
          //-------------------------------End Details-----------------------------------------------
        ],
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        key: fabKey,
        fabButtons: <Widget>[float1(), float2(), float3(), float4(), float5()],
        colorStartAnimation: AppColor.primary,
        colorEndAnimation: AppColor.secondary,
        animatedIconData: AnimatedIcons.menu_close,
      ),
    );
  }

  Widget float1() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddHistoryPage())?.then((value) {
            if (value ?? false) {
              cHome.getAnalysis(cUser.data.idUser!);
            }
          });
        },
        heroTag: "add",
        tooltip: 'Tambah Baru',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget float2() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          Get.to(() => const IncomeOutcomePage(type: 'Pemasukan'));
        },
        heroTag: "income",
        tooltip: 'Pemasukan',
        child: Icon(Icons.south_west),
      ),
    );
  }

  Widget float3() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          Get.to(() => const IncomeOutcomePage(type: 'Pengeluaran'));
        },
        heroTag: "outcome",
        tooltip: 'Pengeluaran',
        child: Icon(Icons.north_east),
      ),
    );
  }

  Widget float4() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          Get.to(() => const HistoryPage());
        },
        heroTag: "history",
        tooltip: 'Riwayat',
        child: Icon(Icons.history),
      ),
    );
  }

  Widget float5() {
    return Container(
      child: FloatingActionButton(
        onPressed: () async {
          bool? confirmLogout = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout'),
              content: Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Logout'),
                ),
              ],
            ),
          );

          if (confirmLogout == true) {
            logout();
          }
        },
        heroTag: "logout",
        tooltip: 'Logout',
        child: Icon(Icons.logout),
      ),
    );
  }

  //--------------------------Monthly Details-----------------------------------
  Row monthly(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.5,
          child: Stack(
            children: [
              Obx(() {
                return DChartPie(
                  data: [
                    {'domain': 'income', 'measure': cHome.monthIncome},
                    {'domain': 'outcome', 'measure': cHome.monthOutcome},
                    if (cHome.monthIncome == 0 && cHome.monthOutcome == 0)
                      {'domain': 'nol', 'measure': 1},
                  ],
                  fillColor: (pieData, index) {
                    switch (pieData['domain']) {
                      case 'income':
                        return AppColor.primary;
                      case 'outcome':
                        return AppColor.chart;
                      default:
                        return AppColor.bg.withOpacity(0.5);
                    }
                  },
                  donutWidth: 20,
                  labelColor: Colors.transparent,
                  showLabelLine: false,
                );
              }),
              Center(
                child: Obx(() {
                  return Text(
                    '${cHome.percentIncome}%',
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: AppColor.primary,
                        ),
                  );
                }),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 16,
                  width: 16,
                  color: AppColor.primary,
                ),
                DView.spaceWidth(8),
                const Text('Pemasukan'),
              ],
            ),
            DView.spaceHeight(8),
            Row(
              children: [
                Container(
                  height: 16,
                  width: 16,
                  color: AppColor.chart,
                ),
                DView.spaceWidth(8),
                const Text('Pengeluaran'),
              ],
            ),
            DView.spaceHeight(20),
            Obx(() {
              return Text(cHome.monthPercent);
            }),
            DView.spaceHeight(10),
            const Text('Atau setara:'),
            Obx(() {
              return Text(
                AppFormat.currency(cHome.differentMonth.toString()),
                style: const TextStyle(
                  color: AppColor.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
  //--------------------------Monthly Details-----------------------------------

  //--------------------------Weekly Details------------------------------------
  AspectRatio weekly() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Obx(() {
        return DChartBar(
          data: [
            {
              'id': 'Bar',
              'data': List.generate(7, (index) {
                return {
                  'domain': cHome.weekText()[index],
                  'measure': cHome.week[index]
                };
              })
            },
          ],
          domainLabelPaddingToAxisLine: 8,
          axisLineTick: 2,
          axisLineColor: AppColor.primary,
          measureLabelPaddingToAxisLine: 16,
          barColor: (barData, index, id) => AppColor.primary,
          showBarValue: true,
        );
      }),
    );
  }
  //--------------------------Weekly Details------------------------------------

  //--------------------------Card Details--------------------------------------
  Material cardToday(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      color: AppColor.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Obx(() {
              return Text(
                AppFormat.currency(cHome.today.toString()),
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondary,
                    ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            child: Obx(() {
              return Text(
                cHome.todayPercent,
                style: const TextStyle(color: AppColor.bg, fontSize: 16),
              );
            }),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => DetailHistoryPage(
                    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    idUser: cUser.data.idUser!,
                    type: 'Pengeluaran',
                  ));
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 0, 16),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Selengkapnya',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                    ),
                  ),
                  Icon(Icons.navigate_next, color: AppColor.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  //--------------------------Card Details--------------------------------------
}
