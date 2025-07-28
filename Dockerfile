# Используем Python 3.11 с минимальной базой
FROM python:3.11-slim

# Установим нужные пакеты, включая Rust (cargo)
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    libffi-dev \
    libssl-dev \
    build-essential \
    cargo \
    && rm -rf /var/lib/apt/lists/*

    ENV CARGO_HOME=/tmp/cargo

# Установим pip-зависимости
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --only-binary :all: --upgrade pydantic-core pydantic
RUN pip install -r requirements.txt

# Копируем весь проект
COPY . .

# Команда запуска сервера
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8000"]
