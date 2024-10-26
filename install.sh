#if not exist, create .env file for docker with MySQL credentials
if [ ! -f ".env" ]; then 
    cp -rf ./src/docker_env.clean .env && \ 
    printf "\n" >> .env && printf "MYSQL_PASSWORD=" >> .env && openssl rand -base64 21 >> .env && \ 
    printf "\n"  && printf "MYSQL_ROOT_PASSWORD=" >> .env && openssl rand -base64 21 >> .env  && \ 
fi 

# create empty dir app
if ! test -d "app"; then 
    mkdir -p app
fi  

if [ ! "$(docker compose ps | grep app)" ]; then
    # start the containers
    docker compose up -d --build 
fi

if [ ! -f "app/.env" ]; then 
    #remove supervisor config  if exist
    if [ -f "./supervisor/conf.d/app.conf" ]; then 
        rm "./supervisor/conf.d/app.conf"
    fi

    #create clean laravel project
    docker compose exec app composer create-project laravel/laravel . --prefer-dist  
fi 

#supervisor config for laravel schedule and queue worker
if [ ! -f "./supervisor/conf.d/app.conf" ]; then 
    cp "./src/supervisor/conf.d/app.conf" "./supervisor/conf.d/app.conf" 
    docker compose up -d --build app && docker compose exec app supervisorctl reload 
fi


#get rid of original laravel .env and create a new one for mysql connection
if [  "$(docker compose ps | grep app)" ] && [  "$(docker compose ps | grep db)" ] && [ ! -f "app/DB_CONNECTION_MYSQL" ]; then 
    cp "./src/env-laravel.txt" "./app/.env" && \ 
    docker compose exec app php artisan key:generate && \  
    docker compose exec app php artisan migrate:fresh --seed && \
    docker compose exec app php artisan optimize:clear && \ 
    docker compose exec app npm install  && \ 
    docker compose exec app npm run build && \ 
    docker compose exec app php artisan storage:link  
    printf "1" >> "./app/DB_CONNECTION_MYSQL" 
fi 

if test -d "app/app"; then 
    sudo chown -R :www-data ./app && sudo chmod -R 775 ./app/storage && sudo chmod -R 775 ./app/database 
fi 
