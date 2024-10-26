# Laravel-installer (devlopment environment)

In order to install a fresh instance of Laravel, simply clone the repo and run ./install.sh

## Requirements
- linux
- docker
- docker-compose

### Tips:
Run install.sh as super user: ```sudo install.sh```

Or, make sure that your user is in docker group, then run install: ```install.sh```

### Info

Docker compose stack defines following services:
- webserver (nginx);
- app (php:8.2-fpm-buster + composer + nodejs ). This is the place where it will be installed Laravel framework;
- db ( mysql:8);
- mysqlbackup (selim13/automysqlbackup).

In the "src" folder of the repo, thre's a file named "docker_env.clean". Before running install.sh, you might want to edit this file in order to change the prts of the http server and mysql server, that will we exposed to the host machine.
