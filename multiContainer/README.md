## Installation via docker

### Description

2 type d'installations sont possibles

* From debian package

Mode fourre-tout, docker est utilisé comme une machine virtuelle sans utiliser ses capacités. Aucune optimisation n'est appliquée. Cette méthode permet d'avoir la version packagée par la team.

* from github-multistage pour la production


la configuration est optimisée pour tirer partie des spécifités de docker ( volume, conf externalisée, taille d'image réduite). un script est fourni pour créer et lancer les deux conteneurs.

