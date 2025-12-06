# Markdown #LMS — Система управления обучением (Moodle-подобная)

## Полноценная учебная платформа, написанная **без Spring Framework** — чистый Jakarta EE 10+, сервлеты, JSP и Hibernate как JPA-провайдер.

## Возможности

- Три роли: **Администратор · Преподаватель · Студент**
- Регистрация / вход в систему
- Создание курсов и групп
- Назначение преподавателей и студентов в группы
- Создание домашних заданий с дедлайном и файлами
- Загрузка и скачивание решений студентами и преподавателями
- Полная поддержка кириллицы в именах файлов
- Современный адаптивный интерфейс (Bootstrap 5 + градиенты + анимации)
- Автоматическое создание дефолтного администратора при первом запуске

## Технологии (100% без Spring)

| Слой                  | Технология                                      |
|-----------------------|-------------------------------------------------|
| Язык                  | Java 17+                                        |
| Спецификация          | **Jakarta EE 10**                               |
| Servlet               | Jakarta Servlet 6.0                             |
| JSP / JSTL            | Jakarta Server Pages 4.0 + Jakarta Tags         |
| JPA                   | Jakarta Persistence 3.1 (Hibernate 6+)          |
| Validation            | Jakarta Bean Validation 3.0                     |
| База данных           | PostgreSQL 15+                                  |
| Сборщик               | Maven                                           |
| Контейнер             | Apache Tomcat 10.1+                             |
| DI / Инициализация    | Ручная через `@WebListener` + синглтоны         |
| Хеширование паролей   | В процессе внедрения BCrypt                     |
| Frontend              | Bootstrap 5, Bootstrap Icons, кастомный CSS/JS  |
| Аннотации             | Lombok                                          |

## Структура проекта
src/main/java/com/lms/system/
├── model/          → JPA-сущности (User, Admin, Teacher, Student, Group, Assignment, Submission)
├── repository/repository/    → DAO-синглтоны с EntityManager
├── service/        → Бизнес-логика (StudentService, TeacherService, Admin*.java и др.)
├── listeners/      → ApplicationInitializer (@WebListener) — запуск приложения
├── servlet/        → Все @WebServlet (AuthServlet, AdminPanelServlet, FileDownloadServlet и т.д.)
├── util/           → JPAUtil, FileService, SecurityUtil и др.
└── enums/          → UserRole, AssignmentStatus и т.п.
src/main/webapp/
├── WEB-INF/views/         → JSP-страницы по ролям (admin/, teacher/, student/, common/)
├── resources/css|js|img/
├── uploads/               → Файлы заданий и решений (создаётся автоматически)
└── index.jsp
text## persistence.xml (Jakarta EE 10)

```xml
<persistence-unit name="MOODLE_LMS">
    <provider>org.hibernate.jpa.HibernatePersistenceProvider</provider>
    <class>com.lms.system.model.User</class>
    ...
    <properties>
        <property name="jakarta.persistence.jdbc.url" value="jdbc:postgresql://localhost:5432/lms_moodle_system"/>
        <property name="jakarta.persistence.jdbc.user" value="postgres"/>
        <property name="jakarta.persistence.jdbc.password" value="2001"/>
        <property name="hibernate.dialect" value="org.hibernate.dialect.PostgreSQLDialect"/>
        <property name="hibernate.show_sql" value="true"/>
    </properties>
</persistence-unit>
Как запустить
Bash# 1. Клонируем
git clone https://github.com/твой-ник/lms-moodle-system.git
cd lms-moodle-system

# 2. Создаём БД в PostgreSQL
createdb lms_moodle_system
psql -d lms_moodle_system -c "CREATE SCHEMA lms;"

# 3. Собираем WAR
mvn clean package

# 4. Запускаем (два варианта):
#    • Через Tomcat 10+
copy target/lms.war /path/to/tomcat/webapps/
#    • Или через Maven плагин:
mvn tomcat10:run
После запуска открываем: http://localhost:8080/lms
Логин по умолчанию:
admin@lms.com / admin123
Особенности реализации

Полностью ручная инициализация EntityManagerFactory в JPAUtil
Все сервисы и репозитории регистрируются в ServletContext через @WebListener
Никаких @Autowired, @Component, @SpringBootApplication — чистый Jakarta EE
Поддержка кириллицы в загружаемых/скачиваемых файлах (через URLEncoder + Content-Disposition)
