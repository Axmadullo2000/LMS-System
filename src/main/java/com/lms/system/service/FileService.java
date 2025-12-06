package com.lms.system.service;

import jakarta.servlet.http.Part;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.UUID;

public class FileService {

    private final Path uploadRoot;

    public FileService(String uploadDir) {
        this.uploadRoot = Paths.get(uploadDir).toAbsolutePath().normalize();

        try {
            Files.createDirectories(uploadRoot);
            System.out.println("✓ FileService initialized: " + uploadRoot);
        } catch (IOException e) {
            throw new RuntimeException("Не могу создать папку для файлов: " + uploadDir, e);
        }
    }

    /**
     * Загружает файл и возвращает Map с двумя ключами:
     * "path" → относительный путь для БД (uploads/students/123/...)
     * "name" → оригинальное имя файла (Мой отчёт.docx)
     */
    public Map<String, String> uploadFile(Part part, String userId) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }

        // 1. Получаем оригинальное имя файла
        String originalName = extractFileName(part);

        System.out.println("📤 Uploading file:");
        System.out.println("   Original name: " + originalName);
        System.out.println("   Size: " + part.getSize() + " bytes");
        System.out.println("   Content type: " + part.getContentType());

        // 2. Очищаем имя от опасных символов, но сохраняем читаемость
        String cleanName = sanitizeFileName(originalName);

        // 3. Генерируем уникальное имя для хранения
        String uniqueName = UUID.randomUUID() + "_" + cleanName;

        // 4. Создаём папку пользователя
        Path userDir = uploadRoot.resolve("students").resolve(userId);
        Files.createDirectories(userDir);

        Path targetPath = userDir.resolve(uniqueName);

        // 5. Сохраняем файл
        try (var in = part.getInputStream()) {
            Files.copy(in, targetPath);
            System.out.println("   ✓ File saved to: " + targetPath);
        } catch (IOException e) {
            System.err.println("   ❌ Failed to save file: " + e.getMessage());
            throw e;
        }

        // 6. Формируем результат
        String relativePath = "uploads/students/" + userId + "/" + uniqueName;

        System.out.println("   ✓ Upload complete:");
        System.out.println("     DB path: " + relativePath);
        System.out.println("     Original name: " + originalName);

        return Map.of(
                "path", relativePath,      // Для БД: uploads/students/123/uuid_file.pdf
                "name", originalName       // Для отображения: Мой документ.pdf
        );
    }

    /**
     * Извлекает оригинальное имя файла из Part
     */
    private String extractFileName(Part part) {
        // Способ 1: getSubmittedFileName()
        String submittedFileName = part.getSubmittedFileName();

        if (submittedFileName != null && !submittedFileName.isBlank()) {
            // Убираем путь, если браузер его добавил (старые IE/Edge)
            int lastSlash = Math.max(
                    submittedFileName.lastIndexOf('/'),
                    submittedFileName.lastIndexOf('\\')
            );
            if (lastSlash >= 0) {
                submittedFileName = submittedFileName.substring(lastSlash + 1);
            }
            return submittedFileName.trim();
        }

        // Способ 2: Парсим Content-Disposition заголовок
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition != null) {
            for (String token : contentDisposition.split(";")) {
                if (token.trim().startsWith("filename")) {
                    String fileName = token.substring(token.indexOf('=') + 1).trim()
                            .replaceAll("\"", "");
                    if (!fileName.isEmpty()) {
                        return fileName;
                    }
                }
            }
        }

        // Fallback: генерируем имя
        return "file_" + System.currentTimeMillis() + ".bin";
    }

    /**
     * Очищает имя файла от опасных символов
     * Сохраняет кириллицу и основные символы
     */
    private String sanitizeFileName(String fileName) {
        if (fileName == null || fileName.isBlank()) {
            return "file_" + System.currentTimeMillis() + ".bin";
        }

        // Убираем опасные символы для файловой системы
        String sanitized = fileName
                .replaceAll("[\\\\/:*?\"<>|]", "_")  // Запрещённые символы → _
                .replaceAll("\\s+", "_")              // Пробелы → _
                .replaceAll("_{2,}", "_")             // Множественные _ → один _
                .trim();

        // Если после очистки ничего не осталось
        if (sanitized.isEmpty() || sanitized.equals("_")) {
            return "file_" + System.currentTimeMillis() + ".bin";
        }

        // Ограничиваем длину (макс 200 символов)
        if (sanitized.length() > 200) {
            String extension = "";
            int lastDot = sanitized.lastIndexOf('.');
            if (lastDot > 0) {
                extension = sanitized.substring(lastDot);
                sanitized = sanitized.substring(0, lastDot);
            }
            sanitized = sanitized.substring(0, 200 - extension.length()) + extension;
        }

        return sanitized;
    }

    /**
     * Удаление файла (по относительному пути из БД)
     */
    public boolean deleteFile(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) {
            return false;
        }

        try {
            // Убираем "uploads/" если есть
            String normalized = relativePath;
            if (normalized.startsWith("uploads/")) {
                normalized = normalized.substring("uploads/".length());
            } else if (normalized.startsWith("/uploads/")) {
                normalized = normalized.substring("/uploads/".length());
            }

            Path path = uploadRoot.resolve(normalized).normalize();

            // Проверка безопасности (защита от path traversal)
            if (!path.startsWith(uploadRoot)) {
                System.err.println("⚠️ Delete blocked: path traversal attempt - " + relativePath);
                return false;
            }

            boolean deleted = Files.deleteIfExists(path);
            if (deleted) {
                System.out.println("✓ File deleted: " + path);
            } else {
                System.out.println("ℹ️ File not found (already deleted?): " + path);
            }
            return deleted;

        } catch (Exception e) {
            System.err.println("⚠️ Delete failed: " + e.getMessage());
            return false;
        }
    }

    /**
     * Проверяет существование файла
     */
    public boolean fileExists(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) {
            return false;
        }

        try {
            String normalized = relativePath;
            if (normalized.startsWith("uploads/")) {
                normalized = normalized.substring("uploads/".length());
            }

            Path path = uploadRoot.resolve(normalized).normalize();

            if (!path.startsWith(uploadRoot)) {
                return false;
            }

            return Files.exists(path) && Files.isRegularFile(path);

        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Получает размер файла в байтах
     */
    public long getFileSize(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) {
            return 0;
        }

        try {
            String normalized = relativePath;
            if (normalized.startsWith("uploads/")) {
                normalized = normalized.substring("uploads/".length());
            }

            Path path = uploadRoot.resolve(normalized).normalize();

            if (!path.startsWith(uploadRoot)) {
                return 0;
            }

            return Files.size(path);

        } catch (Exception e) {
            return 0;
        }
    }
}
