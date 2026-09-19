# Antigravity Commercial Engineering System
*Read this in [Ukrainian (Українською)](#-українська-версія)*

This is a commercial-grade architectural system for developing software using AI agents (Google Antigravity). 
It is designed to force artificial intelligence to work like a professional engineering team: with strict testing, code isolation in branches, and 100% real logs (evidence) of functionality instead of "hallucinations".

## 🚀 What is it?
The system divides the work among three roles:
1. **Architect (You + IDE):** You plan the architecture, assign tasks, and make final decisions.
2. **Coder (Background Agent):** Writes code in an isolated Git branch.
3. **Hostile Reviewer (Strict Auditor):** An independent agent that reviews the Coder's work, **independently** runs tests, and checks for security vulnerabilities (OWASP).

## 🛠 How to use it in your project

1. **Initialization**
   Copy all files and folders from this repository (`.agents/`, `docs/`, `project-config.json`) into the root folder of your new project.

2. **Configure Commands (Stack-Agnostic)**
   Open the `project-config.json` file and enter the terminal commands specific to your stack (e.g., Node.js, Python, .NET). 
   ```json
   {
     "lint_cmd": "npm run lint",
     "build_cmd": "npm run build",
     "test_cmd": "npm test",
     "security_cmd": "npm audit"
   }
   ```
   *Note: If a check is configured as `null`, the system will BLOCK verification, demanding a real command.*

3. **Start the Architect**
   Open your project in the Antigravity IDE and type in the chat:
   > *"Start the commercial-flow and let's plan a new project"*

4. **Code Approval (Human Gate)**
   The agents (Coder and Reviewer) will work autonomously in the background (creating branches, writing code, running tests). After verification, you will receive an **Evidence Package** (a report with real test logs). You simply read the report and click the **"Proceed"** button, after which the AI will automatically merge the code into the `main` branch.

---

## 🇺🇦 Українська версія

Це комерційна архітектурна система для розробки програмного забезпечення за допомогою AI-агентів (Google Antigravity). 
Вона створена для того, щоб змусити штучний інтелект працювати як професійна команда інженерів: із суворим тестуванням, ізоляцією коду в гілках та наданням 100% реальних логів (доказів) працездатності замість "галюцинацій".

## 🚀 Що це таке?
Система розділяє роботу між трьома ролями:
1. **Architect (Ви + IDE):** Ви плануєте архітектуру, даєте завдання і приймаєте фінальні рішення.
2. **Coder (Фоновий агент):** Пише код в ізольованій Git-гілці.
3. **Hostile Reviewer (Суворий аудитор):** Незалежний агент, який перевіряє код Кодера, **самостійно** запускає тести та шукає вразливості безпеки (OWASP).

## 🛠 Як використовувати у вашому проекті

1. **Ініціалізація**
   Скопіюйте всі файли та папки з цього репозиторію (`.agents/`, `docs/`, `project-config.json`) у кореневу папку вашого нового проекту.

2. **Налаштування команд (Stack-Agnostic)**
   Відкрийте файл `project-config.json` та впишіть термінальні команди, характерні для вашого стеку (наприклад, Node.js, Python, .NET). 
   ```json
   {
     "lint_cmd": "npm run lint",
     "build_cmd": "npm run build",
     "test_cmd": "npm test",
     "security_cmd": "npm audit"
   }
   ```
   *Примітка: Якщо перевірка налаштована як `null`, система заблокує (BLOCKED) верифікацію, вимагаючи справжньої команди.*

3. **Запуск Architect**
   Відкрийте ваш проект в Antigravity IDE і напишіть у чат:
   > *"Запусти commercial-flow і давай планувати новий проект"*

4. **Затвердження коду (Human Gate)**
   Агенти (Coder та Reviewer) працюватимуть автономно у фоні (створюватимуть гілки, писатимуть код, перевірятимуть тести). Після перевірки ви отримаєте **Evidence Package** (звіт з реальними логами тестів). Ви просто читаєте звіт і натискаєте кнопку **"Proceed"**, після чого AI автоматично змерджить код у гілку `main`.
