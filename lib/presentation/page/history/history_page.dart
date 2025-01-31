import 'package:tes/config/app_format.dart';
import 'package:tes/data/source/source_history.dart';
import 'package:d_info/d_info.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../config/app_color.dart';
import '../../../data/model/history.dart';
import '../../controller/c_user.dart';
import '../../controller/history/c_history.dart';
import 'detail_history_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final cHistory = Get.put(CHistory());
  final cUser = Get.put(CUser());
  final controllerSearch = TextEditingController();

  //---------------- Function Refresh-------------------------------------------
  refresh() {
    cHistory.getList(cUser.data.idUser);
  }
  //---------------- Function Refresh-------------------------------------------

  //---------------- Delete Function ------------------------------------------
  delete(String idHistory) async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Hapus',
      'Yakin untuk menghapus history ini?',
      textNo: 'Batal',
      textYes: 'Ya',
    );
    if (yes == true) {
      bool success = await SourceHistory.delete(idHistory);
      if (success) refresh();
    }
  }
  //---------------- Delete Function ---------------------------------------------

  @override
  void initState() {
    refresh();
    super.initState();
  }

  Future<void> generateAndDownloadPDF() async {
    final pdf = pw.Document();
    final historyList = cHistory.list;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('History', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Date', 'Type', 'Total'],
              data: historyList.map((history) {
                return [
                  history.date,
                  history.type,
                  AppFormat.currency(history.total.toString()),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //---------------- Title/AppBar Riwayat -------------------------------------
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const Text('Riwayat'),
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.all(16),
                //---------------- Date Input with borderRadius Circle-----------------------------
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
                        cHistory.search(
                          cUser.data.idUser,
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
                  //---------------- Date Input with borderRadius Circle-----------------------------
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: generateAndDownloadPDF,
          ),
        ],
      ),
      //---------------- Title/AppBar Riwayat -------------------------------------

      //---------------- Entire Body ----------------------------------------------
      body: GetBuilder<CHistory>(builder: (_) {
        if (_.loading) return DView.loadingCircle();
        if (_.list.isEmpty) return DView.empty('Kosong');
        return RefreshIndicator(
          onRefresh: () async => refresh(),
          child: ListView.builder(
            itemCount: _.list.length,
            itemBuilder: (context, index) {
              History history = _.list[index];
              //---------------- data Listing With Card ------------------------
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
                      history.type == 'Pemasukan'
                          ? Icon(Icons.south_west, color: Colors.green[300])
                          : Icon(Icons.north_east, color: Colors.red[300]),
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
                      IconButton(
                        onPressed: () => delete(history.idHistory!),
                        icon:
                            Icon(Icons.delete_forever, color: Colors.red[300]!),
                      ),
                    ],
                  ),
                ),
              );
              //---------------- data Listing With Card ------------------------
            },
          ),
        );
      }),
      //---------------- Entire Body ----------------------------------------------
    );
  }
}
   