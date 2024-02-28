import 'package:flutter/material.dart';
import 'package:chatappf/components/my_button.dart';
// import 'package:chatappf/components/my_text_field.dart';
import 'package:chatappf/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isloading = false;
  // sign in user
  signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      // get the auth service
      setState(() {
        isloading = true;
      });
      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        await authService.signInWithEmailandPassword(
          _emailController.text,
          _passwordController.text,
        );
        setState(() {
          isloading = false;
        });
      } catch (e) {
        // setState(() {
        //   isloading = false;
        // });
        // ignore: use_build_context_synchronously
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString(),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade500, Colors.green.shade700],
                    ),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40)),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white, width: 5)),
                      child: const Icon(
                        Icons.done,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),
                    //welcom back message

                    const Text(
                      "CONNEXION A SIR-TechApp",
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 35),
                    //email textfield
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            onFieldSubmitted: (e) {
                              _formKey.currentState?.validate();
                            },
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'Veuillez entrer une adresse e-mail valide.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 50.0),
                          TextFormField(
                            onFieldSubmitted: (e) {
                              _formKey.currentState?.validate();
                            },
                            controller: _passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              labelText: 'Mot de passe',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (isloading) CircularProgressIndicator(),
                    const SizedBox(height: 30),
                    // sign in button
                    MyButton(
                      onTap: signIn,
                      text: "SE CONNECTER",
                    ),

                    const SizedBox(height: 60),

                    // not a nomber register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous êtes pas membre ?",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Inscrive-vous',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
