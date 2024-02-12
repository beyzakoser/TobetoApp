import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/blocs/auth_bloc/auth_bloc.dart';
import 'package:flutter_application_1/api/blocs/auth_bloc/auth_event.dart';
import 'package:flutter_application_1/api/blocs/auth_bloc/auth_state.dart';
import 'package:flutter_application_1/constants/constant_image.dart';
import 'package:flutter_application_1/constants/constant_padding.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/sign_up_page.dart';
import 'package:flutter_application_1/widgets/sign_in_sign_up_page/textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<SignInPage> {
  late String logoAsset;
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    logoAsset = getLogo(brightness);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(backgorundImage), fit: BoxFit.fill),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
                    } else if (state is AuthError) {}
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(top: 15),
                        child: Image.asset(
                          logoAsset,
                          width: 200,
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 15),
                          child: SignTextField(
                            isPassword: false,
                            controller: nameController,
                            labelText: "E-posta adresi",
                            icon: const Icon(Icons.person),
                          )),
                      Container(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 15),
                          child: SignTextField(
                              isPassword: true,
                              controller: passwordController,
                              labelText: "Parola",
                              icon: const Icon(Icons.lock))),
                      Container(
                        padding:
                            const EdgeInsets.only(left: 25, right: 25, top: 15),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondary, // Buton rengini tema rengi olarak ayarla
                              minimumSize: Size(screenWidth * 0.8,
                                  50), // Buton boyutunu ekran genişliğine göre ayarla
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              )),
                          child: const Text('Kayıt Ol',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthSignIn(
                                eMail: nameController.text,
                                password: passwordController.text));
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpPage()));
                          },
                          child: const Text("Giriş Yap")),
                      Padding(padding: paddingMedium),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
