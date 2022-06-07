import 'package:bloc_login/constants.dart';
import 'package:bloc_login/cubit/auth_cubit.dart';
import 'package:bloc_login/views/home/home_screen.dart';
import 'package:bloc_login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../auth_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  /// the form key
  final _formKey = GlobalKey<FormBuilderState>();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: GestureDetector(
          onTap: () => Focus.of(context).unfocus(),
          child: Scaffold(
            body: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthLoginError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                    ));
                }
                if (state is AuthLoginSuccess) {
                  _formKey.currentState!.reset();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HomeScreen(
                                user: state.user,
                              )));
                }
              },
              builder: (context, state) => _theLoginScreen(),
            ),
          ),
        ));
  }

  Widget _theLoginScreen() {
    return SafeArea(
      child: FormBuilder(
          key: _formKey,
          // this comes with autovalidating the form field
          // we will use our own validations
          autovalidateMode: AutovalidateMode.disabled,
          child: Center(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                    image: AssetImage('assets/logo.png'),
                    height: 180,
                    width: 180),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: FormBuilderTextField(
                    textInputAction: TextInputAction.next,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.email(context,
                          errorText: "Enter a valid email address")
                    ]),
                    name: "email",
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      prefixIcon: const Icon(Icons.email),
                      hintText: "Enter email",
                      hintStyle: kHintStyle,
                      fillColor: Colors.grey[200],
                      filled: true,
                      enabledBorder: kOutlineBorder,
                      focusedBorder: kOutlineBorder,
                      errorBorder: kErrorBorder,
                      focusedErrorBorder: kErrorBorder,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: FormBuilderTextField(
                    textInputAction: TextInputAction.next,
                    obscureText: isObscure,
                    name: "password",
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Enter password",
                      hintStyle: kHintStyle,
                      fillColor: Colors.grey[200],
                      filled: true,
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                          child: Icon(
                            isObscure
                                ? Icons.radio_button_off
                                : Icons.radio_button_checked,
                            size: 20,
                          )),
                      enabledBorder: kOutlineBorder,
                      focusedBorder: kOutlineBorder,
                      errorBorder: kErrorBorder,
                      focusedErrorBorder: kErrorBorder,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                LoginButton(onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authCubit = BlocProvider.of<AuthCubit>(context);
                    await authCubit.login(
                        _formKey.currentState!.fields['email']!.value,
                        _formKey.currentState!.fields['password']!.value);
                  }
                }),
                TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: const Text("Forgot Password?")),
                const Divider(height: 20, endIndent: 8, indent: 8),
                CustomButton(
                    child: const Text("Create An Account"),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.signup)),
              ],
            ),
          ))),
    );
  }

  // override the back button that comes installed
  // with it
  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: const Text("Exit Application"),
                    content: const Text("Are you Sure?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            SystemNavigator.pop();
                          },
                          child: const Text("YES",
                              style: TextStyle(color: Colors.red))),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("NO",
                              style: TextStyle(color: Colors.black54))),
                    ]))) ??
        false;
  }
}

// login button

class LoginButton extends StatelessWidget {
  final Function onPressed;
  const LoginButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is AuthLoginLoading) {
              return kLoadeBtn;
            } else {
              return const Text("Login");
            }
          }),
    );
  }
}
