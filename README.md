
# Docker пример

---
Установите и запустите Docker перед выполнением команд ниже.

#### 1. клонируем репозиторий
```
❯ git clone https://github.com/m-2k/docker-sample.git
```

#### 2. переходим в директорию проекта
```
❯ cd docker-sample
```

#### 3. собираем образ (docker image)
```
❯ docker build -t myapp .
```

#### 4. убедимся что образ собрался и загружен в docker
```
❯ docker images                           
REPOSITORY   TAG          IMAGE ID       CREATED              SIZE
myapp        latest       afbdc1c989f7   About a minute ago   103MB
```

#### 5. запустим образ в новом контейнере и в присоединенном режиме (attached mode), используя его идентификатор и пробросив порт `5010` нашей ОС (в которой запущен docker) на порт `5005` внутри контейнера (где работает наше приложение)
```
❯ docker run -p 5010:5005 myapp           
 * Serving Flask app 'app'
 * Debug mode: off
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5005
 * Running on http://172.17.0.2:5005
Press CTRL+C to quit
```

#### 6. перейдем по адресу `http://localhost:5010/` или `http://127.0.0.1:5010/` и убедимся, что приложение работает
#### 7. нажмем Ctrl+C в терминале который был присоединен к docker контейнеру, что приведет к завершению основного процесса контейнера и, следовательно, остановки всего контейнера

#### 8. запустим наш образ еще раз, также в контейнере, но в отсоединенном режиме (detached mode); теперь основной процесс контейнера не будет никак связан с терминалом из которого мы выполняли команды
```
❯ docker run -d -p 5010:5005 myapp
3984084f0d194788d560fea2dad8020e0617737f625079f0de0d63c8dfc88564
```

#### 9. глянем на список контейнеров внутри docker
```
❯ docker ps -a
CONTAINER ID   IMAGE          COMMAND            CREATED          STATUS                      PORTS                    NAMES
3984084f0d19   myapp          "python3 app.py"   9 minutes ago    Up 9 minutes                0.0.0.0:5010->5005/tcp   flamboyant_hopper
12a94ac114be   afbdc1c989f7   "python3 app.py"   21 minutes ago   Exited (1) 21 minutes ago                            sharp_hugle
```

#### 10. мы запустили до этого два контейнера с одним и тем же образом, но первый из них остановили завершив процесс `python3` (из присоединенной консоли через `Ctrl+C`); давайте удалим его чтобы не мешал используя его `CONTAINER ID`
```
❯ docker rm 12a94ac114be          
12a94ac114be
```

#### 11. либо воспользуемся командой которая удалит все текущие остановленные контейнеры
```
❯ docker container prune     
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
Deleted Containers:
12a94ac114be798038514ba61ce830feff2da0272fe8db9a4d57ee84f8d5b58b
Total reclaimed space: 0B
```

#### 12. остановка контейнера по его `CONTAINER ID`
```
❯ docker stop 3984084f0d19     
3984084f0d19
```

#### 13. запуск контейнера по его `CONTAINER ID`
```
❯ docker start 3984084f0d19
3984084f0d19
```

#### 14. посмотрим логи
```
❯ docker logs 3984084f0d19     
 * Serving Flask app 'app'
 * Debug mode: off
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5005
 * Running on http://172.17.0.2:5005
Press CTRL+C to quit
 * Serving Flask app 'app'
 * Debug mode: off
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5005
 * Running on http://172.17.0.2:5005
Press CTRL+C to quit
172.17.0.1 - - [16/Apr/2025 21:37:44] "GET / HTTP/1.1" 200 -
```
как видите, логи сохраняются и после перезапуска контейнера

#### 15. давайте удалим образ (docker image), но для начала посмотрим существующие
```
❯ docker images           
REPOSITORY   TAG          IMAGE ID       CREATED          SIZE
myapp        latest       d1ae4b79b6df   25 minutes ago   87MB
<none>       <none>       33cd75b87aa0   28 minutes ago   103MB
<none>       <none>       7b566a3fff56   30 minutes ago   103MB
```
как видите у них тоже (как и контейнеров) есть уникальные `IMAGE ID`

#### 16. d1ae4b79b6df - это последний, а два других - это старые версии. при загрузки одного и того же образа с одинаковым идентификатором образ затеняет остальные обезличивая их.
```
❯ docker images           
REPOSITORY   TAG          IMAGE ID       CREATED          SIZE
myapp        latest       d1ae4b79b6df   25 minutes ago   87MB
<none>       <none>       33cd75b87aa0   28 minutes ago   103MB
```

#### 17. удалим все образы у которых нет тегов (те что с тегами `<none>`), то есть старые версии загруженных образов (у вас их может не быть сейчас)
```
❯ docker image prune
WARNING! This will remove all dangling images.
Are you sure you want to continue? [y/N] y
Deleted Images:
deleted: sha256:33cd75b87aa0b76408896e973e23c8350141112d6857fb9e4a4f252895b43295
Deleted: sha256:7b566a3fff567333622e5fd4f7bd7b73324096a72f52258e147eb558a021bc27
Total reclaimed space: 0B
```

#### 18. давайте удалим образ `d1ae4b79b6df` который используется в нашем контейнере `3984084f0d19`
```
❯ docker rmi d1ae4b79b6df            
Error response from daemon: conflict: unable to delete d1ae4b79b6df (must be forced) - image is being used by stopped container 3984084f0d19
```

Как видите, этот образ пока еще необходим docker, чтобы работал контейнер; так как образ и является тем, что запускается при старте контейнера.

#### 19. Если мы хотим всё-таки удалить образ, нужно сначала удалить зависящий от него контейнер.
```
❯ docker ps -a           
CONTAINER ID   IMAGE     COMMAND            CREATED          STATUS                       PORTS     NAMES
3984084f0d19   myapp     "python3 app.py"   35 minutes ago   Exited (137) 8 minutes ago             flamboyant_hopper
                                                                                                                                                                   
❯ docker rm 3984084f0d19            
3984084f0d19

❯ docker rmi d1ae4b79b6df
Untagged: myapp:latest
Deleted: sha256:d1ae4b79b6df9747d559eaaccdae489803a3f4923af4d28c25d89d6323b27350
```

#### 20. создадим еще один образ но с расширенным тегом включающим в себя версию нашего приложения (`1.0`)
```
❯ docker build -t myapp:1.0 .
REPOSITORY   TAG          IMAGE ID       CREATED         SIZE
myapp        1.0          c69a6bee9818   2 minutes ago   87MB
```

#### 21. запустим его в контейнере на внешнем порту `7010`
```
❯ docker run -d -p 7010:5005 myapp:1.0
d89f4bfba7d00eab3c9259c1d7701eb5aee25359abd716c44c25d8bab98f07da
```

#### 22. напоследок, можете выгрузить образ из docker и сохранить на файловой системе в виде TAR-архива:
```
❯ docker save -o image-myapp-1.0.tar myapp:1.0
❯ ls -lah image*  
-rw-------@ 1 m  staff    87M Apr 17 01:15 image-myapp-1.1.tar
```