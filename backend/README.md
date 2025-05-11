# Установка и настройка PostgreSQL и pgAdmin4

## Установка PostgreSQL

### Windows
1. Скачайте установщик PostgreSQL с [официального сайта](https://www.postgresql.org/download/windows/)
2. Запустите установщик и следуйте инструкциям:
   - Выберите компоненты для установки (PostgreSQL Server, pgAdmin 4, Stack Builder, Command Line Tools)
   - Укажите директорию для установки
   - Задайте пароль для пользователя postgres (суперпользователь)
   - Укажите порт (по умолчанию 5432)
   - Выберите локаль (обычно default)
3. После установки PostgreSQL будет запущен как служба Windows

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

### macOS
```bash
brew install postgresql
```

## Установка pgAdmin4 (если не установлен вместе с PostgreSQL)

### Windows
1. Скачайте установщик pgAdmin4 с [официального сайта](https://www.pgadmin.org/download/pgadmin-4-windows/)
2. Запустите установщик и следуйте инструкциям

### Linux (Ubuntu/Debian)
```bash
sudo apt install pgadmin4
```

### macOS
```bash
brew install --cask pgadmin4
```

## Проверка установки

1. Запустите pgAdmin4
2. При первом запуске вам будет предложено установить мастер-пароль для pgAdmin4
3. После этого вы увидите интерфейс pgAdmin4
4. Нажмите правой кнопкой мыши на "Servers" и выберите "Create" -> "Server..."
5. На вкладке "General" введите имя сервера (например, "Local PostgreSQL")
6. На вкладке "Connection" введите:
   - Host name/address: localhost
   - Port: 5432
   - Maintenance database: postgres
   - Username: postgres
   - Password: (пароль, который вы указали при установке)
7. Нажмите "Save"
8. Если соединение успешно установлено, вы увидите сервер в дереве слева

## Создание базы данных

1. В pgAdmin4 нажмите правой кнопкой мыши на "Databases" под вашим сервером
2. Выберите "Create" -> "Database..."
3. Введите имя базы данных (например, "crm_db")
4. Нажмите "Save"

Альтернативно, вы можете создать базу данных с помощью SQL-скрипта:
```sql
CREATE DATABASE crm_db;
```

## Создание таблиц

Для создания таблиц вы можете использовать SQL-скрипты из файла `create_tables.sql` в этой директории.
