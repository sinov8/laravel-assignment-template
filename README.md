# laravel-assignment-template
A basic starting point for a simple Laravel application

# Here are the basic steps you can follow to get this draft template up and running so you can start working on the actual assignment.

1) Fork the main branch of this repo to your own github account
2) Open the repo in your editor and run the following docker commands to build the containers:

```docker-compose build```

```docker-compose up -d```

This should create all the containers and spin them up:

![image](https://github.com/HeinHanekom/laravel-assignment-template-test/assets/7314385/736d6b85-58be-4f8a-b7c7-08c4890a10c2)

3) Then bash into the app container by running:
```docker-compose exec app bash```
 
4) Now you can install all the composer dependancies by doing

```composer install```

5) For the front-end you can run the following to install all the node dependancies

```docker-compose run --rm -w /var/www/html node npm install```

6) Then run dev or watch to build the assets
```docker-compose run --rm -w /var/www/html node npm run watch```

### Notes:

- Remember to make a copy of the .env.example file before you start coding but update the .example file as needed for commits.
- Then lastly you can generate your application key and run the migrations and clear your config caches and then you should be able to register and log in by navigating to the url: http://127.0.0.1:8080/
- If you do for some reason get an issue with the cache folder when starting out. try these steps here: https://laravelcode.com/post/failed-to-clear-cache-make-sure-you-have-the-appropriate-permissions-in-laravel


![image](https://github.com/sinov8/laravel-assignment-template/assets/7314385/b000b736-e5ad-4ebf-9ec2-31284d4bff91)

![image](https://github.com/sinov8/laravel-assignment-template/assets/7314385/f35f4493-95de-4699-88c5-abcf72a74cf2)
