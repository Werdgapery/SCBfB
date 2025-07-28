FROM python:3.11-slim

# Системные зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libffi-dev libssl-dev curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Обновляем pip и ставим pydantic и pydantic-core из бинарников
RUN pip install --upgrade pip \
 && pip install --only-binary=:all: \
      "pydantic-core==2.14.6" \
      "pydantic==2.5.3"

# Копируем requirements без pydantic-core
COPY requirements.txt .

# Удаляем pydantic-core из requirements, если он там есть
RUN grep -v "pydantic-core" requirements.txt > clean_requirements.txt

# Устанавливаем зависимости
RUN pip install --no-cache-dir -r clean_requirements.txt

# Копируем весь проект
COPY . .

EXPOSE 10000

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:10000", "main:app"]
