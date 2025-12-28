import 'package:flutter/material.dart';
import 'services/api_serv.dart';
import 'screens/homepage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      home: token == null
          ? LoginScreen(
              onLogin: (t) {
                setState(() {
                  token = t;
                });
              },
            )
          : HomePage(
              onLogout: () {
                setState(() {
                  token = null;
                });
              },
            ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Function(String) onLogin;

  LoginScreen({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "IP Geolocation System",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final token = await ApiService.login(
                    emailController.text,
                    passwordController.text,
                  );

                  if (token != null) {
                    onLogin(token);
                  }
                },

                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
