import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  // Variables pour stocker les données récupérées de l'API
  Map<String, dynamic>? data;
  List<dynamic>? dailyTemperatures;
  List<dynamic>? dailyDates;
  List<dynamic>? dailyWeatherCodes;

  @override
  void initState() {
    super.initState();
    fetchData(); // Charger les données lors de l'initialisation de l'écran
  }

  // Fonction pour récupérer les données météorologiques via une requête HTTP GET
  void fetchData() async {
    Uri url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=34.0531&longitude=-6.7985&daily=temperature_2m_max,weathercode');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // Si la réponse est réussie, parsez les données JSON
      setState(() {
        data = jsonDecode(response.body);
        dailyTemperatures = data!['daily']['temperature_2m_max'];
        dailyDates = data!['daily']['time'];
        dailyWeatherCodes = data!['daily']['weathercode'];
      });
    } else {
      print('Error: ${response.statusCode}'); // Affiche une erreur si la requête échoue
    }
  }

  // Retourne une description textuelle en fonction du code météo
  String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clair';
      case 1:
      case 2:
      case 3:
        return 'Partiellement nuageux';
      case 45:
      case 48:
        return 'Brouillard';
      case 51:
      case 53:
      case 55:
        return 'Bruine';
      case 56:
      case 57:
        return 'Bruine verglaçante';
      case 61:
      case 63:
      case 65:
        return 'Pluie';
      case 66:
      case 67:
        return 'Pluie verglaçante';
      case 71:
      case 73:
      case 75:
        return 'Neige';
      case 77:
        return 'Grains de neige';
      case 80:
      case 81:
      case 82:
        return 'Averses';
      case 85:
      case 86:
        return 'Averses de neige';
      case 95:
        return 'Orage';
      case 96:
      case 99:
        return 'Orage avec grêle';
      default:
        return 'Inconnu';
    }
  }

  // Fonction pour revenir à l'écran précédent
  void navigateBackFunction() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data == null
      // Affichage d'un indicateur de chargement si les données ne sont pas encore disponibles
          ? Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF64B5F6),
              Color(0xFF1E88E5),
              Color(0xFF1565C0),
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            height: 50.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      )
      // Affichage des données météorologiques
          : Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF64B5F6),
              Color(0xFF1E88E5),
              Color(0xFF1565C0),
            ],
          ),
        ),
        child: Padding(
          padding:
          const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne supérieure avec le bouton "Retour" et une icône
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: navigateBackFunction,
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          height: 30.0,
                          width: 30.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_left_outlined,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Retour',
                          style: GoogleFonts.openSans(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/heavycloud.png"),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFFFFFFFF),
                      size: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Cette semaine',
                        style: GoogleFonts.openSans(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Liste des données journalières
              Expanded(
                child: ListView.builder(
                  itemCount: dailyDates?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.only(
                          bottom: 12.0, top: 5.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 0.4,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEE').format(
                                DateTime.parse(dailyDates![index])),
                            style: GoogleFonts.openSans(
                              fontSize: 14.0,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                          Text(
                            getWeatherDescription(
                                dailyWeatherCodes![index]),
                            style: GoogleFonts.openSans(
                              fontSize: 14.0,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                          Text(
                            '${dailyTemperatures![index].toString().substring(0, 2)}°C',
                            style: GoogleFonts.openSans(
                              fontSize: 65.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
