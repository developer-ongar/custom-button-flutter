import 'package:bloc_login/constants.dart';
import 'package:bloc_login/cubit/auth_cubit.dart';
import 'package:bloc_login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({Key? key}) : super(key: key);

  // formkey
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Focus.of(context).unfocus(),
        child: Scaffold(
          body: BlocConsumer<AuthCubit, AuthState>(listener: (context, state) {
            if (state is AuthForgotPasswordError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    backgroundColor: Colors.red, content: Text(state.err!)));
            }
            if (state is AuthForgotPasswordSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Reset link has been sent to your email!")));
            }
          }, builder: (context, state) {
            if (state is AuthDefault) {
              return _buildForgotPasswordScreen(context);
            } else if (state is AuthForgotPasswordLoading) {
              return loader();
            } else if (state is AuthForgotPasswordSuccess) {
              return _buildForgotPasswordScreen(context);
            } else {
              return _buildForgotPasswordScreen(context);
            }
          }),
        ));
  }

  Widget _buildForgotPasswordScreen(BuildContext context) {
    return SafeArea(
      child: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackButton(onPressed: () => Navigator.pop(context)),
                ),
                const Spacer(),
                const Image(
                    image: AssetImage('assets/logo.png'),
                    height: 180,
                    width: 180),
                const Text("Forgot Password?", style: kHeadingStyle),
                const SizedBox(height: 25),
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
                const SizedBox(height: 25),
                SendLinkButton(onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authCubit = BlocProvider.of<AuthCubit>(context);
                    await authCubit.forgotPassword(
                        _formKey.currentState!.fields['email']!.value);
                  }
                }),
                const Spacer(flex: 2),
              ])),
        ),
      ),
    );
  }

  Widget loader() {
    return const Center(child: CircularProgressIndicator());
  }
}

class SendLinkButton extends StatelessWidget {
  final Function onPressed;
  const SendLinkButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      child: const Text("Send Link"),
    );
  }
}
