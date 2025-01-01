import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Week_Screen.dart';

// Widget principal de l'application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// État associé à HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  // Variables pour stocker les données récupérées
  Map<String, dynamic>? data;
  List<dynamic>? hourlyTimes;
  List<dynamic>? hourlyTemperatures;
  List<dynamic>? hourlyHumidities;
  String? timezone;
  String? greeting; // Message de salutation dynamique
  String? formattedDate; // Date formatée
  String? formattedTime; // Heure formatée

  // États pour gérer le chargement et les erreurs
  bool isLoading = true;
  bool hasError = false;

  // Initialisation de l'état
  @override
  void initState() {
    super.initState();
    fetchData(); // Appelle la fonction pour récupérer les données météo
  }

  // Fonction pour récupérer les données météo depuis l'API
  Future<void> fetchData() async {
    try {
      // URL de l'API avec les paramètres de latitude, longitude, etc.
      Uri url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=34.0531&longitude=-6.7985&timezone=auto&current_weather=true&hourly=temperature_2m,relative_humidity_2m');

      // Effectue une requête HTTP GET
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Si la requête réussit, on met à jour l'état avec les données récupérées
        setState(() {
          data = jsonDecode(response.body); // Décodage du JSON
          hourlyTimes = data!['hourly']['time'].sublist(0, 24); // Heures des prévisions
          hourlyTemperatures = data!['hourly']['temperature_2m'].sublist(0, 24); // Températures horaires
          hourlyHumidities = data!['hourly']['relative_humidity_2m'].sublist(0, 24); // Humidité horaire
          timezone = data!['timezone']; // Fuseau horaire

          // Détermine le message de salutation selon l'heure actuelle
          DateTime currentTime = DateTime.parse(data!['current_weather']['time']);
          int currentHour = currentTime.hour;
          if (currentHour < 12) {
            greeting = 'Bonjour';
          } else if (currentHour < 17) {
            greeting = 'Bon après-midi';
          } else {
            greeting = 'Bonsoir';
          }

          // Formatte la date et l'heure
          formattedDate = DateFormat('EEEE d MMM').format(currentTime);
          formattedTime = DateFormat('h:mm a').format(currentTime);
          isLoading = false; // Arrête l'état de chargement
        });
      } else {
        throw Exception('Échec de la récupération des données'); // Gère les erreurs
      }
    } catch (e) {
      // Si une erreur survient, on met à jour l'état pour afficher un message d'erreur
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Widget pour un texte avec effet de dégradé
  Widget gradientText(String text, double fontSize, FontWeight fontWeight) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF64B5F6), Color(0xFF90CAF9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construction de l'interface utilisateur
    return Scaffold(
      body: isLoading
          ? Center(
        // Affiche un indicateur de chargement pendant la récupération des données
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
      )
          : hasError
          ? Center(
        // Affiche un message d'erreur en cas de problème
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger les données météo.\nVeuillez vérifier votre connexion.',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchData, // Bouton pour réessayer
              child: const Text('Réessayer'),
            )
          ],
        ),
      )
          : Container(
        // Interface principale avec un dégradé en arrière-plan
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF64B5F6),
              const Color(0xFF1E88E5).withOpacity(0.8),
              const Color(0xFF1565C0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Affiche le fuseau horaire et le message de salutation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.openSans(),
                      children: [
                        TextSpan(
                          text: '$timezone\n',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        TextSpan(
                          text: greeting,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigue vers l'écran des prévisions hebdomadaires
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WeekScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white70,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Image représentant la météo actuelle
              Image.asset(
                'assets/images/clear.png', // Image dynamique selon les données météo
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              // Affiche la température actuelle, la date et l'heure
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.openSans(),
                  children: [
                    TextSpan(
                      text: '${data!['current_weather']['temperature'].toString()}°C\n',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: '$formattedDate | $formattedTime',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              gradientText('Prévisions horaires', 22, FontWeight.bold),
              const SizedBox(height: 16),
              // Liste des prévisions horaires
              Expanded(
                child: ListView.builder(
                  itemCount: hourlyTimes?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('h a').format(DateTime.parse(hourlyTimes![index])),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${hourlyTemperatures![index]}°C',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
