<div align="center">

# Todo List App

Flutter приложение для формирования групповых и приватных списков с широкой кастомизацией пользовательского интерфейса

[Основные особенности](#-основные-особенности) •
[Используемый стек](#-используемый-стек) •
[Демо](#%EF%B8%8F-демо)

</div>

## 📋 Основные особенности

- Аутентификация пользователей
- Приватные/личные списки для одного пользователя и общие, для всех людей в группе
- Фильтрация и сортировка задач
- Система рассылки уведомлений
- Широкая кастомизация графики на основе 3 тем
  - Material
  - Animated90s
  - Glassmorphism
  
### Material
![material](github_assets/material.png)

### Animated90s
![Animated90s](github_assets/animated90s.gif)

### Glassmophism
![glassmorphism](github_assets/glassmorphism.png)

## 📦 Используемый стек

- Архитектура - MVC/BLoC
- Менеджер состояний/зависимостей - [Get](https://pub.dev/packages/get)
- Shared Preferences - [Get Storage](https://pub.dev/packages/get_storage) 
- Бэкенд - [Firebase](https://firebase.google.com/)
  - БД - [Firestore](https://firebase.google.com/docs/firestore) и [Storage](https://firebase.google.com/docs/storage)
  - Аутентификация пользователей - [Authentication Firebase](https://firebase.google.com/docs/auth)
  - Сервис рассылки оповещений - [Firebase Messaging](https://firebase.google.com/docs/cloud-messaging)
  - Небольшой собственный сервер на java с использованием [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup), который нужен для формирования и отправки оповещений (используя [API FMC](https://firebase.google.com/docs/cloud-messaging)) о новой задаче другим пользователям
- Тестирование [NoSQL Firestore](https://firebase.google.com/docs/firestore) - Mock библиотека [Fake Cloud Firestore](https://pub.dev/packages/fake_cloud_firestore) 

## 🎞️ Демо

### Пример одновременного использования с 2 аккаунтов и разных устройств - web chrome и necrophone Samsung A20 (ЦП Samsung Exynos) 💩
https://user-images.githubusercontent.com/30704653/149622544-3231bcba-c1f5-4d76-b86b-0a6e349baf22.mp4

### Кастомизация тем на Samsung S9 (ссылка на youtube, жалко сжимать до 10мб, чтобы залить напрямую на страницу😭)
[![Theme Customization](github_assets/Theme_customization.jpg)](https://www.youtube.com/watch?v=topItmnXg20 "Theme customization")

### Изменение профиля
https://user-images.githubusercontent.com/30704653/149626910-05941e5e-cd8e-428b-87f3-a8fcf0676b94.mp4