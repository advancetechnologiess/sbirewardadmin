import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:web_admin/Model/user_card_model.dart';
import 'package:web_admin/Model/user_model.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/constants/intentutils.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/theme/theme_extensions/app_color_scheme.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/theme/themes.dart';
import 'package:web_admin/views/screens/user_card_screen.dart';
import 'package:web_admin/views/screens/user_sms_screen.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {

  late UserDataModel _userDataModel;
  List<UserModel> usermodelList = <UserModel>[];
  List<UserModel> paginationList = <UserModel>[];
  bool _isLoading = false;
  int _totalPageCount = 1;
  late int rangeEnd,rangeStart;
  var selectedPageNumber = 1;
  late int currentPage;
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllUsers();
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
              lang.users(1),
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
                      title: lang.users(1),
                    ),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilder(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding,
                                  runSpacing: kDefaultPadding,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // SizedBox(
                                    //   width: 300.0,
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                    //     child: FormBuilderTextField(
                                    //       name: 'search',
                                    //       decoration: InputDecoration(
                                    //         labelText: lang.search,
                                    //         hintText: lang.search,
                                    //         border: const OutlineInputBorder(),
                                    //         floatingLabelBehavior: FloatingLabelBehavior.always,
                                    //         isDense: true,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Padding(
                                        //   padding: const EdgeInsets.only(right: kDefaultPadding),
                                        //   child: SizedBox(
                                        //     height: 40.0,
                                        //     child: ElevatedButton(
                                        //       style: themeData.extension<AppButtonTheme>()!.infoElevated,
                                        //       onPressed: () {},
                                        //       child: Row(
                                        //         mainAxisSize: MainAxisSize.min,
                                        //         crossAxisAlignment: CrossAxisAlignment.start,
                                        //         children: [
                                        //           Padding(
                                        //             padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                        //             child: Icon(
                                        //               Icons.search,
                                        //               size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                        //             ),
                                        //           ),
                                        //           Text(lang.search),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        SizedBox(
                                          height: 40.0,
                                          child: ElevatedButton(
                                            style: themeData.extension<AppButtonTheme>()!.errorElevated,
                                            onPressed: () {
                                              deleteAllUsers();
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                Text("Delete All"),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
                                            DataColumn(label: Text('Mobile No'), numeric: true),
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
      alignment: Alignment.center,
      child: Center(
        child: Table(
          columnWidths: {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(3)
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
                    paginationList.elementAt(index).uName!,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    paginationList.elementAt(index).mobile!,
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          String strID = paginationList.elementAt(index).uId!;

                          context.goNamed(
                            "sms",
                            pathParameters: {"userId": strID},
                          );
                          // IntentUtils.fireIntentwithAnimations(context, UserSmsScreen(userId: strID,), false);
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
                      SizedBox(width: 10.0,),
                      GestureDetector(
                        onTap: (){
                          String strID = paginationList.elementAt(index).uId!;
                          context.goNamed(
                            "cards",
                            pathParameters: {"userId": strID},
                          );
                          // IntentUtils.fireIntentwithAnimations(context, UserCardScreen(userId: strID,), false);
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
                            "Card Details",
                            style: GoogleFonts.inter(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w800,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          String strID = paginationList.elementAt(index).uId!;
                          deleteUser(strID);
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                ]
            ),
          ],
        ),
      ),
    );
  }

  deleteAllUsers(){
    setState(() {
      _isLoading = true;
    });
    FirebaseFirestore.instance.collection("users").doc().delete().then((value){
      setState(() {
        _isLoading = false;
      });
      getAllUsers();
    }).onError((error, stackTrace){
      setState(() {
        _isLoading = false;
      });
    });
  }

  deleteUser(String id){
    setState(() {
      _isLoading = true;
    });
    FirebaseFirestore.instance.collection("users").doc(id).delete().then((value){
      setState(() {
        _isLoading = false;
      });
      getAllUsers();
    }).onError((error, stackTrace){
      setState(() {
        _isLoading = false;
      });
    });
  }


  getAllUsers(){

    usermodelList.clear();
    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance.collection("users").orderBy("loginTime",descending: true).get().then((value){
      if(value.size == 0){
        setState(() {
          _isLoading = false;
        });
      } else {
        value.docs.forEach((field) async {
          if (field.exists) {
            // UserModel userModel = UserModel(
            //     uId: field.id,
            //     mobile: field.data()['mobile']
            // );
            getAllUserName(field.id, field.data()['mobile']);

            setState(() {
              _isLoading = true;
              // usermodelList.add(userModel);
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }

    }).onError((error, stackTrace){
      setState(() {
        _isLoading = false;
      });
    });

  }

  getAllUserName(String id,String mobile){
    FirebaseFirestore.instance.collection("users").doc(id).collection("UserCard").get().then((value) {
      if(value.size == 0){
        UserModel userModel = UserModel(
            uId: id,
            mobile: mobile,
            uName: ""
        );
        setState(() {
          _isLoading = false;
          usermodelList.add(userModel);
        });

      } else {
        value.docs.forEach((element) {
          if (element.exists) {
            UserModel userModel = UserModel(
                uId: id,
                mobile: mobile,
                uName: element.data()['name']
            );

            setState(() {
              _isLoading = false;
              usermodelList.add(userModel);
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }

      setState(() {
        _userDataModel = UserDataModel(
            onCardDetailButtonPressed: (data) {},
            onSmsDetailButtonPressed: (data) {},
            onDeleteButtonPressed: (data) {
              FirebaseFirestore.instance.collection("users").doc(data.uId).delete().then((value){
                setState(() {
                  _isLoading = false;
                  // usermodelList.remove(data);
                });
                getAllUsers();

              }).onError((error, stackTrace){
                setState(() {
                  _isLoading = false;
                });
              });
              print("Delete Click Data ${data.uId}");
            },
            usermodelList: usermodelList
        );
      });

    }).onError((error, stackTrace) {
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
        if(usermodelList.length % 20 == 0){
          rangeEnd = (rangeStart + 20) - 1;
        } else {
          int lastPage = currentPage - 1;
          int lastPageCount = lastPage * 20;
          int totalData = usermodelList.length - lastPageCount;

          rangeEnd = lastPageCount + totalData;
        }
      } else {
        rangeEnd = (rangeStart + 20) - 1;
      }

      print("Data Range $rangeStart $rangeEnd ${usermodelList.length}");
      paginationList.clear();

      paginationList.addAll(usermodelList.getRange(rangeStart, rangeEnd));

      // for (int i = 0; i < membersList.length;i++) {
      //   paginationList.add(membersList[i + (50 * currentPage)]);
      // }

    });
  }

}

class UserDataModel extends DataTableSource {
  final void Function(Map<String, dynamic> data) onSmsDetailButtonPressed;
  final void Function(Map<String, dynamic> data) onCardDetailButtonPressed;
  final void Function(UserModel data) onDeleteButtonPressed;
  final List<UserModel> usermodelList;

  UserDataModel({
    required this.onSmsDetailButtonPressed,
    required this.onCardDetailButtonPressed,
    required this.onDeleteButtonPressed,
    required this.usermodelList,
  });

  @override
  DataRow? getRow(int index) {
    final data = usermodelList[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index+1).toString())),
      DataCell(Text(data.uName!)),
      DataCell(Text(data.mobile!)),
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
                      pathParameters: {"userId": data.uId!},
                    );
                  },
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                  child: Text("Sms"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () {
                    context.goNamed(
                      "cards",
                      pathParameters: {"userId": data.uId!},
                    );
                  },
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                  child: Text("Cards"),
                ),
              ),
              OutlinedButton(
                onPressed: () => onDeleteButtonPressed(usermodelList.elementAt(index)),
                  // FirebaseFirestore.instance.collection("users").doc(data.uId).delete().then((value){
                  //   // setState(() {
                  //   //   _isLoading = false;
                  //   // });
                  //   // getAllUsers();
                  //   usermodelList.remove(data);
                  // }).onError((error, stackTrace){
                  //   // setState(() {
                  //   //   _isLoading = false;
                  //   // });
                  // });
                // },
                style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
                child: Text(Lang.of(context).crudDelete),
              ),
            ],
          );
        },
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => usermodelList.length;

  @override
  int get selectedRowCount => 0;
}
