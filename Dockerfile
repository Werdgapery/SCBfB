# Используем официальный образ Python с Rust
FROM python:3.11-slim

# Установим system deps
RUN apt-get update && apt-get install -y \
    gcc \
    cargo \
    libffi-dev \
    libssl-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Создаём рабочую директорию
WORKDIR /app

# Копируем зависимости
COPY requirements.txt .

# Устанавливаем зависимости
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Копируем весь проект
COPY . .

# Указываем команду запуска
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8000"]
