// lib/l10n/app_strings.dart

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
  String get continueText => 'Продолжить';
  String get fillAllFields => 'Заполните все поля';
  String get checking => 'Проверка...';
  String get applyingPromoCode => 'Применяем промокод...';
  String get failedToApplyPromoCode => 'Не удалось применить промокод';
  String get errorApplyingPromoCode => 'Ошибка применения промокода';
  String get daysFree => 'дня бесплатно';
  String get payment => 'Оплата';
  String get apply => 'Применить';
  String get active => 'Активен';
  String get profile => 'Профиль';
  String get statistics => 'Статистика';
  String get remaining => 'Осталось';
  String get perMonth => 'Генераций/мес';
  String get maxSlides => 'Макс. слайдов';
  String get logoutConfirmation => 'Вы уверены, что хотите выйти?';
  String get logoutError => 'Ошибка выхода';
  String get premiumStatus => 'Premium статус';
  String get allFeaturesAvailable => 'Все функции доступны';
  String get thisMonth => 'в этом месяце';
  String get activate => 'Активировать';
  String get of => 'из';
  String get ofFive => 'из 5';
  String get generationsLeftLower => 'бесплатных генераций осталось';
  String get quizGenerator => 'Генератор тестов';
  String get createQuizFromTopic => 'Создайте тест по теме или презентации';
  String get fromPresentation => 'Из презентации';
  String get byTopic => 'По теме';
  String get uploadFile => 'Загрузить файл';
  String get chooseFile => 'Выбрать файл';
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
  String get premiumRequired => 'Premium доступ';
  String get pdfPremiumOnly => 'Экспорт в PDF доступен только с Premium подпиской';
  String get uploadFileFirst => 'Сначала загрузите файл';
  String get selectPresentationFirst => 'Выберите презентацию';
  String get enterTopicFirst => 'Введите тему';
  String get questionsRange => 'Количество вопросов должно быть от 3 до 10';
  String get generateQuizFromFile => 'Сгенерировать тест из файла';
  String get generateQuizFromPresentation => 'Сгенерировать тест из презентации';
  String get quizSaved => 'Тест сохранён в';
  String get correctAnswersTitle => 'ПРАВИЛЬНЫЕ ОТВЕТЫ';
  String get friends => 'Друзья';
  String get inviteFriend => 'Пригласи друга';
  String get sendReferralLink => 'Отправь реферальную ссылку другу';
  String get free => 'Бесплатно';
  String get friendRegistration => 'Регистрация друга';
  String get friendRegisters => 'Друг зарегистрируется по твоей ссылке';
  String get friendPremium => 'Premium друга';
  String get friendBuysPremium => 'Друг купит Premium тариф';
  String get generations => 'генераций';
  String get inviteFriendTitle => 'Приведи друга';
  String get getBonusGenerations => 'Получи бонусные генерации';
  String get invitations => 'Приглашений';
  String get bonusReceived => 'Бонусов получено';
  String get yourReferralCode => 'ВАШ РЕФЕРАЛЬНЫЙ КОД';
  String get copied => 'Скопировано!';
  String get copy => 'Копировать';
  String get codeCopied => 'Код скопирован!';
  String get copyError => 'Ошибка копирования';
  String get link => 'Ссылка';
  String get inviteFriendsButton => 'Пригласить друзей';
  String get howItWorks => 'Как это работает';
  String get invitedFriends => 'ПРИГЛАШЁННЫЕ ДРУЗЬЯ';
  String get user => 'Пользователь';
  String get pending => 'Ожидает';
  String get referralProgram => 'Реферальная программа';
  String get inviteFriendsGetBonuses => 'Приглашайте друзей и получайте бонусы';
  String get referralLoginRequired => 'Реферальная программа доступна только авторизованным пользователям';
  String get registerAndPayment => 'Регистрация и оплата';
  String get paymentModuleUnderDevelopment => 'Платёжный модуль в разработке';
  String get premiumWillBeActivatedAfterPayment => 'Premium доступ будет активирован после оплаты';
  String get monthlySubscription => 'Месячная подписка';
  String get semiannualSubscription => 'Полугодовая подписка';
  String get annualSubscription => 'Годовая подписка';
  String get subscription => 'Подписка';
  
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
  String get logIn => 'Войти';
  String get welcome => 'Добро пожаловать';
  String get loginToAccount => 'Войдите в свой аккаунт';
  String get welcomeBack => 'С возвращением';
  
  // ═══════════════════════════════════════════════════════════════
  // СБРОС ПАРОЛЯ
  // ═══════════════════════════════════════════════════════════════
  String get resetPassword => 'Сброс пароля';
  String get resetPasswordSubtitle => 'Мы отправим ссылку для сброса пароля\nна вашу почту';
  String get sendResetLink => 'Отправить ссылку';
  String get emailSent => 'Письмо отправлено!';
  String get checkEmail => 'Проверьте почту';
  String get backToLogin => 'Вернуться к входу';
  
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
  String get buyPlanUSDT => 'Купить тариф — USDT';
  String get unlimited => '∞';
  String get enterTopic => 'Введите тему презентации';
  String get uploadText => 'Загрузите текст';
  String get pasteText => 'Вставьте текст для презентации';
  String get yourText => 'Ваш текст...';
  String get fromText => 'Из текста';
  String get uploadLogo => 'Загрузить логотип';
  String get templates => 'Шаблоны';
  String get generationsFinished => 'Бесплатные генерации на месяц закончились';
  String get choosePlan => 'Выберите план';
  String get pricesInUSD => 'Цены в USD — оплата USDT';
  String get monthLower => 'мес';
  String get generationsPerMonth => 'генераций/мес';
  String get slidesLower => 'слайдов';
  String get backgroundsLower => 'фонов';
  String get basicExport => 'Базовый экспорт';
  String get allFromMonth => 'Всё из Месяца';
  String get allFromHalfYear => 'Всё из Полугода';
  String get save17 => 'Экономия 17%';
  String get prioritySupport => 'Приоритетная поддержка';
  String get brandKit => 'Бренд-кит';
  String get payWithUSDTShort => 'Оплата USDT';
  String get bestValue => 'ВЫГОДНО';
  String get upgradeToUnlimited => 'Перейти на безлимит';
  String get usedThreeOfFive => 'Вы использовали 3 из 5 бесплатных генераций.';
  String get unlimitedPresentations => 'Безлимит презентаций';
  String get fiftySlides => '50 слайдов на презентацию';
  String get pdfNoWatermark => 'PDF без водяного знака';
  String get only499PerMonth => 'Всего $4.99/мес — оплата USDT';
  String get continueFree => 'Продолжить бесплатно';
  String get upgradeNow => 'Оформить подписку — $4.99';
  String get limitReachedLoggedIn => 'Вы использовали все бесплатные генерации на этот месяц.\n\nОформите подписку, чтобы продолжить создавать презентации, уроки и тесты без ограничений.';
  String get limitReachedGuest => 'У вас есть 5 бесплатных генераций без регистрации. Чтобы получить больше, войдите или оформите подписку.';
  String get payWithUSDT => 'Оплатить USDT';
  String get generationHistory => 'История генераций';
  String get noGenerations => 'Пока нет генераций';
  String get repeat => 'Повторить';
  String get logoPremiumOnly => 'Загрузка логотипа — Premium функция';
  String get logoUploaded => 'Логотип загружен!';
  String get afterPaymentMessage => 'После оплаты USDT, вернитесь в приложение. Подписка активируется через 1-2 мин.\nПромокод CRYPTO10 → второй месяц бесплатно!';
  
  // ═══════════════════════════════════════════════════════════════
  // ПРЕМИУМ ЭКРАН
  // ═══════════════════════════════════════════════════════════════
  String get unlockEverything => 'Разблокируй всё';
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
  String get monthly => 'Месяц';
  String get halfYearly => '6 месяцев';
  String get yearly => 'Год';
  String get securePayment => 'Безопасная оплата';
  String get cancelAnytime => 'Отмена в любое время';
  
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
  String get lessonGenerationError => 'Ошибка создания урока:';
  String get lesson => 'Урок';
  String get subjectLabel => 'Предмет';
  String get gradeLabel => 'Класс';
  String get durationLabel => 'Длительность';
  String get minutes => 'мин';
  String get slide => 'Слайд';
  String get lessonTitle => 'Урок:';
  String get topicHintLesson => 'Тема урока';
  String get subjectHint => 'Предмет';
  String get gradeHint => 'Класс';
  String get standardLabel => 'Образовательный стандарт';
  String get generationsFinishedLesson => 'Бесплатные генерации закончились. Оформите подписку, чтобы продолжить.';
  String get generationsLeftLesson => 'Осталось';
  
  // ═══════════════════════════════════════════════════════════════
  // ЭКРАН ЗАГРУЗКИ
  // ═══════════════════════════════════════════════════════════════
  String get analyzingTopic => 'Анализирую тему...';
  String get generatingStructure => 'Генерирую структуру...';
  String get creatingSlides => 'Создаю слайды...';
  String get selectingDesign => 'Подбираю оформление...';
  String get almostReady => 'Почти готово...';
  String get mayTakeUpTo30Seconds => 'Это может занять до 30 секунд';
  String get finishing => 'Завершаем...';
  
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
  String get highQuality => 'Высокое качество';
  
  // ═══════════════════════════════════════════════════════════════
  // ПРОФИЛЬ И НАСТРОЙКИ
  // ═══════════════════════════════════════════════════════════════
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
  String get securePaymentRedirect => 'Вы будете перенаправлены на защищённую страницу оплаты';
  String get payNow => 'Оплатить';
  String get promoCode => 'Промокод';
  String get enterPromoCode => 'Введите промокод';
  String get promoCodeApplied => 'Промокод применён!';
  String get invalidPromoCode => 'Неверный промокод';
  String get payWithUSDTLong => 'Оплата в USDT (криптовалюта)';
  String get noFeesNoBanks => 'Без комиссий, без банков — защищённая оплата через CryptoCloud';
  String get promoCodeCRYPTO10 => '🎁 Промокод CRYPTO10 — второй месяц бесплатно для первых 10 платящих';
  
  // ═══════════════════════════════════════════════════════════════
  // НАВИГАЦИЯ
  // ═══════════════════════════════════════════════════════════════
  String get forTeachers => 'Учителям';
  String get forBusiness => 'Бизнесу';
  String get team => 'Команда';
  String get tests => 'Тесты';
  String get friends => 'Друзья';
  
  // ═══════════════════════════════════════════════════════════════
  // CORPORATE SCREEN
  // ═══════════════════════════════════════════════════════════════
  String get business => 'Бизнес';
  String get corporate => 'Корпоративный';
  String get plan => 'Тариф';
  String get corporatePlans => 'Корпоративные тарифы';
  String get corporateSubtitle => 'Для компаний любого размера — оплата USDT';
  String get chooseYourPlan => 'ВЫБЕРИТЕ ПЛАН';
  String get forSmallBusiness => 'Для малого бизнеса';
  String get forLargeCompanies => 'Для крупных компаний';
  String get openReportBuilder => 'Открыть конструктор отчётов';
  String get contactSales => 'Связаться с отделом продаж';
  String get included => 'Включено';
  String get salesDepartment => 'Отдел продаж';
  String get contactSalesText => 'Свяжитесь с нами для подбора индивидуального тарифа';
}

