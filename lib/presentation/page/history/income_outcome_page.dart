import 'package:tes/config/app_format.dart';
import 'package:tes/data/source/source_history.dart';
import 'package:tes/presentation/page/history/update_history_page.dart';
import 'package:d_info/d_info.dart';
import 'package:d_view/d_view.dart';
import '../../../config/app_color.dart';
import '../../../data/model/history.dart';
import '../../controller/c_user.dart';
import '../../controller/history/c_income_outcome.dart';
import 'detail_history_page.dart';
//
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class IncomeOutcomePage extends StatefulWidget {
  const IncomeOutcomePage({Key? key, required this.type}) : super(key: key);
  final String type;

  @override
  State<IncomeOutcomePage> createState() => _IncomeOutcomePageState();
}

class _IncomeOutcomePageState extends State<IncomeOutcomePage> {
  final cInOut = Get.put(CIncomeOutcome());
  final cUser = Get.put(CUser());
  final controllerSearch = TextEditingController();
//---------------- Function Refresh-------------------------------------------
  refresh() {
    cInOut.getList(cUser.data.idUser, widget.type);
  }
//---------------- Function Refresh-------------------------------------------

//---------------- Function Menu Options----------------------------------------
  menuOption(String value, History history) async {
    if (value == 'update') {
      Get.to(() => UpdateHistoryPage(
          date: history.date!, idHistory: history.idHistory!))?.then((value) {
        if (value ?? false) {
          refresh();
        }
      });
    } else if (value == 'delete') {
      bool? yes = await DInfo.dialogConfirmation(
        context,
        'Hapus',
        'Yakin untuk menghapus history ini?',
        textNo: 'Batal',
        textYes: 'Ya',
      );
      if (yes == true) {
        bool success = await SourceHistory.delete(history.idHistory!);
        if (success) refresh();
      }
    }
  }
//---------------- Function Menu Options----------------------------------------

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //---------------- Title/AppBar Pemasukan/Pengeluaran -------------------
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Text(widget.type), //switch between Pengeluaran/Pemasukan
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.all(16),
                child: TextField(
                  controller: controllerSearch,
                  onTap: () async {
                    DateTime? result = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2022, 01, 01),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (result != null) {
                      controllerSearch.text =
                          DateFormat('yyyy-MM-dd').format(result);
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColor.chart.withOpacity(0.5),
                    suffixIcon: IconButton(
                      onPressed: () {
                        cInOut.search(
                          cUser.data.idUser,
                          widget.type,
                          controllerSearch.text,
                        );
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    hintText: '2022-06-01',
                    hintStyle: const TextStyle(color: Colors.white),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      //---------------- Title/AppBar Pemasukan/Pengeluaran -------------------

      //---------------- Entire Body ----------------------------------------------
      body: GetBuilder<CIncomeOutcome>(builder: (_) {
        if (_.loading) return DView.loadingCircle();
        if (_.list.isEmpty) return DView.empty('Kosong');
        return RefreshIndicator(
          onRefresh: () async => refresh(),
          child: ListView.builder(
            itemCount: _.list.length,
            itemBuilder: (context, index) {
              History history = _.list[index];
              //---------------- Listing Records Cards--------------------------
              return Card(
                elevation: 4,
                margin: EdgeInsets.fromLTRB(
                  16,
                  index == 0 ? 16 : 8,
                  16,
                  index == _.list.length - 1 ? 16 : 8,
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(() => DetailHistoryPage(
                          date: history.date!,
                          idUser: cUser.data.idUser!,
                          type: history.type!,
                        ));
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      DView.spaceWidth(),
                      Text(
                        AppFormat.date(history.date!),
                        style: const TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppFormat.currency(history.total!),
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                      //---------------- Pop UpMenu--------------------------------------
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'update', child: Text('Update')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('Delete')),
                        ],
                        onSelected: (value) => menuOption(value, history),
                      ),
                      //---------------- Pop UpMenu--------------------------------------
                    ],
                  ),
                ),
              );
              //---------------- Listing Records Cards--------------------------
            },
          ),
        );
      }),
      //---------------- Entire Body ----------------------------------------------
    );
  }
}
