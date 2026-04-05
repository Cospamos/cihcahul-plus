class Converter {
  static final List<String> days = ["Luni", "Marti", "Miercuri", "Joi", "Vineri", "Simbata", "Duminica"];

  static String iTDay(int idx) {
    return days[idx];
  }

  static List<String> _getTimeIntervalParts(String timeInterval) {
    return timeInterval.split("-");
  }

  static List<Duration> stringToListDuration(String timeInterval) {
    List<Duration> startEndTime = [];

    List<String> time = _getTimeIntervalParts(timeInterval);

    List<String> stringStartTime = time[0].split(":");
    List<String> stringEndTime = time[1].split(":");
    
    Duration startTime = Duration(
      hours: int.parse(stringStartTime[0]), 
      minutes: int.parse(stringStartTime[1])
    );
    startEndTime.add(startTime);

    Duration endTime = Duration(
      hours: int.parse(stringEndTime[0]),
      minutes: int.parse(stringEndTime[1]),
    );
    startEndTime.add(endTime);

    return startEndTime;
  }

  static String subjectToAbbreviation(String subject) {
    subject = subject.replaceAll("(1)", "");
    // if (subject.contains("SQL")) return "SQL";
    // if (subject.contains("Programare")) return "Programare";
    if (subject.contains("Practici Contabile")) return "Practici Contabile";
    if (subject.contains("Tehnologii Informationale")) return "Tehnologii Informationale";
    if (subject.contains("Servicii electronice")) return "Tehnologii Informationale";
    if (subject.contains("Literatura pentru Copii")) return "Literatura pentru Copii";
    if (subject.contains("Practica pedagogică")) return "Practica pedagodică";
    if (subject.contains("Utilizarea Instrumentelor Software")) return "Utilizarea Instrumentelor Software";
    if (subject.contains("Limba Straina") && subject.contains("TIC")) return "Limba Straina in TIC";
    if (subject.contains("Utilizarea Sistemelor de Operare in Retea")) return "Utilizarea OS in Retea";
    if (subject.contains("Asistenta in Managementul Proiectelor Software")) return "Asistenta in PM Software";
    if (subject.contains("Testarea Depanarea")) return subject.replaceAll("Testarea Depanarea", "Debuging");
    if (subject.contains("Contabilitatea") && subject.contains("exploatare")) return "Contabilitate de Exploatare";
    if (subject.contains("Dezvoltarea") && subject.contains("Mobile")) return "Dezvoltarea Aplicatiilor Mobile";
    if (subject.contains("Terapii individuale si Interventii in Caz de Criza")) return "Terapie și Intervenții de Criza";
    if (subject.contains("Metode si Tehnici ale Asistentei Sociale")) return "Metode și Tehnici Sociale";
    if (subject.contains("Asistența socială")) return "Asistența socială";
    if (subject.contains("Microbiologie")) return "Microbiologie";
    if (subject.contains("Didactica educației pentru limbaj și comunicare")) return "Limbaj și Comunicare in Didactica";
    if (subject.contains("Didactica") && subject.contains("Matematica")) return "Didactica Matematicii Elementare";
    if (subject.contains("Administrarea Retelelor")) return "Administrarea Retelelor";
    if (subject.contains("Decizii") && subject.contains("Viata")) return "Mod de Viata Sanatos";  
    if (subject.contains("Structura") && subject.contains("Calculatoarelor")) return "Structura Calculatoarelor";  
    if (subject.contains("comunicarea profesională")) return "Comunicarea Profisionala";
    if (subject.contains("agricultura ecologică")) return "Agricultura Ecologica";
    if (subject.contains("Tehnologii") && subject.contains("mediu")) return "Tehnologii de Mediu";
    if (subject.contains("Protecția mediului")) return "Protecția mediului";
    if (subject.contains("Securitatea ecologică")) return "Securitatea ecologiă";
    if (subject.contains("Tehnologii") && subject.contains("Mediului")) return "Tehnologii de Control al Mediului";
    if (subject.contains("Dezvoltarea comunitară")) return "Dezvoltarea comunitară";
    if (subject.contains("Strategii") && subject.contains("Socio-Profesionala")) return "Incluziune Socio-Profesională";
    if (subject.contains("analiza datelor statitstice")) return "Statistică Aplicată";
    if (subject.contains("evaluare statistică")) return "Evaluare Statistică Socială";
    if (subject.contains("Studierea naturii")) return "Studierea naturii";
    if (subject.contains("Anatomia fiziologia")) return "Anatomia si fiziologia";
    if (subject.contains("Client-side")) return "Programare Client-side Web";
    return subject;
  }
}