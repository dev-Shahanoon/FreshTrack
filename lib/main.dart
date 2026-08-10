import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/expiry_checker.dart';
import 'screens/splash_screen.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  await NotificationService.initialize();


  await ExpiryChecker.checkExpiry();


  runApp(const FreshTrackApp());

}






class FreshTrackApp extends StatelessWidget {

  const FreshTrackApp({super.key});



  @override
  Widget build(BuildContext context) {


    return MaterialApp(


      debugShowCheckedModeBanner:false,


      title:"FreshTrack",




      themeMode:
      ThemeMode.system,





      // LIGHT THEME

      theme:ThemeData(


        brightness:
        Brightness.light,


        colorScheme:

        ColorScheme.fromSeed(

          seedColor:
          Colors.green,

        ),


        scaffoldBackgroundColor:

        const Color(0xffF5F7FA),



        appBarTheme:

        const AppBarTheme(

          backgroundColor:
          Colors.green,

          foregroundColor:
          Colors.white,

          elevation:0,

        ),



        cardTheme: CardThemeData(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  margin: const EdgeInsets.all(8),
),



        useMaterial3:true,


      ),







      // DARK THEME

      darkTheme:ThemeData(


        brightness:
        Brightness.dark,



        colorScheme:

        ColorScheme.fromSeed(

          seedColor:
          Colors.green,


          brightness:
          Brightness.dark,

        ),




        scaffoldBackgroundColor:

        const Color(0xff121212),





        appBarTheme:

        const AppBarTheme(

          backgroundColor:
          Color(0xff121212),

          foregroundColor:
          Colors.white,

          elevation:0,

        ),






        cardTheme: CardThemeData(
  color: const Color(0xff1E1E1E),
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  margin: const EdgeInsets.all(8),
),



        useMaterial3:true,


      ),





      home:
      const SplashScreen(),


    );


  }


}