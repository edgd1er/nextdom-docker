## Installation via docker

### Pre-requis

- docker installé
- .env, envMysql, envProd: renseigner les informations ports, mdp bdd, user

### Construction de l'image et lancement des services 

Aucune image docker existe pour le moment, il faut la construire via le script docker_prod.sh. 
Le script va egalement construire l'image et les conteneurs puis les lancer.

la configuration requise à la construction des conteneurs est dans .env, dans envWeb et envMysql,  y sont définies les variables accessibles au conteneur apache, 
la configuration envMysql pour le conteneur mysql.

la bdd et l'utilisateur sont crées lors de la création du conteneur mysql. Si vous voulez changer les mots de passe, ce qui est conseillé, les infos sensibles sont dans le envMysql et .env.

Pour mysql, dans le fichier envMysql, il faut changer les mots de passe root et user
 * MYSQL_ROOT_PASSWORD=changeItTwo
 * MYSQL_PASSWORD=changeIt

Pour le web, dans le fichier .env, il faut changer le mot de passe root et user mysql
* ROOT_PASSWORD=changeIt
* MYSQL_PASSWORD=changeIt

La variable ROOT_PASSWORD n'est utile que dans le cas d'utilisation du serveur SSH si il est installé.

Le script docker_prod.sh est adapté pour la production

Le données mysq sont dans le volume mysqldata-prod

### Parametres du docker_build.sh

options du script:

*	sans option, aucun acces aux périphériques.
s option, aucun acces aux périphériques.

*	p	le conteneur a accès à touts les périphériques (privileged: non recommandé)
*	u	le conteneur a accès au périphérique ttyUSB0
*	r	le conteneur sera dans la version de la dernière release. sinon sur la branch paramétrée.
*   z   le conteneur sera complété par le projet local au lieu d'un git clone.
*   k   le volume ( mysql) est conservé ainsi que son contenu.
*	h	Cette aide

### outils containers

* Verification de la configuration de la bdd

``docker-compose run --rm nextdom-web cat /var/www/html/core/config/common.config.php``

* Verification des users et hosts

```docker-compose run --rm nextdom-mysql /usr/bin/mysql -uroot -hlocalhost -pMnextdom96 -e 'select user,host from mysql.user;'```

#### Quand le système ne s'éxécute pas 
* Accès au conteneur web 

``` docker-compose run --rm nextdom-web bash```
* Accès au conteneur mysql

```docker-compose run --rm nextdom-mysql bash```

#### Quand le système s'éxécute 
* Accès au conteneur web 

```docker-compose exec nextdom-web bash```
* Accès au conteneur mysql

```docker-compose exec nextdom-mysql bash```

* Copie d'un backup dans le conteneur web depuis le repertoire install/OS_specific/Docker/prod/

```
docker cp ../../../../backup/backup-myNextom.mydomain.tld-date.time.tar.gz $(docker-compose ps -q nextdom-web):/var/www/html/backup/
```