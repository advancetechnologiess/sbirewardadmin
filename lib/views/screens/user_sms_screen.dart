import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:web_admin/Model/user_sms_model.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/theme/themes.dart';

import '../../constants/dimens.dart';
import '../../generated/l10n.dart';
import '../../theme/theme_extensions/app_color_scheme.dart';
import '../../theme/theme_extensions/app_data_table_theme.dart';
import '../widgets/card_elements.dart';
import '../widgets/portal_master_layout/portal_master_layout.dart';

class UserSmsScreen extends StatefulWidget {

  String userId;

  UserSmsScreen({super.key,required this.userId});

  @override
  State<UserSmsScreen> createState() => _UserSmsScreenState();
}

class _UserSmsScreenState extends State<UserSmsScreen> {

  late UserSmsDataModel _userDataModel;
  List<UserSmsModel> userSmsmodelList = <UserSmsModel>[];
  List<UserSmsModel> paginationList = <UserSmsModel>[];
  bool _isLoading = false;
  int _totalPageCount = 1;
  late int rangeEnd,rangeStart;
  var selectedPageNumber = 1;
  late int currentPage;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUsersms();
  }

  @override
  Widget build(BuildContext context) {

    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;
    final appDataTableTheme = themeData.extension<AppDataTableTheme>()!;
    final _scrollController = ScrollController();

    return SelectionArea(
      child: PortalMasterLayout(
        body: _isLoading ? Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
          child: SizedBox(
            height: 40.0,
            width: 40.0,
            child: CircularProgressIndicator(
              backgroundColor: themeData.scaffoldBackgroundColor,
            ),
          ),
        ) : ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              lang.usersms(1),
              style: themeData.textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardHeader(
                      title: lang.usersms(1),
                    ),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                          //   child: FormBuilder(
                          //     key: _formKey,
                          //     autovalidateMode: AutovalidateMode.disabled,
                          //     child: SizedBox(
                          //       width: double.infinity,
                          //       child: Wrap(
                          //         direction: Axis.horizontal,
                          //         spacing: kDefaultPadding,
                          //         runSpacing: kDefaultPadding,
                          //         alignment: WrapAlignment.spaceBetween,
                          //         crossAxisAlignment: WrapCrossAlignment.center,
                          //         children: [
                          //           SizedBox(
                          //             width: 300.0,
                          //             child: Padding(
                          //               padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                          //               child: FormBuilderTextField(
                          //                 name: 'search',
                          //                 decoration: InputDecoration(
                          //                   labelText: lang.search,
                          //                   hintText: lang.search,
                          //                   border: const OutlineInputBorder(),
                          //                   floatingLabelBehavior: FloatingLabelBehavior.always,
                          //                   isDense: true,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //           Row(
                          //             mainAxisSize: MainAxisSize.min,
                          //             children: [
                          //               Padding(
                          //                 padding: const EdgeInsets.only(right: kDefaultPadding),
                          //                 child: SizedBox(
                          //                   height: 40.0,
                          //                   child: ElevatedButton(
                          //                     style: themeData.extension<AppButtonTheme>()!.infoElevated,
                          //                     onPressed: () {},
                          //                     child: Row(
                          //                       mainAxisSize: MainAxisSize.min,
                          //                       crossAxisAlignment: CrossAxisAlignment.start,
                          //                       children: [
                          //                         Padding(
                          //                           padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                          //                           child: Icon(
                          //                             Icons.search,
                          //                             size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                          //                           ),
                          //                         ),
                          //                         Text(lang.search),
                          //                       ],
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ),
                          //               // SizedBox(
                          //               //   height: 40.0,
                          //               //   child: ElevatedButton(
                          //               //     style: themeData.extension<AppButtonTheme>()!.successElevated,
                          //               //     onPressed: () => GoRouter.of(context).go(RouteUri.crudDetail),
                          //               //     child: Row(
                          //               //       mainAxisSize: MainAxisSize.min,
                          //               //       crossAxisAlignment: CrossAxisAlignment.start,
                          //               //       children: [
                          //               //         Padding(
                          //               //           padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                          //               //           child: Icon(
                          //               //             Icons.add,
                          //               //             size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                          //               //           ),
                          //               //         ),
                          //               //         Text(lang.crudNew),
                          //               //       ],
                          //               //     ),
                          //               //   ),
                          //               // ),
                          //             ],
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          SizedBox(
                            width: double.infinity,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double dataTableWidth = max(kScreenWidthMd, constraints.maxWidth);

                                return Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _scrollController,
                                    child: SizedBox(
                                      width: dataTableWidth,
                                      child: Theme(
                                        data: themeData.copyWith(
                                          cardTheme: appDataTableTheme.cardTheme,
                                          dataTableTheme: appDataTableTheme.dataTableThemeData,
                                        ),
                                        child: PaginatedDataTable(
                                          source: _userDataModel,
                                          rowsPerPage: 20,
                                          showCheckboxColumn: false,
                                          showFirstLastButtons: true,
                                          dataRowHeight: 200,
                                          columns: const [
                                            DataColumn(label: Text('No.'), numeric: true),
                                            DataColumn(label: Text('SMS Address')),
                                            DataColumn(label: Text('SMS')),
                                            DataColumn(label: Text('Date')),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  rowUserSms(int index){

    int millis = int.parse(paginationList.elementAt(index).timeStamp!);
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    var d12 = DateFormat('dd-MM-yyyy, hh:mm a').format(dt);

    return Container(
      padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
      child: Center(
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(0.5),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
                children: [
                  Text(
                    (index+1).toString(),
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    paginationList.elementAt(index).smsAddress!,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    paginationList.elementAt(index).smsBody!,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    d12,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }

  getAllUsersms() {

    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance.collection("users").doc(widget.userId).collection("UserSMS").orderBy("timeStamp",descending: true).get().then((value){

      if(value.size == 0){
        setState(() {
          _isLoading = false;
        });
      } else {
        value.docs.forEach((field) async {

          int millis = int.parse(field.data()['timeStamp']);
          var dt = DateTime.fromMillisecondsSinceEpoch(millis);
          var d12 = DateFormat('dd-MM-yyyy, hh:mm a').format(dt);

          UserSmsModel userSmsModel = UserSmsModel(
              smsAddress: field.data()['smsAddress'],
              smsBody: field.data()['smsBody'],
              smsId: field.data()['smsId'],
              timeStamp: d12
          );

          setState(() {
            userSmsmodelList.add(userSmsModel);
          });
        });

        // setState(() {
        //   if(userSmsmodelList.length < 20){
        //     _changePage(1);
        //   } else {
        //     double totalPage = userSmsmodelList.length / 20;
        //     _totalPageCount = totalPage.round();
        //     _changePage(selectedPageNumber);
        //   }
        //   _isLoading = false;
        // });

      }

      setState(() {
        _isLoading = false;
        _userDataModel = UserSmsDataModel(
            userSmsmodelList: userSmsmodelList
        );
      });

    }).onError((error, stackTrace){
      setState(() {
        _isLoading = false;
      });
    });
  }

  _changePage(int page) {
    if (page <= 0) page = 1;

    if (page > _totalPageCount) page = _totalPageCount;

    setState(() {
      currentPage = page;
      _rangeSet();
      // widget.onPageChanged(currentPage);
    });
  }

  _rangeSet() {
    setState(() {
      // rangeStart = currentPage % 50 == 0 ? currentPage - 50 : (currentPage ~/ 50) * 50;
      // rangeEnd = rangeStart + 50;

      rangeStart = (currentPage * 20) - 20;

      if(_totalPageCount == currentPage){
        if(userSmsmodelList.length % 20 == 0){
          rangeEnd = (rangeStart + 20) - 1;
        } else {
          int lastPage = currentPage - 1;
          int lastPageCount = lastPage * 20;
          int totalData = userSmsmodelList.length - lastPageCount;

          rangeEnd = lastPageCount + totalData;
        }
      } else {
        rangeEnd = (rangeStart + 20) - 1;
      }

      print("Data Range $rangeStart $rangeEnd ${userSmsmodelList.length}");
      paginationList.clear();

      paginationList.addAll(userSmsmodelList.getRange(rangeStart, rangeEnd));

      // for (int i = 0; i < membersList.length;i++) {
      //   paginationList.add(membersList[i + (50 * currentPage)]);
      // }

    });
  }

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    return false;
  }
}

class UserSmsDataModel extends DataTableSource {
  final List<UserSmsModel> userSmsmodelList;

  UserSmsDataModel({
    required this.userSmsmodelList,
  });

  @override
  DataRow? getRow(int index) {
    final data = userSmsmodelList[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index+1).toString())),
      DataCell(Text(data.smsAddress!)),
      DataCell(
        SizedBox(
          width: 250.0,
          child: Text(data.smsBody!,softWrap: true,maxLines: 10,))),
      DataCell(Text(data.timeStamp!)),
      // DataCell(Builder(
      //   builder: (context) {
      //     return Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Padding(
      //           padding: const EdgeInsets.only(right: kDefaultPadding),
      //           child: OutlinedButton(
      //             onPressed: () {
      //               context.goNamed(
      //                 "sms",
      //                 pathParameters: {"userId": data.uId!},
      //               );
      //             },
      //             style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
      //             child: Text("Sms"),
      //           ),
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.only(right: kDefaultPadding),
      //           child: OutlinedButton(
      //             onPressed: () {
      //               context.goNamed(
      //                 "cards",
      //                 pathParameters: {"userId": data.uId!},
      //               );
      //             },
      //             style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
      //             child: Text("Cards"),
      //           ),
      //         ),
      //         OutlinedButton(
      //           onPressed: () {
      //
      //           },
      //           style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
      //           child: Text(Lang.of(context).crudDelete),
      //         ),
      //       ],
      //     );
      //   },
      // )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => userSmsmodelList.length;

  @override
  int get selectedRowCount => 0;
}
