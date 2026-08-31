import 'package:cihcahul_plus/core/services/reactive_store.dart';

/// Lightweight, framework-free translation lookup.
///
/// The active language is read straight from [ReactiveStore] (the same
/// place every other user setting lives), so `L10n.tr(...)` can be called
/// from anywhere — widgets, services, plain Dart — without threading a
/// `BuildContext` around. Widgets pick up a language change because
/// `main.dart` remounts the app shell whenever the "language" variable
/// changes; `L10n.tr` itself is just a synchronous map lookup.
class L10n {
  static const String fallback = 'ro';
  static const List<String> supported = ['ro', 'ru', 'en'];

  static String currentLanguage() {
    final value = ReactiveStore.get('language')?.get();
    return supported.contains(value) ? value as String : fallback;
  }

  static String tr(String key, [Map<String, String>? params]) {
    final entry = _strings[key];
    var value = entry?[currentLanguage()] ?? entry?[fallback] ?? key;
    if (params != null) {
      for (final param in params.entries) {
        value = value.replaceAll('{${param.key}}', param.value);
      }
    }
    return value;
  }

  static const Map<String, Map<String, String>> _strings = {
    'day_monday': {'ro': 'Luni', 'ru': 'Понедельник', 'en': 'Monday'},
    'day_tuesday': {'ro': 'Marti', 'ru': 'Вторник', 'en': 'Tuesday'},
    'day_wednesday': {'ro': 'Miercuri', 'ru': 'Среда', 'en': 'Wednesday'},
    'day_thursday': {'ro': 'Joi', 'ru': 'Четверг', 'en': 'Thursday'},
    'day_friday': {'ro': 'Vineri', 'ru': 'Пятница', 'en': 'Friday'},
    'day_saturday': {'ro': 'Simbata', 'ru': 'Суббота', 'en': 'Saturday'},
    'day_sunday': {'ro': 'Duminica', 'ru': 'Воскресенье', 'en': 'Sunday'},

    'nav_today': {
      'ro': 'Orarul pe azi',
      'ru': 'Сегодня',
      'en': "Today's schedule",
    },
    'nav_week': {'ro': 'Toate zilele', 'ru': 'Все дни', 'en': 'All days'},

    'vacation_notice': {'ro': 'Vacanță', 'ru': 'Каникулы', 'en': 'Vacation'},
    'no_data_found': {
      'ro': 'Datele nu au fost regăsite',
      'ru': 'Данные не найдены',
      'en': 'Data not found',
    },
    'no_lessons_day': {
      'ro': 'Nu sunt lecții...',
      'ru': 'Уроков нет...',
      'en': 'No lessons...',
    },

    'loading_placeholder': {
      'ro': 'Prelucrare...',
      'ru': 'Обработка...',
      'en': 'Processing...',
    },
    'break_label': {'ro': 'Pauza', 'ru': 'Перемена', 'en': 'Break'},

    'gym_hall': {'ro': 'Sala sportiva', 'ru': 'Спортзал', 'en': 'Gym'},
    'classroom_label': {
      'ro': 'Clasa {n}',
      'ru': 'Кабинет {n}',
      'en': 'Room {n}',
    },
    'both_groups': {
      'ro': 'Ambele grupe',
      'ru': 'Обе группы',
      'en': 'Both groups',
    },
    'group_label': {'ro': 'Grupa {n}', 'ru': 'Группа {n}', 'en': 'Group {n}'},

    'notification_title': {
      'ro': '{subject} se incepe peste 5min',
      'ru': '{subject} начинается через 5 мин',
      'en': '{subject} starts in 5 min',
    },
    'notification_body': {
      'ro': 'In classa {group} se va desfasura lectia',
      'ru': 'Урок пройдёт в кабинете {group}',
      'en': 'The lesson will take place in room {group}',
    },

    'settings_title': {'ro': 'Setari', 'ru': 'Настройки', 'en': 'Settings'},

    'section_general': {'ro': 'General', 'ru': 'Общее', 'en': 'General'},
    'section_filters': {'ro': 'Filtre', 'ru': 'Фильтры', 'en': 'Filters'},
    'section_automation': {
      'ro': 'Automatizare',
      'ru': 'Автоматизация',
      'en': 'Automation',
    },
    'section_notifications': {
      'ro': 'Notificari',
      'ru': 'Уведомления',
      'en': 'Notifications',
    },
    'section_additional': {
      'ro': 'Aditional',
      'ru': 'Дополнительно',
      'en': 'Additional',
    },

    'setting_language': {'ro': 'Limba', 'ru': 'Язык', 'en': 'Language'},

    'setting_theme': {'ro': 'Tema', 'ru': 'Тема', 'en': 'Theme'},
    'theme_light': {'ro': 'Deschisa', 'ru': 'Светлая', 'en': 'Light'},
    'theme_dark': {'ro': 'Inchisa', 'ru': 'Тёмная', 'en': 'Dark'},
    'theme_system': {'ro': 'Din sistema', 'ru': 'Системная', 'en': 'System'},

    'setting_show_timetable': {
      'ro': 'Arata graficul',
      'ru': 'Показывать расписание',
      'en': 'Show schedule',
    },
    'role_student': {'ro': 'Elevului', 'ru': 'Ученика', 'en': 'Student'},
    'role_teacher': {'ro': 'Invatatorului', 'ru': 'Учителя', 'en': 'Teacher'},

    'label_i_am': {'ro': 'Sunt', 'ru': 'Я', 'en': 'I am'},
    'selector_choose_name': {
      'ro': 'Alege numele',
      'ru': 'Выберите имя',
      'en': 'Choose the name',
    },
    'setting_am_in_class': {
      'ro': 'Sunt in clasa',
      'ru': 'Я в классе',
      'en': 'I am in class',
    },
    'selector_choose_group': {
      'ro': 'Alege grupa',
      'ru': 'Выберите группу',
      'en': 'Choose the group',
    },
    'setting_show_group': {
      'ro': 'Arata grupa',
      'ru': 'Показывать группу',
      'en': 'Show group',
    },
    'group_all': {'ro': 'Toate', 'ru': 'Все', 'en': 'All'},
    'group_first': {'ro': 'Prima', 'ru': 'Первая', 'en': 'First'},
    'group_second': {'ro': 'Adoua', 'ru': 'Вторая', 'en': 'Second'},
    'lang_track_anglophone': {
      'ro': 'Anglofon',
      'ru': 'Англофон',
      'en': 'Anglophone',
    },
    'lang_track_francophone': {
      'ro': 'Francofon',
      'ru': 'Франкофон',
      'en': 'Francophone',
    },
    'lang_track_none': {
      'ro': 'Nu importa',
      'ru': 'Не важно',
      'en': "Doesn't matter",
    },

    'setting_show_weekend': {
      'ro': 'Arata zilele de odihna',
      'ru': 'Показывать выходные',
      'en': 'Show weekend days',
    },

    'setting_auto_day_switch': {
      'ro': 'Trecerea zilei automat',
      'ru': 'Автоматическая смена дня',
      'en': 'Automatic day switch',
    },
    'setting_auto_day_switch_desc': {
      'ro':
          'Sistemul schimba orarul pe ziua urmatoare in cazul cind orele s-au terminat.',
      'ru':
          'Система переключает расписание на следующий день, когда уроки закончились.',
      'en':
          'The system switches the schedule to the next day once the lessons have ended.',
    },

    'setting_lesson_start_notify': {
      'ro': 'Inceputul lectiilor',
      'ru': 'Начало уроков',
      'en': 'Start of lessons',
    },
    'setting_lesson_start_notify_desc': {
      'ro':
          'Cu 5min inainte de a se incepe lectia, sistemul trimite notificare de amintire.',
      'ru': 'За 5 минут до начала урока система отправляет напоминание.',
      'en':
          '5 minutes before the lesson starts, the system sends a reminder notification.',
    },
    'setting_fast_info_notify': {
      'ro': 'Lectia acum si urmatoarea',
      'ru': 'Текущий и следующий урок',
      'en': 'Current and next lesson',
    },
    'setting_fast_info_notify_desc': {
      'ro':
          'Arata notificarea cu informatia despre lectia de acum si urmatoarea',
      'ru': 'Показывает уведомление с информацией о текущем и следующем уроке',
      'en': 'Shows a notification with info about the current and next lesson',
    },
    'feature_unavailable': {
      'ro':
          'Aceasta functie acum este indisponibila din cauza lucrarilor asupra ei. Cerem scuze pentru incomoditati',
      'ru':
          'Эта функция сейчас недоступна из-за проводимых работ. Приносим извинения за неудобства',
      'en':
          'This feature is currently unavailable due to maintenance work. We apologize for the inconvenience',
    },

    'setting_endpoint_source': {
      'ro': 'Sursa Endpoint',
      'ru': 'Источник Endpoint',
      'en': 'Endpoint source',
    },
    'share_app_qr_label': {
      'ro': 'Distribuie aplicatia prin cod QR',
      'ru': 'Поделиться приложением по QR-коду',
      'en': 'Share the app via QR code',
    },

    'attention_title': {'ro': 'Atentie', 'ru': 'Внимание', 'en': 'Attention'},
    'ok_button': {'ro': 'Ok', 'ru': 'Ок', 'en': 'OK'},

    'search_hint': {
      'ro': 'Introduce textul...',
      'ru': 'Введите текст...',
      'en': 'Enter text...',
    },

    'toggle_on': {'ro': 'On', 'ru': 'Вкл', 'en': 'On'},
    'toggle_off': {'ro': 'Off', 'ru': 'Выкл', 'en': 'Off'},

    'classroom_auto_updated': {
      'ro':
          'Setarea "Sunt in clasa" a fost actualizata automat: {old} -> {new}, deoarece clasa anterioara nu mai exista.',
      'ru':
          'Настройка «Я в классе» была автоматически обновлена: {old} → {new}, так как прежний класс больше не существует.',
      'en':
          'The "I am in class" setting was automatically updated: {old} -> {new}, because the previous class no longer exists.',
    },
    'update_available_title': {
      'ro': 'Actualizare disponibila',
      'ru': 'Доступно обновление',
      'en': 'Update available',
    },
    'update_available_body': {
      'ro': 'Versiunea {version} este gata de instalare.',
      'ru': 'Версия {version} готова к установке.',
      'en': 'Version {version} is ready to install.',
    },
    'update_now_button': {
      'ro': 'Actualizeaza',
      'ru': 'Обновить',
      'en': 'Update',
    },
    'update_later_button': {
      'ro': 'Mai tarziu',
      'ru': 'Позже',
      'en': 'Later',
    },
    'update_downloading': {
      'ro': 'Se descarca actualizarea...',
      'ru': 'Загрузка обновления...',
      'en': 'Downloading update...',
    },
    'update_error': {
      'ro': 'Actualizarea nu a putut fi descarcata. Incercati mai tarziu.',
      'ru': 'Не удалось загрузить обновление. Попробуйте позже.',
      'en': 'The update could not be downloaded. Please try again later.',
    },
    'classroom_not_found': {
      'ro':
          'Clasa salvata ({old}) nu a mai fost gasita. Va rugam alegeti clasa din nou in Setari.',
      'ru':
          'Сохранённый класс ({old}) больше не найден. Пожалуйста, выберите класс заново в настройках.',
      'en':
          'Your saved class ({old}) could not be found anymore. Please pick your class again in Settings.',
    },
  };
}
