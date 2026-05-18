const axios = require('axios');

exports.generateLessonPlan = async (req, res) => {
  try {
    const { topic, subject, standard, grade, durationMinutes } = req.body;

    const prompt = `
      Ты — эксперт по педагогике. Создай подробный план урока.

      Входные данные:
      - Тема: ${topic}
      - Предмет: ${subject}
      - Класс/возраст: ${grade}
      - Образовательный стандарт: ${standard}
      - Длительность: ${durationMinutes} минут

      Ответ должен быть в строгом JSON формате без лишнего текста:

      {
        "topic": "${topic}",
        "subject": "${subject}",
        "grade": "${grade}",
        "standard": "${standard}",
        "duration": "${durationMinutes} минут",
        "objectives": ["цель 1", "цель 2", "цель 3", "цель 4"],
        "stages": [
          {
            "name": "Организационный момент",
            "minutes": 5,
            "teacherActions": "Приветствие, проверка готовности",
            "studentActions": "Подготовка к уроку",
            "resources": "Презентация"
          },
          {
            "name": "Актуализация знаний",
            "minutes": 10,
            "teacherActions": "Опрос по предыдущей теме",
            "studentActions": "Ответы на вопросы",
            "resources": "Доска, карточки"
          },
          {
            "name": "Изучение нового материала",
            "minutes": 20,
            "teacherActions": "Объяснение темы, демонстрация",
            "studentActions": "Конспектирование, вопросы",
            "resources": "Видео, схемы"
          },
          {
            "name": "Закрепление",
            "minutes": 7,
            "teacherActions": "Практические задания",
            "studentActions": "Выполнение упражнений",
            "resources": "Рабочие листы"
          },
          {
            "name": "Итоги и рефлексия",
            "minutes": 3,
            "teacherActions": "Подведение итогов, оценки",
            "studentActions": "Рефлексия, самооценка",
            "resources": "Дневники"
          }
        ],
        "homework": "Конкретное домашнее задание по теме",
        "assessment": "Критерии оценивания на уроке",
        "differentiation": ["Индивидуальные карточки", "Групповая работа", "Дополнительные задания"]
      }
    `;

    // Используй YandexGPT или OpenAI
    const yandexApiKey = process.env.YANDEX_API_KEY;
    const yandexFolderId = process.env.YANDEX_FOLDER_ID;

    const response = await axios.post(
      'https://llm.api.cloud.yandex.net/foundationModels/v1/completion',
      {
        modelUri: `gpt://${yandexFolderId}/yandexgpt-lite`,
        completionOptions: {
          stream: false,
          temperature: 0.7,
          maxTokens: 2000,
        },
        messages: [
          {
            role: 'system',
            text: 'Ты — эксперт по педагогике. Отвечай только в формате JSON.',
          },
          {
            role: 'user',
            text: prompt,
          },
        ],
      },
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Api-Key ${yandexApiKey}`,
        },
      }
    );

    const aiResponse = response.data.result.alternatives[0].message.text;
    
    // Парсим JSON из ответа AI
    const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
    const lessonPlan = jsonMatch ? JSON.parse(jsonMatch[0]) : null;

    if (!lessonPlan) {
      throw new Error('Не удалось распарсить ответ AI');
    }

    res.json(lessonPlan);
  } catch (error) {
    console.error('Error generating lesson plan:', error);
    res.status(500).json({ message: 'Ошибка генерации плана урока', error: error.message });
  }
};