import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:web_admin/Model/user_model.dart';
import 'package:web_admin/app_router.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/theme/theme_extensions/app_data_table_theme.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class CrudScreen extends StatefulWidget {

  const CrudScreen({Key? key}) : super(key: key);

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late UserDataModel _userDataModel;

  List<UserModel> usermodelList = <UserModel>[];
  List<UserModel> paginationList = <UserModel>[];
  bool _isLoading = false;
  int _totalPageCount = 1;
  late int rangeEnd,rangeStart;
  var selectedPageNumber = 1;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    getAllUsers();
    _dataSource = DataSource(
      onDetailButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.crudDetail}?id=${data['id']}'),
      onDeleteButtonPressed: (data) {},
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appDataTableTheme = themeData.extension<AppDataTableTheme>()!;

    return PortalMasterLayout(
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
            'CRUD',
            style: themeData.textTheme.headlineMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardHeader(
                    title: 'CRUD',
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
                                  SizedBox(
                                    width: 300.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                      child: FormBuilderTextField(
                                        name: 'search',
                                        decoration: InputDecoration(
                                          labelText: lang.search,
                                          hintText: lang.search,
                                          border: const OutlineInputBorder(),
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding),
                                        child: SizedBox(
                                          height: 40.0,
                                          child: ElevatedButton(
                                            style: themeData.extension<AppButtonTheme>()!.infoElevated,
                                            onPressed: () {},
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.search,
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                Text(lang.search),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40.0,
                                        child: ElevatedButton(
                                          style: themeData.extension<AppButtonTheme>()!.successElevated,
                                          onPressed: () => GoRouter.of(context).go(RouteUri.crudDetail),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                child: Icon(
                                                  Icons.add,
                                                  size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                ),
                                              ),
                                              Text(lang.crudNew),
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
    );
  }

  getAllUsers(){

    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance.collection("users").get().then((value){

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
          onDetailButtonPressed: (data) {},
          onDeleteButtonPressed: (data) {},
          usermodelList: usermodelList
        );
      });

    }).onError((error, stackTrace) {
      setState(() {
        _isLoading = false;
      });
    });
  }

}

class UserDataModel extends DataTableSource {
  final void Function(Map<String, dynamic> data) onDetailButtonPressed;
  final void Function(Map<String, dynamic> data) onDeleteButtonPressed;
  final List<UserModel> usermodelList;

  UserDataModel({
    required this.onDetailButtonPressed,
    required this.onDeleteButtonPressed,
    required this.usermodelList,
  });

  // final _data = List.generate(usermodelList.length, (index) {
  //   return {
  //     'id': index + 1,
  //     'no': index + 1,
  //     'item': 'Item ${index + 1}',
  //     'price': Random().nextInt(10000),
  //     'date': '2022-06-30',
  //   };
  // });

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

                  },
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                  child: Text(Lang.of(context).crudDetail),
                ),
              ),
              OutlinedButton(
                onPressed: () {

                },
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

class DataSource extends DataTableSource {
  final void Function(Map<String, dynamic> data) onDetailButtonPressed;
  final void Function(Map<String, dynamic> data) onDeleteButtonPressed;

  final _data = List.generate(200, (index) {
    return {
      'id': index + 1,
      'no': index + 1,
      'item': 'Item ${index + 1}',
      'price': Random().nextInt(10000),
      'date': '2022-06-30',
    };
  });

  DataSource({
    required this.onDetailButtonPressed,
    required this.onDeleteButtonPressed,
  });

  @override
  DataRow? getRow(int index) {
    final data = _data[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['no'].toString())),
      DataCell(Text(data['item'].toString())),
      DataCell(Text(data['price'].toString())),
      DataCell(Text(data['date'].toString())),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onDetailButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                  child: Text(Lang.of(context).crudDetail),
                ),
              ),
              OutlinedButton(
                onPressed: () => onDeleteButtonPressed.call(data),
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
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
