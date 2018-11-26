## Installation via docker

### Description

Ce document décrit l'utilisation des scripts de construction des deux conteneurs docker pour le développement de Nextdom. un conteneur s'occupe du serveur Mysql, le second contient tout les outils pour les devs, comme le ferait une VM. Cela permet de recompiler les css, js et autres plus rapidement avec l'inconvénient de prendre beaucoup plus de place et de ne pas utiliser la flexibilité docker.

Pour info le dossier prod, décrit la manière et propose les scripts pour créer les conteneurs plus proche de ce que propose docker.

### Pre-requis

- docker installé
- .env: renseigner les informations mdp bdd, user, token github

### Construction de l'image et lancement des services 

Aucune image docker existe pour le moment, il faut la construire via le script docker_build.sh. 
Le script va egalement construire l'image et les conteneurs et les lancer.

toute la configguration est dans le fichier .env

les infos sensibles sont données en ARG de build ( mdp bdd ) et ne restent pas disponibles dans le conteneur à l'éxécution.

/!\ particularité du au dépot privé, il faut lancer le init.sh dans le conteneur nextdom-dev pour avoir les invites (login/pwd) git du projet. 

le script docker_build.sh est adapté pour le developpement.

le script docker_multi.sh est adapté pour la production


### Parametres du docker_build.sh

options du script:

*	sans option, aucun acces aux périphériques.
*	p	le conteneur a accès à touts les périphériques (privileged: non recommandé)
*	u	le conteneur a accès au périphérique ttyUSB0
*   z   le conteneur sera complété par le projet local au lieu d'un git clone.
*	h	This help

### Acces aux containers

* nextdom-dev (serveur apache/php) est accessible en ssh .
* nextdom-mysql est accessible via mysql sur le port 3326.

##