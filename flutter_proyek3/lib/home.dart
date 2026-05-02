import 'package:flutter/material.dart';
import 'main.dart';
import 'cek_ai.dart';
import 'informasi.dart';
import 'notifikasi.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

// Global variable (sementara sebelum pakai backend Laravel)
int suhu = 24;
int kelembaban = 60;
int durasiKritis = 3;
int durasiJadwal = 6;

class _HomeState extends State<HomePage> {
  // 1. PINDAHAN: Variabel dinamis ditaruh di dalam State
  String suhuSaatIni = "--";
  String lembabSaatIni = "--";
  String statusMqtt = "Menghubungkan...";

  late MqttServerClient client;

  TimeOfDay selectedTime = const TimeOfDay(hour: 15, minute: 30);
  Map<String, bool> selectedDays = {
    'Min': false,
    'Sen': false,
    'Sel': false,
    'Rab': false,
    'Kam': false,
    'Jum': false,
    'Sab': false,
  };

  @override
  void initState() {
    super.initState();
    // 2. Setup Client MQTT dengan ID unik
    client = MqttServerClient(
      'broker.emqx.io',
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    setupMqtt(); // Panggil saat layar pertama dibuka
    fetchSettings(); // Ambil data setting dari database
  }

  Future<void> setupMqtt() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onDisconnected = () {
      setState(() => statusMqtt = "Terputus dari Broker");
    };

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('MQTT Client Error: $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('MQTT Socket Error: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      setState(() => statusMqtt = "Terhubung ke Server");

      // 3. Subscribe ke Topik ESP32 lu
      client.subscribe('AgroSquad/monitoring/suhu', MqttQos.atLeastOnce);
      client.subscribe('AgroSquad/monitoring/lembab', MqttQos.atLeastOnce);

      // 4. Dengerin kalau ada data masuk
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        // Update UI pakai setState biar angkanya berubah otomatis
        setState(() {
          if (c[0].topic == 'AgroSquad/monitoring/suhu') {
            suhuSaatIni = pt;
          } else if (c[0].topic == 'AgroSquad/monitoring/lembab') {
            lembabSaatIni = pt;
          }
        });
      });
    } else {
      setState(() => statusMqtt = "Gagal Konek");
      client.disconnect();
    }
  }

  void _showSettingPopup(String type) {
    int value;
    String unit;
    if (type == "Pengaturan Suhu") {
      value = suhu;
      unit = "°";
    } else if (type == "Kelembapan") {
      value = kelembaban;
      unit = "%";
    } else if (type == "Durasi Kritis") {
      value = durasiKritis;
      unit = "s";
    } else {
      value = durasiJadwal;
      unit = "s";
    }

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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C732E),
                        ),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              if (value > 0) value--;
                            });
                          },
                          child: const Text(
                            "-",
                            style: TextStyle(
                              fontSize: 80,
                              color: Color(0xFF4C732E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "$value$unit",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C732E),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              value++;
                            });
                          },
                          child: const Text(
                            "+",
                            style: TextStyle(
                              fontSize: 48,
                              color: Color(0xFF4C732E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (type == "Pengaturan Suhu") {
                              suhu = value;
                            } else if (type == "Kelembapan") {
                              kelembaban = value;
                            } else if (type == "Durasi Kritis") {
                              durasiKritis = value;
                            } else {
                              durasiJadwal = value;
                            }
                          });

                          // Mapping type → dbKey & mqttTopic
                          final map = {
                            "Pengaturan Suhu": {
                              "dbKey": "batas_suhu",
                              "topic": "AgroSquad/kontrol/batas_suhu",
                            },
                            "Kelembapan": {
                              "dbKey": "batas_lembab",
                              "topic": "AgroSquad/kontrol/batas_lembab",
                            },
                            "Durasi Kritis": {
                              "dbKey": "durasi_suhu",
                              "topic": "AgroSquad/kontrol/durasi_suhu",
                            },
                            "Durasi Jadwal Otomatis": {
                              "dbKey": "durasi_jadwal",
                              "topic": "AgroSquad/kontrol/durasi_jadwal",
                            },
                          };

                          final dbKey = map[type]?['dbKey'] ?? '';
                          final mqttTopic = map[type]?['topic'] ?? '';

                          // Kirim ke Laravel & ESP32
                          if (dbKey.isNotEmpty) {
                            simpanKeDatabase(dbKey, value.toString());
                          }
                          if (mqttTopic.isNotEmpty) {
                            publishMqtt(mqttTopic, value.toString());
                          }

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C732E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Set Nilai",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Kirim data setting ke backend Laravel via HTTP POST dengan Sanctum token.
  Future<void> simpanKeDatabase(String key, String value) async {
    // 1. Ambil token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // 2. Hentikan jika token tidak ditemukan
    if (token == null) {
      print('[DB] Token tidak ditemukan, user belum login');
      return;
    }

    // 3. Kirim POST ke endpoint API Laravel
    const url = 'https://unjoyfully-decrepit-dian.ngrok-free.dev/api/update-setting';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'key': key, 'value': value}),
      );
      // 4. Debug log
      print('[DB] Status : ${response.statusCode}');
      print('[DB] Body   : ${response.body}');
    } catch (e) {
      print('[DB] Error  : $e');
    }
  }

  /// Publish pesan ke broker MQTT pada topik tertentu.
  void publishMqtt(String topic, String message) {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      print('[MQTT] Tidak terkoneksi, pesan gagal dikirim');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('[MQTT] Publish → $topic : $message');
  }

  /// Ambil semua setting dari database Laravel saat halaman dimuat.
  Future<void> fetchSettings() async {
    // 1. Ambil token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('[FETCH] Token tidak ditemukan, user belum login');
      return;
    }

    // 2. HTTP GET ke endpoint /api/settings
    const url = 'https://unjoyfully-decrepit-dian.ngrok-free.dev/api/settings';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[FETCH] Status: ${response.statusCode}');
      print('[FETCH] Body  : ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final data = json['data'] as Map<String, dynamic>;

          setState(() {
            // --- Integer settings ---
            if (data['batas_suhu'] != null) {
              suhu = int.tryParse(data['batas_suhu'].toString()) ?? suhu;
            }
            if (data['batas_lembab'] != null) {
              kelembaban = int.tryParse(data['batas_lembab'].toString()) ?? kelembaban;
            }
            if (data['durasi_suhu'] != null) {
              durasiKritis = int.tryParse(data['durasi_suhu'].toString()) ?? durasiKritis;
            }
            if (data['durasi_jadwal'] != null) {
              durasiJadwal = int.tryParse(data['durasi_jadwal'].toString()) ?? durasiJadwal;
            }

            // --- Jadwal Jam ("HH:mm" → TimeOfDay) ---
            if (data['jadwal_jam'] != null) {
              final parts = data['jadwal_jam'].toString().split(':');
              if (parts.length == 2) {
                selectedTime = TimeOfDay(
                  hour: int.tryParse(parts[0]) ?? selectedTime.hour,
                  minute: int.tryParse(parts[1]) ?? selectedTime.minute,
                );
              }
            }

            // --- Jadwal Hari ("1,0,1,0,0,0,0" → Map boolean) ---
            if (data['jadwal_hari'] != null) {
              final bits = data['jadwal_hari'].toString().split(',');
              final keys = selectedDays.keys.toList(); // Min, Sen, ... Sab
              for (int i = 0; i < bits.length && i < keys.length; i++) {
                selectedDays[keys[i]] = bits[i] == '1';
              }
            }
          });
        }
      }
    } catch (e) {
      print('[FETCH] Error : $e');
    }
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
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
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
                  ),
                ],
              ),
              const SizedBox(height: 35),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Halo,\nAgro Squad",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C732E),
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 50),
              Stack(
                clipBehavior: Clip.none,
                children: [
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
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 5. STATUS MQTT — pill container di tengah
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "Status MQTT ",
                                    style: TextStyle(
                                      color: Color(0xFF6B8A4D),
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextSpan(
                                    text: statusMqtt,
                                    style: TextStyle(
                                      color: statusMqtt.contains("Terhubung")
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Batas Ambang Sensor",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF4C732E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _settingCard(
                                value: "$suhu°",
                                label: "Suhu",
                                type: "Pengaturan Suhu",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _settingCard(
                                value: "$kelembaban%",
                                label: "Kelembapan",
                                type: "Kelembapan",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Durasi Penyiraman",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF4C732E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _settingCard(
                                value: "${durasiKritis}s",
                                label: "Durasi Kritis",
                                type: "Durasi Kritis",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _settingCard(
                                value: "${durasiJadwal}s",
                                label: "Durasi Jadwal Otomatis",
                                type: "Durasi Jadwal Otomatis",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Jadwal Otomatis",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF4C732E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: selectedDays.keys.map((day) {
                            final isSelected = selectedDays[day]!;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDays[day] = !isSelected;
                                });
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFF4C732E),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Color(0xFF4C732E),
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    day,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF4C732E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFF4C732E)),
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
                                child: const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF4C732E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: 180,
                          child: ElevatedButton(
                            onPressed: () {
                              // 1. Format waktu HH:mm
                              final stringJam =
                                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                              // 2. Konversi hari ke "1,0,1,0,0,0,0" (Min→Sab)
                              final stringHari = selectedDays.values
                                  .map((v) => v ? '1' : '0')
                                  .join(',');

                              // 3. Gabung payload: "1,0,1,0,0,0,0#07:00"
                              final payloadMqtt = '$stringHari#$stringJam';

                              // 4. Kirim ke MQTT
                              publishMqtt(
                                'AgroSquad/kontrol/jadwal_mingguan',
                                payloadMqtt,
                              );

                              // 5. Simpan ke database (2 baris terpisah)
                              simpanKeDatabase('jadwal_hari', stringHari);
                              simpanKeDatabase('jadwal_jam', stringJam);

                              // 6. Feedback ke user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Jadwal berhasil disimpan!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
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
                        ),
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
                          Positioned(
                            top: 65,
                            left: 30,
                            child: Column(
                              children: [
                                // 6. BINDING DATA SUHU REALTIME DI SINI
                                Text(
                                  "$suhuSaatIni °",
                                  style: const TextStyle(
                                    color: Color(0xFF4C732E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Suhu Saat Ini",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B8A4D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 65,
                            right: 30,
                            child: Column(
                              children: [
                                // 7. BINDING DATA KELEMBAPAN REALTIME DI SINI
                                Text(
                                  "$lembabSaatIni %",
                                  style: const TextStyle(
                                    color: Color(0xFF4C732E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Kelembaban Saat Ini",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B8A4D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CekAIPage(),
                                      ),
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

  Widget _iconButton(String path) {
    return GestureDetector(
      onTap: () {
        if (path.contains('informasi')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InformasiPage()),
          );
        } else if (path.contains('notif')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotifikasiPage()),
          );
        }
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(child: Image.asset(path, width: 18, height: 18)),
      ),
    );
  }

  Widget _settingCard({
    required String value,
    required String label,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showSettingPopup(type),
              child: const Icon(
                Icons.settings,
                size: 18,
                color: Color(0xFF4C732E),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C732E),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B8A4D)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
