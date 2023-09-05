import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:web_admin/constants/dimens.dart';
import 'package:web_admin/generated/l10n.dart';
import 'package:web_admin/providers/user_data_provider.dart';
import 'package:web_admin/theme/theme_extensions/app_button_theme.dart';
import 'package:web_admin/utils/app_focus_helper.dart';
import 'package:web_admin/views/widgets/card_elements.dart';
import 'package:web_admin/views/widgets/portal_master_layout/portal_master_layout.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  Future<bool>? _future;

  Future<bool> _getDataAsync() async {

    UserDataProvider userDataProvider;
    
    await Future.delayed(const Duration(seconds: 1), () {
      _formData.userProfileImageUrl = 'https://picsum.photos/id/1005/300/300';
      _formData.username = 'Admin ABC';
      _formData.email = 'adminabc@email.com';
    });

    return true;
  }

  void _doSave(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final lang = Lang.of(context);

      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: lang.recordSavedSuccessfully,
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {},
      );

      dialog.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.myProfile,
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
                    title: lang.myProfile,
                  ),
                  CardBody(
                    child: FutureBuilder<bool>(
                      initialData: null,
                      future: (_future ??= _getDataAsync()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          if (snapshot.hasData && snapshot.data!) {
                            return _content(context);
                          }
                        } else if (snapshot.hasData && snapshot.data!) {
                          return _content(context);
                        }

                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                          child: SizedBox(
                            height: 40.0,
                            width: 40.0,
                            child: CircularProgressIndicator(
                              backgroundColor: themeData.scaffoldBackgroundColor,
                            ),
                          ),
                        );
                      },
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

  Widget _content(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: Stack(
              children: [
                Selector<UserDataProvider, String>(
                  selector: (context, provider) => provider.userProfileImageUrl,
                  builder: (context, value, child){
                    return CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(value),
                      radius: 60.0,
                    );
                  }
                ),
                // Positioned(
                //   top: 0.0,
                //   right: 0.0,
                //   child: SizedBox(
                //     height: 40.0,
                //     width: 40.0,
                //     child: ElevatedButton(
                //       onPressed: () {},
                //       style: themeData.extension<AppButtonTheme>()!.secondaryElevated.copyWith(
                //             shape: MaterialStateProperty.all(const CircleBorder()),
                //             padding: MaterialStateProperty.all(EdgeInsets.zero),
                //           ),
                //       child: const Icon(
                //         Icons.edit_rounded,
                //         size: 20.0,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: Selector<UserDataProvider, String>(
              selector: (context, provider) => provider.username,
              builder: (context, value, child) {
                return FormBuilderTextField(
                  name: 'Name',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Name',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  initialValue: value,
                  validator: FormBuilderValidators.required(),
                  onSaved: (value1) => (value = value1 ?? ''),
                );
              }
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: Selector<UserDataProvider, String>(
              selector: (context, provider) => provider.userphone,
              builder: (context, value, child) {
                return FormBuilderTextField(
                  name: 'Mobile',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Mobile',
                    hintText: 'Mobile',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  initialValue: value,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: FormBuilderValidators.required(),
                  onSaved: (value1) => (value = value1 ?? ''),
                );
              }
            ),
          ),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: SizedBox(
          //     height: 40.0,
          //     child: ElevatedButton(
          //       style: themeData.extension<AppButtonTheme>()!.successElevated,
          //       onPressed: () => _doSave(context),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
          //             child: Icon(
          //               Icons.save_rounded,
          //               size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
          //             ),
          //           ),
          //           Text(lang.save),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class FormData {
  String userProfileImageUrl = '';
  String username = '';
  String email = '';
}
