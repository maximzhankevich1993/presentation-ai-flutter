class AppStrings {
  static AppStrings? _current;
  
  static AppStrings get current {
    _current ??= AppStrings();
    return _current!;
  }
  
  static void setLanguage(String locale) {
    if (locale == 'en') {
      _current = AppStringsEn();
    } else {
      _current = AppStrings();
    }
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ОБЩИЕ
  // ═══════════════════════════════════════════════════════════════
  String get appTitle => 'Презентатор ИИ';
  String get login => 'Войти';
  String get register => 'Зарегистрироваться';
  String get logout => 'Выйти';
  String get cancel => 'Отмена';
  String get later => 'Позже';
  String get back => 'Назад';
  String get save => 'Сохранить';
  String get close => 'Закрыть';
  String get create => 'Создать';
  String get generate => 'Сгенерировать';
  String get select => 'Выбрать';
  String get apply => 'Применить';
  String get delete => 'Удалить';
  String get duplicate => 'Дублировать';
  String get rename => 'Переименовать';
  String get share => 'Поделиться';
  String get export => 'Экспорт';
  String get loading => 'Загрузка...';
  String get error => 'Ошибка';
  String get success => 'Успешно';
  String get yes => 'Да';
  String get no => 'Нет';
  String get ok => 'ОК';
  
  // ═══════════════════════════════════════════════════════════════
  // АВТОРИЗАЦИЯ
  // ═══════════════════════════════════════════════════════════════
  String get email => 'Email';
  String get password => 'Пароль';
  String get name => 'Имя';
  String get confirmPassword => 'Подтвердите пароль';
  String get forgotPassword => 'Забыли пароль?';
  String get noAccount => 'Нет аккаунта?';
  String get haveAccount => 'Уже есть аккаунт?';
  String get loginError => 'Неверный email или пароль';
  String get registerError => 'Ошибка регистрации';
  String get passwordLengthError => 'Пароль должен быть минимум 6 символов';
  String get emailRequired => 'Email обязателен';
  String get passwordRequired => 'Пароль обязателен';
  String get nameRequired => 'Имя обязательно';
  
  // ═══════════════════════════════════════════════════════════════
  // ГЛАВНЫЙ ЭКРАН
  // ═══════════════════════════════════════════════════════════════
  String get createPresentation => 'Создай презентацию';
  String get withAI => 'с помощью ИИ за 1 минуту';
  String get topicHint => 'О чём презентация?';
  String get createButton => 'Создать';
  String get slidesCount => 'Количество слайдов';
  String get limitReached => 'Лимит исчерпан';
  String get generationsLeft => 'Осталось генераций в этом месяце:';
  String get free => 'Бесплатно';
  String get month => 'Месяц';
  String get halfYear => 'Полгода';
  String get year => 'Год';
  String get popular => 'Популярный';
  String get save33 => 'Экономия 33%';
  String get save15 => 'Экономия 15%';
  String get premiumUnlimited => 'Premium • Безлимитно';
  String get buyTariff => 'Купить тариф — USDT';
  
  // ═══════════════════════════════════════════════════════════════
  // ПРЕМИУМ ЭКРАН
  // ═══════════════════════════════════════════════════════════════
  String get unlockEverything => 'Разблокируй всё';
  String get pricesInUSD => 'Цены в USD — оплата USDT';
  String get feature => 'Функция';
  String get presentations => 'Презентаций';
  String get slides => 'Слайдов';
  String get backgrounds => 'Фоны';
  String get fonts => 'Шрифты';
  String get animations => 'Анимации';
  String get pdfExport => 'PDF экспорт';
  String get aiImprove => 'AI-улучшение';
  String get customImages => 'Свои картинки';
  String get watermark => 'Водяной знак';
  String get freePlan => 'Бесплатно';
  String get premiumPlan => 'Premium';
  String get unlimited => '∞';
  String get monthly => 'Monthly';
  String get halfYearly => '6 Months';
  String get yearly => 'Yearly';
  String get bestValue => 'BEST VALUE';
  String get securePayment => 'Безопасная оплата';
  String get cancelAnytime => 'Отмена в любое время';
  String get payWithUSDT => '💳 Оплатить USDT';
  
  // ═══════════════════════════════════════════════════════════════
  // ГЕНЕРАТОР ТЕСТОВ
  // ═══════════════════════════════════════════════════════════════
  String get quizGenerator => 'Генератор тестов';
  String get createQuizFromTopic => 'Создайте тест по теме или презентации';
  String get fromPresentation => 'Из презентации';
  String get byTopic => 'По теме';
  String get uploadFile => 'Загрузить файл';
  String get chooseFile => 'Выбрать файл';
  String get selectFromSaved => 'Или выберите из сохранённых';
  String get selectPresentation => 'Выберите презентацию';
  String get generateQuiz => 'Сгенерировать тест';
  String get question => 'Вопрос';
  String get score => 'Счёт';
  String get selectAnswer => 'Выберите ответ';
  String get correct => 'Правильно!';
  String get wrong => 'Неправильно!';
  String get correctAnswer => 'Правильный ответ:';
  String get showAnswers => 'Показать ответы';
  String get hideAnswers => 'Скрыть ответы';
  String get newQuiz => 'Новый тест';
  String get backToHome => 'На главную';
  String get excellent => 'Отлично!';
  String get good => 'Хорошо!';
  String get tryAgain => 'Попробуй ещё!';
  
  // ═══════════════════════════════════════════════════════════════
  // КОНСТРУКТОР УРОКОВ
  // ═══════════════════════════════════════════════════════════════
  String get lessonBuilder => 'Конструктор уроков';
  String get createFullLesson => 'Создайте полноценный урок по вашей теме';
  String get subject => 'Предмет';
  String get grade => 'Класс';
  String get standard => 'Стандарт';
  String get generateLesson => 'Создать урок';
  String get lessonPlan => 'План урока';
  String get homework => 'Домашнее задание';
  String get materials => 'Материалы';
  
  // ═══════════════════════════════════════════════════════════════
  // КОНСТРУКТОР ОТЧЁТОВ
  // ═══════════════════════════════════════════════════════════════
  String get reportBuilder => 'Конструктор отчётов';
  String get createFinancialReport => 'Создайте профессиональный финансовый отчёт';
  String get company => 'Компания';
  String get period => 'Период';
  String get reportType => 'Тип отчёта';
  String get generateReport => 'Создать отчёт';
  
  // ═══════════════════════════════════════════════════════════════
  // ЭКСПОРТ
  // ═══════════════════════════════════════════════════════════════
  String get exportToPPTX => 'PowerPoint';
  String get exportToPDF => 'PDF';
  String get withWatermark => 'С водяным знаком';
  String get noWatermark => 'Без водяного знака';
  String get premiumRequired => 'Только Premium';
  String get highQuality => 'Высокое качество';
  
  // ═══════════════════════════════════════════════════════════════
  // ПРОФИЛЬ И НАСТРОЙКИ
  // ═══════════════════════════════════════════════════════════════
  String get profile => 'Профиль';
  String get settings => 'Настройки';
  String get history => 'История';
  String get referralProgram => 'Реферальная программа';
  String get inviteFriends => 'Пригласи друзей';
  String get getBonus => 'Получи бонус';
  String get language => 'Язык';
  String get russian => 'Русский';
  String get english => 'English';
  
  // ═══════════════════════════════════════════════════════════════
  // ДИАЛОГИ И ОШИБКИ
  // ═══════════════════════════════════════════════════════════════
  String get limitReachedTitle => 'Лимит исчерпан';
  String get limitReachedMessage => 'Вы использовали все 5 бесплатных генераций на этот месяц. Оформите подписку, чтобы продолжить.';
  String get subscribe => 'Оформить подписку';
  String get pleaseLogIn => 'Пожалуйста, войдите в аккаунт';
  String get sessionExpired => 'Сессия истекла';
  String get networkError => 'Ошибка сети';
  String get somethingWentWrong => 'Что-то пошло не так';
  
  // ═══════════════════════════════════════════════════════════════
  // ОПЛАТА
  // ═══════════════════════════════════════════════════════════════
  String get payment => 'Оплата';
  String get securePaymentRedirect => 'Вы будете перенаправлены на защищённую страницу оплаты';
  String get payNow => 'Оплатить';
  String get afterPaymentMessage => 'После успешной оплаты USDT, вернитесь в приложение и подождите 1-2 минуты для автоматической активации.';
  String get promoCode => 'Промокод';
  String get enterPromoCode => 'Введите промокод';
  String get promoCodeApplied => 'Промокод применён!';
  String get invalidPromoCode => 'Неверный промокод';
}

// Класс для английского языка
class AppStringsEn extends AppStrings {
  @override
  String get appTitle => 'Prezentator AI';
  @override
  String get login => 'Login';
  @override
  String get register => 'Register';
  @override
  String get logout => 'Logout';
  @override
  String get cancel => 'Cancel';
  @override
  String get later => 'Later';
  @override
  String get back => 'Back';
  @override
  String get save => 'Save';
  @override
  String get close => 'Close';
  @override
  String get create => 'Create';
  @override
  String get generate => 'Generate';
  @override
  String get select => 'Select';
  @override
  String get apply => 'Apply';
  @override
  String get delete => 'Delete';
  @override
  String get duplicate => 'Duplicate';
  @override
  String get rename => 'Rename';
  @override
  String get share => 'Share';
  @override
  String get export => 'Export';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get ok => 'OK';
  
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get name => 'Name';
  @override
  String get confirmPassword => 'Confirm password';
  @override
  String get forgotPassword => 'Forgot password?';
  @override
  String get noAccount => 'No account?';
  @override
  String get haveAccount => 'Already have an account?';
  @override
  String get loginError => 'Invalid email or password';
  @override
  String get registerError => 'Registration error';
  @override
  String get passwordLengthError => 'Password must be at least 6 characters';
  @override
  String get emailRequired => 'Email is required';
  @override
  String get passwordRequired => 'Password is required';
  @override
  String get nameRequired => 'Name is required';
  
  @override
  String get createPresentation => 'Create a Presentation';
  @override
  String get withAI => 'with AI in 1 minute';
  @override
  String get topicHint => 'What is your presentation about?';
  @override
  String get createButton => 'Create';
  @override
  String get slidesCount => 'Number of slides';
  @override
  String get limitReached => 'Limit reached';
  @override
  String get generationsLeft => 'Generations left this month:';
  @override
  String get free => 'Free';
  @override
  String get month => 'Month';
  @override
  String get halfYear => '6 Months';
  @override
  String get year => 'Year';
  @override
  String get popular => 'Popular';
  @override
  String get save33 => 'Save 33%';
  @override
  String get save15 => 'Save 15%';
  @override
  String get premiumUnlimited => 'Premium • Unlimited';
  @override
  String get buyTariff => 'Buy plan — USDT';
  
  @override
  String get unlockEverything => 'Unlock Everything';
  @override
  String get pricesInUSD => 'Prices in USD — pay with USDT';
  @override
  String get feature => 'Feature';
  @override
  String get presentations => 'Presentations';
  @override
  String get slides => 'Slides';
  @override
  String get backgrounds => 'Backgrounds';
  @override
  String get fonts => 'Fonts';
  @override
  String get animations => 'Animations';
  @override
  String get pdfExport => 'PDF Export';
  @override
  String get aiImprove => 'AI Improve';
  @override
  String get customImages => 'Custom Images';
  @override
  String get watermark => 'Watermark';
  @override
  String get freePlan => 'Free';
  @override
  String get premiumPlan => 'Premium';
  @override
  String get unlimited => '∞';
  @override
  String get monthly => 'Monthly';
  @override
  String get halfYearly => '6 Months';
  @override
  String get yearly => 'Yearly';
  @override
  String get bestValue => 'BEST VALUE';
  @override
  String get securePayment => 'Secure payment';
  @override
  String get cancelAnytime => 'Cancel anytime';
  @override
  String get payWithUSDT => '💳 Pay with USDT';
  
  @override
  String get quizGenerator => 'Quiz Generator';
  @override
  String get createQuizFromTopic => 'Create a quiz from a topic or presentation';
  @override
  String get fromPresentation => 'From Presentation';
  @override
  String get byTopic => 'By Topic';
  @override
  String get uploadFile => 'Upload file';
  @override
  String get chooseFile => 'Choose file';
  @override
  String get selectFromSaved => 'Or select from saved';
  @override
  String get selectPresentation => 'Select presentation';
  @override
  String get generateQuiz => 'Generate quiz';
  @override
  String get question => 'Question';
  @override
  String get score => 'Score';
  @override
  String get selectAnswer => 'Select answer';
  @override
  String get correct => 'Correct!';
  @override
  String get wrong => 'Wrong!';
  @override
  String get correctAnswer => 'Correct answer:';
  @override
  String get showAnswers => 'Show answers';
  @override
  String get hideAnswers => 'Hide answers';
  @override
  String get newQuiz => 'New quiz';
  @override
  String get backToHome => 'Back to home';
  @override
  String get excellent => 'Excellent!';
  @override
  String get good => 'Good job!';
  @override
  String get tryAgain => 'Try again!';
  
  @override
  String get lessonBuilder => 'Lesson Builder';
  @override
  String get createFullLesson => 'Create a full lesson plan on your topic';
  @override
  String get subject => 'Subject';
  @override
  String get grade => 'Grade';
  @override
  String get standard => 'Standard';
  @override
  String get generateLesson => 'Generate lesson';
  @override
  String get lessonPlan => 'Lesson plan';
  @override
  String get homework => 'Homework';
  @override
  String get materials => 'Materials';
  
  @override
  String get reportBuilder => 'Report Builder';
  @override
  String get createFinancialReport => 'Create a professional financial report';
  @override
  String get company => 'Company';
  @override
  String get period => 'Period';
  @override
  String get reportType => 'Report type';
  @override
  String get generateReport => 'Generate report';
  
  @override
  String get exportToPPTX => 'PowerPoint';
  @override
  String get exportToPDF => 'PDF';
  @override
  String get withWatermark => 'With watermark';
  @override
  String get noWatermark => 'No watermark';
  @override
  String get premiumRequired => 'Premium only';
  @override
  String get highQuality => 'High quality';
  
  @override
  String get profile => 'Profile';
  @override
  String get settings => 'Settings';
  @override
  String get history => 'History';
  @override
  String get referralProgram => 'Referral program';
  @override
  String get inviteFriends => 'Invite friends';
  @override
  String get getBonus => 'Get bonus';
  @override
  String get language => 'Language';
  @override
  String get russian => 'Russian';
  @override
  String get english => 'English';
  
  @override
  String get limitReachedTitle => 'Limit reached';
  @override
  String get limitReachedMessage => 'You have used all 5 free generations for this month. Subscribe to continue.';
  @override
  String get subscribe => 'Subscribe';
  @override
  String get pleaseLogIn => 'Please log in';
  @override
  String get sessionExpired => 'Session expired';
  @override
  String get networkError => 'Network error';
  @override
  String get somethingWentWrong => 'Something went wrong';
  
  @override
  String get payment => 'Payment';
  @override
  String get securePaymentRedirect => 'You will be redirected to a secure payment page';
  @override
  String get payNow => 'Pay now';
  @override
  String get afterPaymentMessage => 'After successful USDT payment, return to the app and wait 1-2 minutes for automatic activation.';
  @override
  String get promoCode => 'Promo code';
  @override
  String get enterPromoCode => 'Enter promo code';
  @override
  String get promoCodeApplied => 'Promo code applied!';
  @override
  String get invalidPromoCode => 'Invalid promo code';
}