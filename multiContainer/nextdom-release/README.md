## Installation via docker

### Pre-requis

- docker installé
- .env, envMysql, envProd, githubtoken.txt: renseigner les informations ports, mdp bdd, user, token github

### Construction de l'image et lancement des services 

Cette image est construite a partir des scripts js, css compilés de nextdom, donc destinée à la production.
il faut la construire via le script docker_release.sh.

l'image ne contient que la partie apache, php, et execution des shells. 

Le script ne fait qu'encapsuler les commandes docker-composer avec des parametres.

la configuration requise à la construction des conteneurs est dans .env, dans envWeb et envMysql,  y sont définies les variables accessibles au conteneur apache, 
la configuration envMysql pour le conteneur mysql.

la bdd et l'utilisateur sont crées lors de la création du conteneur mysql. Si vous voulez changer les mots de passe, ce qui est conseillé, les infos sensibles sont dans le envMysql et .env.


Pour mysql, dans le fichier envMysql, il faut changer les mots de passe root et user
 * MYSQL_ROOT_PASSWORD=changeItTwo
 * MYSQL_PASSWORD=changeIt)

Pour le web, dans le fichier .env, il faut changer le mot de passe root
* ROOT_PASSWORD=changeIt

Cette variable n'est utile que dans le cas d'utilisation du serveur SSH si il est installé

### Parametres du docker_release.sh

options du script:

*	sans option, aucun acces aux périphériques.
*	TODO p	le conteneur a accès à touts les périphériques (privileged: non recommandé)
*	TODO u	le conteneur a accès au périphérique ttyUSB0
*	TODO m	le conteneur est en mode démo ou dev (disponible uniquement avec les paquets debian)
*   z   le conteneur sera complété par le projet local au lieu d'un git clone.
*   k   les volumes ( web et mysql) sont conservés ainsi que leurs contenus.
*	h	This help

### Lancement par docker

docker run 
    -e ROOT_PASSWORD=changeIt
    -e BRANCH=develop \
    -e VERSIONTAG=0.0.6
    -e ROOT_PASSWORD= \
    -e MYSQL_HOST=nextdom-mysql \
    -e MYSQL_PORT=3306 \
    -e MYSQL_DATABASE=nextdomdb \
    -e MYSQL_USER=nextdom_user \
    -e MYSQL_PASSWORD=changeIt \
    -e TZDATA=Europe/Paris \
    -p "9280:80"
    -p "9643:443"
    edgd1er/nextdom:0.0.6
    
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
docker cp backup/backup-myNextom.mydomain.tld-date.time.tar.gz $(docker-compose ps -q nextdom-web):/var/www/html/backup/
```