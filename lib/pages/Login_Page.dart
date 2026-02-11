import 'package:daily_drop/pages/Home_Page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_drop/includes/Common_Styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: Lottie.asset(
                'assets/lotties/login_page_bg.json',
                fit: BoxFit.cover,
                repeat: true,
                reverse: true,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DailyDrop',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Lottie.asset(
                    'assets/lotties/calendar_woman.json',
                    height: 150,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Share your daily thoughts & moments',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    style: CommonStyles.primaryButtonStyle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.g_mobiledata_outlined,
                          color: Colors.black,
                          size: 35.0,
                        ),
                        const SizedBox(width: 8),
                        Text('Login with Google'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: CommonStyles.primaryButtonStyle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email, color: Colors.black, size: 24.0),
                        const SizedBox(width: 8),
                        Text('Login with Email'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'By continuing, you agree to our Terms & Privacy Policy',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
