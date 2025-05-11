// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get app_title => 'FilmRandomizer';

  @override
  String get missing_title => 'Название отсутствует!';

  @override
  String get error_occurred => 'Произошла ошибка!';

  @override
  String get film_created_error => 'Произошла ошибка во время добавления фильма!';

  @override
  String get film_updated_error => 'Произошла ошибка во время обновления фильма!';

  @override
  String get film_delete_error => 'Произошла ошибка во время удаления фильма!';

  @override
  String get username_required => 'Ник обязателен!';

  @override
  String get password_required => 'Пароль обязателен!';

  @override
  String get username_short => 'Ник должен быт не короче 4 символов';

  @override
  String get password_short => 'Пароль должен быт не короче 4 символов';

  @override
  String get login_error => 'Не удалось выполнить вход, проверь ник и пароль!';

  @override
  String get films_missing => 'Фильмов не найдено! Добавь несколько для начала.';

  @override
  String get film_created_successfully => 'Фильм создан успешно!';

  @override
  String get film_updated_successfully => 'Фильм обновлен успешно!';

  @override
  String get film_delete_success => 'Фильм удалён успешно!';

  @override
  String get film_marked_as_watched => 'Фильм помечен как просмотренный!';

  @override
  String get delete_confirmation_title => 'Точно нужно удалить?';

  @override
  String get title => 'Название';

  @override
  String get select_categories => 'Выбрать категории';

  @override
  String get categories => 'Категории';

  @override
  String get select_genres => 'Выбрать жанры';

  @override
  String get genres => 'Жанры';

  @override
  String get is_watched => 'Просмотрено';

  @override
  String get submit => 'Сохранить';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get ok => 'Ок';

  @override
  String get register_action => 'Зарегистрироваться';

  @override
  String get login_action => 'Войти';

  @override
  String get show_watched => 'Показывать просмотренные фильмы';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Оформление';

  @override
  String get app_version => 'Версия приложения';

  @override
  String get username => 'Ник';

  @override
  String get password => 'Пароль';

  @override
  String get include_watched => 'Включить просмотренные фильмы';

  @override
  String get switch_include_mode => 'Переключить включение/исключение';

  @override
  String get goto_register => 'Нет аккаунта? Создай';

  @override
  String get goto_login => 'Есть аккаунт? Перейди на вход';

  @override
  String get login_page => 'Вход';

  @override
  String get register_page => 'Регистрация';

  @override
  String get settings_page => 'Настройки';

  @override
  String get edit_page => 'Редактирование фильма';

  @override
  String get add_page => 'Добавление фильма';

  @override
  String get randomizer_page => 'Рандомайзер';

  @override
  String get confirmation => 'Подтверждение';

  @override
  String get category_series => 'Сериал';

  @override
  String get category_animation => 'Анимация';

  @override
  String get category_cartoon => 'Мультфильм';

  @override
  String get category_film => 'Кино';

  @override
  String get category_anime => 'Аниме';

  @override
  String get genre_action => 'Боевик';

  @override
  String get genre_adventure => 'Приключение';

  @override
  String get genre_comedy => 'Комедия';

  @override
  String get genre_drama => 'Драма';

  @override
  String get genre_thriller => 'Триллер';

  @override
  String get genre_documentary => 'Документальный';

  @override
  String get genre_musical => 'Мюзикл';

  @override
  String get genre_romance => 'Романтика';

  @override
  String get genre_scifi => 'Научпоп';

  @override
  String get genre_crime => 'Криминал';

  @override
  String get genre_fantasy => 'Фэнтези';

  @override
  String get genre_fiction => 'Фантастика';

  @override
  String get genre_detective => 'Детектив';
}