// ═══════════════════════════════════════════════════════════════
// ENGLISH VERSION
// ═══════════════════════════════════════════════════════════════
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
  String get continueText => 'Continue';
  @override
  String get fillAllFields => 'Please fill all fields';
  @override
  String get checking => 'Checking...';
  @override
  String get applyingPromoCode => 'Applying promo code...';
  @override
  String get failedToApplyPromoCode => 'Failed to apply promo code';
  @override
  String get errorApplyingPromoCode => 'Error applying promo code';
  @override
  String get daysFree => 'days free';
  @override
  String get payment => 'Payment';
  @override
  String get apply => 'Apply';
  @override
  String get active => 'Active';
  @override
  String get profile => 'Profile';
  @override
  String get statistics => 'Statistics';
  @override
  String get remaining => 'Remaining';
  @override
  String get perMonth => 'Generations/month';
  @override
  String get maxSlides => 'Max slides';
  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';
  @override
  String get logoutError => 'Logout error';
  @override
  String get premiumStatus => 'Premium status';
  @override
  String get allFeaturesAvailable => 'All features available';
  @override
  String get thisMonth => 'this month';
  @override
  String get activate => 'Activate';
  @override
  String get of => 'of';
  @override
  String get ofFive => 'of 5';
  @override
  String get generationsLeftLower => 'free generations left';
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
  String get premiumRequired => 'Premium Required';
  @override
  String get pdfPremiumOnly => 'PDF export is only available with a Premium subscription.';
  @override
  String get uploadFileFirst => 'Upload a file first';
  @override
  String get selectPresentationFirst => 'Select a presentation';
  @override
  String get enterTopicFirst => 'Enter a topic';
  @override
  String get questionsRange => 'Questions must be between 3 and 10';
  @override
  String get generateQuizFromFile => 'Generate Quiz from File';
  @override
  String get generateQuizFromPresentation => 'Generate Quiz from Presentation';
  @override
  String get quizSaved => 'Quiz saved as';
  @override
  String get correctAnswersTitle => 'CORRECT ANSWERS';
  @override
  String get friends => 'Friends';
  @override
  String get inviteFriend => 'Invite a friend';
  @override
  String get sendReferralLink => 'Send referral link to a friend';
  @override
  String get free => 'Free';
  @override
  String get friendRegistration => 'Friend registration';
  @override
  String get friendRegisters => 'Friend registers using your link';
  @override
  String get friendPremium => 'Friend Premium';
  @override
  String get friendBuysPremium => 'Friend buys Premium plan';
  @override
  String get generations => 'generations';
  @override
  String get inviteFriendTitle => 'Invite a friend';
  @override
  String get getBonusGenerations => 'Get bonus generations';
  @override
  String get invitations => 'Invitations';
  @override
  String get bonusReceived => 'Bonuses received';
  @override
  String get yourReferralCode => 'YOUR REFERRAL CODE';
  @override
  String get copied => 'Copied!';
  @override
  String get copy => 'Copy';
  @override
  String get codeCopied => 'Code copied!';
  @override
  String get copyError => 'Copy error';
  @override
  String get link => 'Link';
  @override
  String get inviteFriendsButton => 'Invite friends';
  @override
  String get howItWorks => 'How it works';
  @override
  String get invitedFriends => 'INVITED FRIENDS';
  @override
  String get user => 'User';
  @override
  String get pending => 'Pending';
  @override
  String get referralProgram => 'Referral program';
  @override
  String get inviteFriendsGetBonuses => 'Invite friends and get bonuses';
  @override
  String get referralLoginRequired => 'Referral program is only available to logged in users';
  @override
  String get registerAndPayment => 'Registration & Payment';
  @override
  String get paymentModuleUnderDevelopment => 'Payment module is under development';
  @override
  String get premiumWillBeActivatedAfterPayment => 'Premium access will be activated after payment';
  @override
  String get monthlySubscription => 'Monthly subscription';
  @override
  String get semiannualSubscription => 'Semi-annual subscription';
  @override
  String get annualSubscription => 'Annual subscription';
  @override
  String get subscription => 'Subscription';
  
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
  String get logIn => 'Log in';
  @override
  String get welcome => 'Welcome';
  @override
  String get loginToAccount => 'Log in to your account';
  @override
  String get welcomeBack => 'Welcome back';
  
  @override
  String get resetPassword => 'Reset Password';
  @override
  String get resetPasswordSubtitle => 'We will send a password reset link\nto your email';
  @override
  String get sendResetLink => 'Send reset link';
  @override
  String get emailSent => 'Email sent!';
  @override
  String get checkEmail => 'Check your email';
  @override
  String get backToLogin => 'Back to login';
  
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
  String get buyPlanUSDT => 'Buy plan — USDT';
  @override
  String get unlimited => '∞';
  @override
  String get enterTopic => 'Enter a presentation topic';
  @override
  String get uploadText => 'Upload text';
  @override
  String get pasteText => 'Paste text for presentation';
  @override
  String get yourText => 'Your text...';
  @override
  String get fromText => 'From text';
  @override
  String get uploadLogo => 'Upload logo';
  @override
  String get templates => 'Templates';
  @override
  String get generationsFinished => 'Free generations for the month are over';
  @override
  String get choosePlan => 'Choose plan';
  @override
  String get pricesInUSD => 'Prices in USD — pay with USDT';
  @override
  String get monthLower => 'month';
  @override
  String get generationsPerMonth => 'generations/month';
  @override
  String get slidesLower => 'slides';
  @override
  String get backgroundsLower => 'backgrounds';
  @override
  String get basicExport => 'Basic export';
  @override
  String get allFromMonth => 'Everything from Month';
  @override
  String get allFromHalfYear => 'Everything from 6 Months';
  @override
  String get save17 => 'Save 17%';
  @override
  String get prioritySupport => 'Priority support';
  @override
  String get brandKit => 'Brand kit';
  @override
  String get payWithUSDTShort => 'Pay with USDT';
  @override
  String get bestValue => 'BEST VALUE';
  @override
  String get upgradeToUnlimited => 'Upgrade to Unlimited';
  @override
  String get usedThreeOfFive => 'You have used 3 of 5 free generations.';
  @override
  String get unlimitedPresentations => 'Unlimited presentations';
  @override
  String get fiftySlides => '50 slides per presentation';
  @override
  String get pdfNoWatermark => 'PDF export without watermark';
  @override
  String get only499PerMonth => 'Only \$4.99/month — pay with USDT';
  @override
  String get continueFree => 'Continue free';
  @override
  String get upgradeNow => 'Upgrade now — \$4.99';
  @override
  String get limitReachedLoggedIn => 'You have used all free generations for this month.\n\nSubscribe to continue creating unlimited presentations, lessons, tests and reports.';
  @override
  String get limitReachedGuest => 'You have 5 free generations without registration. To get more, log in or subscribe.';
  @override
  String get payWithUSDT => 'Pay with USDT';
  @override
  String get generationHistory => 'Generation history';
  @override
  String get noGenerations => 'No generations yet';
  @override
  String get repeat => 'Repeat';
  @override
  String get logoPremiumOnly => 'Logo upload is a Premium feature';
  @override
  String get logoUploaded => 'Logo uploaded!';
  @override
  String get afterPaymentMessage => 'After payment, return to the app. Subscription activates in 1-2 min.\nPromo code CRYPTO10 → second month free!';
  
  @override
  String get unlockEverything => 'Unlock Everything';
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
  String get monthly => 'Monthly';
  @override
  String get halfYearly => '6 Months';
  @override
  String get yearly => 'Yearly';
  @override
  String get securePayment => 'Secure payment';
  @override
  String get cancelAnytime => 'Cancel anytime';
  
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
  String get lessonGenerationError => 'Lesson generation error:';
  @override
  String get lesson => 'Lesson';
  @override
  String get subjectLabel => 'Subject';
  @override
  String get gradeLabel => 'Grade';
  @override
  String get durationLabel => 'Duration';
  @override
  String get minutes => 'min';
  @override
  String get slide => 'Slide';
  @override
  String get lessonTitle => 'Lesson:';
  @override
  String get topicHintLesson => 'Lesson topic';
  @override
  String get subjectHint => 'Subject';
  @override
  String get gradeHint => 'Grade';
  @override
  String get standardLabel => 'Educational standard';
  @override
  String get generationsFinishedLesson => 'Free generations are over. Subscribe to continue.';
  @override
  String get generationsLeftLesson => 'Left';
  
  @override
  String get analyzingTopic => 'Analyzing topic...';
  @override
  String get generatingStructure => 'Generating structure...';
  @override
  String get creatingSlides => 'Creating slides...';
  @override
  String get selectingDesign => 'Selecting design...';
  @override
  String get almostReady => 'Almost ready...';
  @override
  String get mayTakeUpTo30Seconds => 'This may take up to 30 seconds';
  @override
  String get finishing => 'Finishing...';
  
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
  String get highQuality => 'High quality';
  
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
  String get securePaymentRedirect => 'You will be redirected to a secure payment page';
  @override
  String get payNow => 'Pay now';
  @override
  String get promoCode => 'Promo code';
  @override
  String get enterPromoCode => 'Enter promo code';
  @override
  String get promoCodeApplied => 'Promo code applied!';
  @override
  String get invalidPromoCode => 'Invalid promo code';
  @override
  String get payWithUSDTLong => 'Pay with USDT (cryptocurrency)';
  @override
  String get noFeesNoBanks => 'No fees, no banks — secure payment via CryptoCloud';
  @override
  String get promoCodeCRYPTO10 => '🎁 Promo code CRYPTO10 — second month free for first 10 paying users';
  
  @override
  String get forTeachers => 'For Teachers';
  @override
  String get forBusiness => 'For Business';
  @override
  String get team => 'Team';
  @override
  String get tests => 'Tests';
  @override
  String get friends => 'Friends';
  
  @override
  String get business => 'Business';
  @override
  String get corporate => 'Corporate';
  @override
  String get plan => 'Plan';
  @override
  String get corporatePlans => 'Corporate Plans';
  @override
  String get corporateSubtitle => 'For companies of any size — pay with USDT';
  @override
  String get chooseYourPlan => 'CHOOSE YOUR PLAN';
  @override
  String get forSmallBusiness => 'For small business';
  @override
  String get forLargeCompanies => 'For large companies';
  @override
  String get openReportBuilder => 'Open Report Builder';
  @override
  String get contactSales => 'Contact Sales';
  @override
  String get included => 'INCLUDED';
  @override
  String get salesDepartment => 'Sales Department';
  @override
  String get contactSalesText => 'Contact us for custom corporate pricing';
}