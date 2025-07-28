FROM python:3.11-slim

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl libffi-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/*

# Создаём рабочую директорию
WORKDIR /app

# Обновляем pip и устанавливаем бинарные версии pydantic и pydantic-core заранее
RUN pip install --upgrade pip

# Устанавливаем pydantic и pydantic-core отдельно — только бинарники
RUN pip install --only-binary=:all: \
    "pydantic-core==2.14.6" \
    "pydantic==2.5.3"

# Копируем остальное и устанавливаем
COPY requirements.txt .
RUN pip install --no-cache-dir --no-build-isolation -r requirements.txt

# Копируем проект
COPY . .

# Порт и команда запуска
EXPOSE 10000
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:10000", "main:app"]
