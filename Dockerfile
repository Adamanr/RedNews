# Установите актуальную версию Elixir (В данный момент 1.18.1)
FROM elixir:1.18.1

# Установите Hex и Rebar (пакетные менеджеры для Elixir)
RUN mix local.hex --force && mix local.rebar --force

# Установите Node.js и npm (для фронтенда Phoenix)
RUN apt-get update && apt-get install -y \
    curl \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Установите inotify-tools для Phoenix (для событий в файловой системе)
RUN apt-get update && apt-get install -y inotify-tools

# Установите Phoenix (Актуальная версия проекта - 1.7.18)
RUN mix archive.install hex phx_new 1.7.18 --force

# Установите рабочую директорию
WORKDIR /app

# Скопируйте файлы проекта
COPY . .

# Установите зависимости
RUN mix deps.get && mix assets.deploy

# Соберите приложение
RUN mix compile

# Открываем порт для Phoenix (по умолчанию 4000)
EXPOSE 4000


# Команда для запуска приложения
CMD ["mix", "phx.server"]


RUN echo 'Готово! Приятной работы =)'
