# Костылик для запуска grafana-oss в контейнере

Данный репозиторий - домашняя работа "на троечку" (да, я такой) по интенсиву Docker 24.

Скрипты запуска и останова контейнеров используют относительные пути,
у пользователя, их запускающиего, должно быть достаточно прав на каталог,
откуда выполняется запуск.

start.sh создаст необходимые сети и контейнеры, а так же директории монтирования
для хранения данных приложений. При остановке контейнера он будет
автоматически удалён. Используются образы grafana-oss и postgres16-alpine.

stop.sh останавливает контейнеры и удаляет созданные ранее сети.