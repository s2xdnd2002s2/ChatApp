import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/service/isar_service.dart';

import 'package:permission_handler/permission_handler.dart';

import 'home_screen_2/home_screen2.dart';
import 'input_phone_number.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: 'Home Screen',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    ///Hàm initState không thực hiện bất đồng bộ được
    _initialPage();
    super.initState();
  }

  void _initialPage() async {
    await Future.delayed(const Duration(seconds: 2));

    /// Mở Isar service
    final isarService = IsarService();

    ///Lấy về số điện thoại đã lưu trong database
    final phones = await isarService.getAllPhoneNumbers();

    ///Nếu danh sách lấy về không rỗng (có SDT đã đăng nhập) => Vào màn Home
    ///Nếu danh sách trống (Chưa đăng nhập) => Vào màn nhập SDT
    if (phones.isNotEmpty) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HomeScreen2(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InputPhoneNumber(),
          ),
        );
      }
    }
  }

  Future<void> _initApp() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.requestPermission();
      } else {
        await Permission.notification.isDenied.then((value) {
          if (value) {
            Permission.notification.request();
          }
        });
      }

      // await FirebaseMessaging.instance.deleteToken();
      final deviceToken = await FirebaseMessaging.instance.getToken();
      // GlobalData.instance.deviceToken = deviceToken;
      // logger.d('Firebase Device TOKEN:\n$deviceToken');
    });
    // _cubit.checkVersion();
    // await Future.delayed(const Duration(seconds: 1), () => _cubit.checkLogin());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 135,
                    bottom: 42,
                  ),
                  child: Image.asset(
                    'assets/images/img_background.png',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 48,
                  ),
                  child: Text(
                    'Connect easily with your family and friends over countries',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Terms & Privacy Policy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          InkWell(
            onTap: () async {},
            child: Container(
              margin: const EdgeInsets.only(
                top: 18,
                bottom: 20,
                left: 24,
                right: 24,
              ),
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF002ED3),
              ),
              child: const Center(
                child: Text(
                  "Start Messaging",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}