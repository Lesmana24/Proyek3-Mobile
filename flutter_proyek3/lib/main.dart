import 'package:flutter/material.dart';
import 'daftar.dart';
import 'masuk.dart';

void main() {
  runApp(const MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Plants House',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 32, 54, 15),
        scaffoldBackgroundColor: Colors.white,
      ), //gen
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4C732E);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Smart',
                  style: TextStyle(
                    color: Color(0xFF4C4C4C),
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Plants House',
                  style: TextStyle(
                    color: Color(0xFF4C732E),
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                Center(
                  child: Container(
                    width: 320,
                    height: 340,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset('gambar/img1.png', fit: BoxFit.cover),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MasukPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DaftarPage(),
                              ),
                            );
                          },

                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primaryGreen,
                              width: 2,
                            ),
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 18,
                              color: primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
