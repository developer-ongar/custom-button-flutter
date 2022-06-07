import 'package:bloc_login/constants.dart';
import 'package:bloc_login/cubit/auth_cubit.dart';
import 'package:bloc_login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // initialization
  final formKey = GlobalKey<FormBuilderState>();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSignUpError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ));
            }
            if (state is AuthSignUpSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text("Account has been created successfully!"),
                  backgroundColor: Colors.green,
                ));
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is AuthDefault) {
              return _buildSignUpForm();
            } else if (state is AuthSignUpLoading) {
              return _loading();
            } else if (state is AuthSignUpSuccess) {
              return _buildSignUpForm();
            } else {
              return _buildSignUpForm();
            }
          },
        )));
  }

  Widget _buildSignUpForm() {
    return SafeArea(
      child: SingleChildScrollView(
          child: FormBuilder(
              key: formKey,
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                          BackButton(onPressed: () => Navigator.pop(context)),
                    ),
                    const SizedBox(height: 40),
                    const Image(
                        image: AssetImage('assets/logo.png'),
                        height: 180,
                        width: 180),
                    const Align(
                        alignment: Alignment.center,
                        child: Text("Sign Up", style: kHeadingStyle)),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.center,
                      child: Text("It's quick and easy"),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: FormBuilderTextField(
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                          FormBuilderValidators.match(context, r'[a-zA-Z]',
                              errorText: "Name can only be alphabets!"),
                        ]),
                        name: 'name',
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8.0),
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'Full Name',
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
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: FormBuilderTextField(
                        textInputAction: TextInputAction.next,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context),
                          FormBuilderValidators.email(context),
                        ]),
                        name: 'email',
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8.0),
                          prefixIcon: const Icon(Icons.email),
                          hintText: 'Email Address',
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
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: FormBuilderTextField(
                        textInputAction: TextInputAction.done,
                        validator: FormBuilderValidators.required(context),
                        obscureText: isObscure,
                        name: 'password',
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8.0),
                          prefixIcon: const Icon(Icons.lock_open),
                          hintText: 'Enter password',
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
                              size: 20.0,
                            ),
                          ),
                          enabledBorder: kOutlineBorder,
                          focusedBorder: kOutlineBorder,
                          errorBorder: kErrorBorder,
                          focusedErrorBorder: kErrorBorder,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SignUpButton(onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final authCubit = BlocProvider.of<AuthCubit>(context);
                        await authCubit.signUp(
                            formKey.currentState!.fields['name']!.value,
                            formKey.currentState!.fields['password']!.value,
                            formKey.currentState!.fields['email']!.value);
                      }
                    }),
                    const SizedBox(height: 30.0),
                    const Text(
                      "By clicking sign up you are agreeing to our Terms of Services",
                      textAlign: TextAlign.center,
                    )
                  ])))),
    );
  }

  Widget _loading() {
    return const SizedBox(
        child: Center(
      child: CircularProgressIndicator(),
    ));
  }
}

class SignUpButton extends StatelessWidget {
  final Function onPressed;
  const SignUpButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
        onPressed: onPressed,
        child: const Text("SignUp", style: TextStyle(color: Colors.white)));
  }
}
