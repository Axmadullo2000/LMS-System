<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Создать пользователя</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }

        .container {
            max-width: 700px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        h1 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
        }

        .error {
            background: #fee;
            border: 1px solid #fcc;
            color: #c33;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #333;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        input[type="text"]:focus,
        input[type="email"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #667eea;
        }

        .radio-group {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .radio-option {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .radio-option input[type="radio"] {
            width: auto;
        }

        .row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .hint {
            font-size: 12px;
            color: #666;
            margin-top: 3px;
        }

        .teacher-fields {
            display: none;
            padding: 15px;
            background: #f9f9f9;
            border-radius: 4px;
            margin-top: 10px;
        }

        .admin-warning {
            display: none;
            padding: 12px;
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 4px;
            color: #856404;
            margin-top: 10px;
        }

        .buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: #667eea;
            color: white;
        }

        .btn-primary:hover {
            background: #5568d3;
        }

        .btn-secondary {
            background: #e0e0e0;
            color: #333;
        }

        .btn-secondary:hover {
            background: #d0d0d0;
        }

        @media (max-width: 600px) {
            .row {
                grid-template-columns: 1fr;
            }

            .radio-group {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Создать нового пользователя</h1>

    <c:if test="${not empty error}">
        <div class="error">
            <strong>Ошибка:</strong> ${error}
        </div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/admin/users/create" id="userForm">

        <div class="form-group">
            <label>Тип пользователя *</label>
            <div class="radio-group">
                <div class="radio-option">
                    <input type="radio" name="userType" id="student" value="student"
                    ${empty userType or userType == 'student' ? 'checked' : ''} required>
                    <label for="student">Студент</label>
                </div>
                <div class="radio-option">
                    <input type="radio" name="userType" id="teacher" value="teacher"
                    ${userType == 'teacher' ? 'checked' : ''} required>
                    <label for="teacher">Преподаватель</label>
                </div>
                <div class="radio-option">
                    <input type="radio" name="userType" id="admin" value="admin"
                    ${userType == 'admin' ? 'checked' : ''} required>
                    <label for="admin">Администратор</label>
                </div>
            </div>
        </div>

        <div class="form-group">
            <label for="fullName">Полное имя *</label>
            <input type="text" id="fullName" name="fullName" value="${fullName}"
                   placeholder="Введите полное имя" required>
        </div>

        <div class="form-group">
            <label for="email">Email *</label>
            <input type="email" id="email" name="email" value="${email}"
                   placeholder="user@example.com" required>
        </div>

        <div class="row">
            <div class="form-group">
                <label for="password">Пароль *</label>
                <input type="password" id="password" name="password"
                       placeholder="Минимум 6 символов" minlength="6" required>
                <div class="hint">Минимум 6 символов</div>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Подтвердите пароль *</label>
                <input type="password" id="confirmPassword" name="confirmPassword"
                       placeholder="Повторите пароль" minlength="6" required>
            </div>
        </div>

        <div id="teacherFields" class="teacher-fields">
            <div class="form-group">
                <label for="specialization">Специализация</label>
                <input type="text" id="specialization" name="specialization"
                       placeholder="Например: Математика, Программирование">
                <div class="hint">Область экспертизы преподавателя</div>
            </div>
        </div>

        <div id="adminWarning" class="admin-warning">
            <strong>⚠ Внимание:</strong> Учетная запись администратора имеет полный доступ к системе.
        </div>

        <div class="buttons">
            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">
                Отмена
            </a>
            <button type="submit" class="btn btn-primary">
                Создать пользователя
            </button>
        </div>
    </form>
</div>

<script>
    const teacherRadio = document.getElementById('teacher');
    const adminRadio = document.getElementById('admin');
    const studentRadio = document.getElementById('student');
    const teacherFields = document.getElementById('teacherFields');
    const adminWarning = document.getElementById('adminWarning');

    function updateFields() {
        teacherFields.style.display = 'none';
        adminWarning.style.display = 'none';

        if (teacherRadio.checked) {
            teacherFields.style.display = 'block';
        } else if (adminRadio.checked) {
            adminWarning.style.display = 'block';
        }
    }

    studentRadio.addEventListener('change', updateFields);
    teacherRadio.addEventListener('change', updateFields);
    adminRadio.addEventListener('change', updateFields);

    updateFields();

    document.getElementById('userForm').addEventListener('submit', function(e) {
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (password !== confirmPassword) {
            e.preventDefault();
            alert('Пароли не совпадают!');
            document.getElementById('confirmPassword').focus();
            return false;
        }
    });
</script>
</body>
</html>