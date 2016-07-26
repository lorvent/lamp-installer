# ubuntu lamp install script

## Major packages

- [x] apache 2.4
- [ ] php 7 (good if we have options)
  - [x] php 7
  - [ ] Old versions
- [ ] mysql-server
  - [x] latest
  - [ ] option to choose other versions
- [ ] phpmyadmin
  -  [x] using github download
  -  [ ] using apt-get
- [x] composer
- [x] memcached
  -  [ ] make it optional
- [x] redis
 -  [ ] make it optional
- [x] beanstalkd
  -  [ ] make it optional
- [x] git
- [x] virtualhost setup script
- [x] letsencrypt
- [x] oh-my-zsh
- [x] curl
- [x] nano

## php required plugins (everything needed for laravel)
- [x] mb-string
- [x] ext-dom (for phpunit)
- [x] mcrypt
- [x] php-json

## global node modules
- [x] npm
- [x] gulp
- [x] bower
- [x] gulp-bower
- [x] coffee-script
- [x] marked
- [x] jshint
- [x] node-gyp
- [x] node-sass


## Settings:
* upon on ssh, jump to /var/www/html
* ssh-keygen
* add swap memory
* create info.php with phpinfo();

## Clone repos (optional)
- [x] linux-dash
- [ ] laravel (for testing purpose)
