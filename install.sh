cp -rf .env.clean .env && \
printf "\n" >> .env && printf "MYSQL_PASSWORD=" >> .env && openssl rand -base64 21 >> .env && \
printf "\n"  && printf "MYSQL_ROOT_PASSWORD=" >> .env && openssl rand -base64 21 >> .env  && \
mkdir -p app && \ 
docker-compose down && \
cp "./Dockerfile-php8-no-supervisor" "./app/Dockerfile" && \
docker-compose up -d --build && \
rm "./app/Dockerfile" && \ 
docker-compose exec app composer create-project laravel/laravel . --prefer-dist  && \
cp "./env-laravel.txt" "./app/.env" && \
docker-compose exec app php artisan key:generate && \ 
docker-compose exec app php artisan optimize:clear && \
docker-compose exec app php artisan migrate:fresh --seed && \
docker-compose exec app npm install  && \
docker-compose exec app npm run build && \
docker-compose exec app php artisan storage:link && \
chmod -R 0744 app/storage && \
cp "./Dockerfile-php8-supervisor" "./app/Dockerfile" && \
docker-compose up -d --build && \
docker-compose exec app supervisorctl reload
