# Используем официальный Python-образ
FROM python:3.11-slim

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем Rust, если вдруг понадобится для dev (но не используем в прод)
# RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Создаём директорию приложения
WORKDIR /app

# Копируем requirements
COPY requirements.txt .

# Обновляем pip и заранее ставим только бинарные версии pydantic и pydantic-core
RUN pip install --upgrade pip \
 && pip install --only-binary :all: \
    "pydantic==2.5.3" \
    "pydantic-core==2.14.6"

# Устанавливаем зависимости проекта
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь код проекта
COPY . .

# Указываем порт, если нужно (Render сам пробрасывает PORT)
EXPOSE 10000

# Команда запуска
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:10000", "main:app"]
