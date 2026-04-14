import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomeState();
}

int suhu = 24;
int kelembaban = 60;

class _HomeState extends State<HomePage> {
  TimeOfDay selectedTime = const TimeOfDay(hour: 15, minute: 30);

  Map<String, bool> selectedDays = {
    'Sun': true,
    'Mon': true,
    'Tues': true,
    'Wed': true,
    'Thur': true,
    'Fri': true,
    'Sat': true,
  };

  void _showSettingPopup(String type) {
  int value = type == "Pengaturan Suhu" ? suhu : kelembaban;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              width: 250,
              height: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// JUDUL
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      type == "Pengaturan Suhu" ? "Suhu" : "Kelembaban",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C732E),
                      ),
                    ),
                  ),

                  const Divider(),

                  const SizedBox(height: 10),

                  /// CONTROL (PANAH - NILAI +)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// MINUS
                      GestureDetector(
                        onTap: () {
                          setStateDialog(() {
                            value--;
                          });
                        },
                        child: const Text(
                          "-",
                          style: TextStyle(
                            fontSize: 100,
                            color: Color(0xFF4C732E),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      /// VALUE
                      Text(
                        type == "Pengaturan Suhu"
                            ? "$value°"
                            : "$value%",
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C732E),
                        ),
                      ),

                      const SizedBox(width: 20),

                      /// PLUS
                      GestureDetector(
                        onTap: () {
                          setStateDialog(() {
                            value++;
                          });
                        },
                        child: const Text(
                          "+",
                          style: TextStyle(
                            fontSize: 50,
                            color: Color(0xFF4C732E),
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON (PERSIS HIJAU BULAT)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (type == "Pengaturan Suhu") {
                            suhu = value;
                          } else {
                            kelembaban = value;
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C732E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Set Batas",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            children: [

              /// ================= TOP BAR =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// LOGOUT (outline)
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainPage()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4C732E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Color(0xFF4C732E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      _iconButton('gambar/informasi.png'),
                      const SizedBox(width: 10),
                      _iconButton('gambar/notif.png'),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 35),

              /// ================= TITLE =================
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "halo,\nAgro Squad",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C732E),
                    height: 1.1,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// ================= MAIN CARD =================
              const SizedBox(height: 50),
              Stack(
                clipBehavior: Clip.none,
                children: [

                  /// CARD
                  Container(
                    width: 430,
                    padding: const EdgeInsets.fromLTRB(20, 90, 20, 70),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                      ),
                      boxShadow: [
                        const BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 10,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                    child: Column(
                      children: [

                        /// STATUS MQTT
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Status MQTT ",
                                style: TextStyle(color: Color(0xFF6B8A4D), fontSize: 12),
                              ),
                              TextSpan(
                                text: "Menunggu Data Alat...",
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// SUHU CARD
                        _dataCard("$suhu°", "Pengaturan Suhu"),

                        const SizedBox(height: 16),

                        /// KELEMBABAN
                        _dataCard("$kelembaban%", "Kelembaban"),

                        const SizedBox(height: 25),

                        /// JADWAL
                        const Text(
                          "Jadwal Otomatis",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF4C732E),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: selectedDays.keys.map((day) {
    final isSelected = selectedDays[day]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8), // ⬅️ jarak antar hari
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDays[day] = !isSelected;
          });
        },
        child: Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4C732E)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF4C732E)),
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              day,
              style: const TextStyle(fontSize: 11), // ⬅️ sedikit lebih kecil biar muat
            )
          ],
        ),
      ),
    );
  }).toList(),
),

                        const SizedBox(height: 18),

                        /// TIME
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          width: 300,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Color.fromARGB(255, 63, 121, 19)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4C732E),
                                ),
                              ),
                              GestureDetector(
                                onTap: _selectTime,
                                child: const Icon(Icons.access_time,
                                    color: Color(0xFF4C732E)),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// BUTTON
                        SizedBox(
                          width: 180,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C732E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
child: const Text(
  "Set Jadwal",
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
),
                          ),
                        )
                      ],
                    ),
                  ),

Positioned(
  top: -55,
  left: 0,
  right: 0,
  child: SizedBox(
    height: 100,
    child: Stack(
      alignment: Alignment.center,
      children: [

        /// TEKS KIRI (SUHU)
        Positioned(
          top: 65,
          left: 30,
          child: Column(
            children: const [
              Text(
                "-- °",
                style: TextStyle(
                  color: Color(0xFF4C732E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Suhu Saat Ini",
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B8A4D),
                ),
              ),
            ],
          ),
        ),

        /// TEKS KANAN (KELEMBABAN)
        Positioned(
          top: 65,
          right: 30,
          child: Column(
            children: const [
              Text(
                "-- %",
                style: TextStyle(
                  color: Color(0xFF4C732E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Kelembaban Saat Ini",
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B8A4D),
                ),
              ),
            ],
          ),
        ),

        /// LOGO TENGAH (TETAP)
Container(
  width: 90,
  height: 90,
  decoration: BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.25),
        blurRadius: 10,
        offset: Offset(0, 1),
      )
    ],
  ),
  child: ClipOval( // ⬅️ biar area klik ikut lingkaran
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Image.asset('gambar/logo.png'),
        ),
      ),
    ),
  ),
),
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
    );
  }

  /// ================= WIDGET REUSABLE =================

  Widget _iconButton(String path) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    },
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          path,
          width: 18, // ⬅️ UBAH DI SINI (ukuran icon)
          height: 18,
        ),
      ),
    ),
  );
}

  Widget _dataCard(String value, String label) {
  return Container(
    width: 300,
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 255, 255, 255),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.25),
          blurRadius: 10,
        )
      ],
    ),
    child: Stack(
  alignment: Alignment.topRight, // ⬅️ INI KUNCI NYA
  children: [

        /// ICON SETTING (pojok kanan atas)
        GestureDetector(
  onTap: () {
    _showSettingPopup(label);
  },
  child: const Icon(
    Icons.settings,
    size: 20,
    color: Color(0xFF4C732E),
  ),
),

        /// ISI CARD
        SizedBox(
  width: double.infinity, // ⬅️ bikin full lebar
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C732E),
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF4C732E)),
            )
          ],
        ),
        ),
      ],
    ),
  );
}
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        backgroundColor: const Color(0xFF4C732E),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4C732E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Masuk ke Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
