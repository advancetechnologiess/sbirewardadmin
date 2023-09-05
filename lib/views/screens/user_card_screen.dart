import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_admin/Model/user_card_model.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/constants/intentutils.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/theme/theme_extensions/app_color_scheme.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/theme/themes.dart';
import 'package:web_admin/views/screens/user_sms_screen.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class UserCardScreen extends StatefulWidget {

  String userId;

  UserCardScreen({super.key,required this.userId});

  @override
  State<UserCardScreen> createState() => _UserCardScreenState();
}

class _UserCardScreenState extends State<UserCardScreen> {

  List<UserCardModel> usercardmodelList = <UserCardModel>[];
  bool _isLoading = false;
  late UserCardDataModel _userDataModel;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUsercards();
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
              lang.usercards(1),
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
                      title: lang.usercards(1),
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
                                          columns: const [
                                            DataColumn(label: Text('No.'), numeric: true),
                                            DataColumn(label: Text('Name')),
                                            DataColumn(label: Text('Card No'), numeric: true),
                                            DataColumn(label: Text('Card CVV'), numeric: true),
                                            DataColumn(label: Text('Card Exp')),
                                            DataColumn(label: Text('Actions')),
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

  rowUserCard(int index){

    return Container(
      padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
      child: Center(
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(0.5),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
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
                    usercardmodelList.elementAt(index).holderName!,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    usercardmodelList.elementAt(index).cardNumber!,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    usercardmodelList.elementAt(index).cvv!,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    
                    usercardmodelList.elementAt(index).expiryDate!,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){

                      context.goNamed(
                        "sms",
                        pathParameters: {"userId": widget.userId},
                      );

                      // IntentUtils.fireIntentwithAnimations(context, UserSmsScreen(userId: widget.userId,), false);
                    },
                    child: Container(
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                            color: kPrimaryColor,
                            width: 1.5
                        ),
                      ),
                      child: Text(
                        "Sms Details",
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }

  getAllUsercards(){

    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance.collection("users").doc(widget.userId).collection("UserCard").get().then((value){

      if(value.size == 0){
        setState(() {
          _isLoading = false;
        });
      } else {
        value.docs.forEach((field) async {
          UserCardModel userCardModel = UserCardModel(
            expiryDate: field.data()['expiryDate'],
            cvv: field.data()['cvv'],
            holderName: field.data()['holderName'],
            cardNumber: field.data()['cardNumber'],
          );

          setState(() {
            _isLoading = false;
            usercardmodelList.add(userCardModel);
          });
        });
      }

      setState(() {
        _isLoading = false;
        _userDataModel = UserCardDataModel(
            onSmsDetailButtonPressed: (data) {},
            userCardmodelList: usercardmodelList,
            userid: widget.userId,
        );
      });

    }).onError((error, stackTrace){
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    return false;
  }
}

class UserCardDataModel extends DataTableSource {
  final void Function(Map<String, dynamic> data) onSmsDetailButtonPressed;
  final List<UserCardModel> userCardmodelList;
  final String userid;

  UserCardDataModel({
    required this.onSmsDetailButtonPressed,
    required this.userCardmodelList,
    required this.userid,
  });

  @override
  DataRow? getRow(int index) {
    final data = userCardmodelList[index];
    String userId = userid;

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index+1).toString())),
      DataCell(Text(data.holderName!)),
      DataCell(Text(data.cardNumber!)),
      DataCell(Text(data.cvv!)),
      DataCell(Text(data.expiryDate!)),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () {
                    context.goNamed(
                      "sms",
                      pathParameters: {"userId": userId},
                    );
                  },
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                  child: Text("Sms"),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(right: kDefaultPadding),
              //   child: OutlinedButton(
              //     onPressed: () {
              //       context.goNamed(
              //         "cards",
              //         pathParameters: {"userId": data.uId!},
              //       );
              //     },
              //     style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
              //     child: Text("Cards"),
              //   ),
              // ),
              // OutlinedButton(
              //   onPressed: () {
              //
              //   },
              //   style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
              //   child: Text(Lang.of(context).crudDelete),
              // ),
            ],
          );
        },
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => userCardmodelList.length;

  @override
  int get selectedRowCount => 0;
}
