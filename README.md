# docker-images-php-builder

Docker Images | PHP Builder (php, node, compose, etc)

## Authentification

* Prérequis

Créer un "Personal Access Token" > https://github.com/settings/tokens

> Go to your GitHub account settings.
> Navigate to Developer settings > Personal access tokens.
> Create a new token with sufficient permissions 
> * write:packages
> * delete:packages

* Docker Login

```
GHCR_USERNAME="XXX"
GHCR_PAT="XXX"
echo $GHCR_PAT | docker login ghcr.io -u GHCR_USERNAME --password-stdin
```

## Préparation

```
# Tagguer l'image
docker build -t ghcr.io/maloups/docker-images-php-builder:dev .
docker push ghcr.io/maloups/docker-images-php-builder:dev
```

## Github Administration - Public Docker Image

1- Désactiver "Inherit access from source repository" > https://github.com/settings/packages
2- Sélectionner le package concerné > https://github.com/maloups?tab=packages
3- Package Setting > Danger Zone > Change Visibility
