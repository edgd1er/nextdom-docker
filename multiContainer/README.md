## Installation via docker

### Description

4 type d'installations sont possibles

* From debian package

Mode fourre-tout, docker est utilisé comme une machine virtuelle sans utiliser ses capacités. Aucune optimisation n'est appliquée. Cette méthode permet d'avoir la version packagée par la team.

* from github source for dev

 Mode fourre tout egalement, c'est a dire sans utiliser les capacités de docker, ici on crée deux conteneurs (web, mysql), et l'application est récupérée depuis le dépot github.
 
 Chaque dossier contient un README détaille chaque solution.

* from github minimal install for prod

la configuration est optimisée pour tirer partie des spécifités de docker ( volume, conf externalisée, taille d'image réduite). un script est fourni pour créer et lancer les deux conteneurs.

