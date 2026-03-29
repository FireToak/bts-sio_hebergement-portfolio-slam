# Configuration du pipeline CI/CD GitHub Actions

![Bannière BTS SIO](../assets/banniere_bts-sio.png)

## Informations

  - **Mainteneur :** Louis MEDO
  - **Date de création :** 29/03/2026

-----

## Contexte

Ce document décrit la configuration de l'organisation GitHub pour automatiser le déploiement continu (CI/CD) des portfolios étudiants. Il permet à GitHub d'initier une connexion sécurisée vers le serveur virtuel via une clé SSH unique d'organisation afin de déclencher la mise à jour du code dynamiquement, sans exposer aucune donnée sensible dans les dépôts ou les journaux d'exécution publics.

---

## Sommaire

1.  Configuration des secrets d'organisation sur GitHub
2.  Création du fichier de workflow d'automatisation (CI/CD)

---

## 1. Configuration des secrets d'organisation sur GitHub

1.  **Enregistrement centralisé des identifiants.** Pour ne pas exposer l'adresse du serveur et la clé de sécurité, et pour éviter de les répéter dans chaque dépôt, nous devons les stocker au niveau de l'organisation. GitHub chiffre ces données et les masque automatiquement (en affichant `***`) dans les logs publics des pipelines. Naviguez sur la page de l'organisation GitHub :

    **`Settings` > `Secrets and variables` > `Actions` > `New organization secret`**.

      - **VPS_HOST** : Créez ce secret et renseignez l'adresse IP publique du serveur Infomaniak comme valeur.

      - **SSH_PRIVATE_KEY** : Créez ce secret et collez-y l'intégralité de la clé privée Ed25519 (qui correspond à la clé publique configurée sur le compte `github-deploy-portfolio` du VPS).

    *Note : Lors de la création, choisissez une politique d'accès (Access policy) autorisant les dépôts de votre choix à utiliser ces secrets.*

---

## 2. Création du fichier de workflow d'automatisation (CI/CD)

1.  **Création du pipeline de déploiement YAML.** Dans le dossier racine du projet de l'étudiant, créez l'arborescence requise par GitHub et ajoutez le fichier de configuration définissant les actions à exécuter lors d'un envoi de code.

    ```bash
    mkdir -p .github/workflows
    nano .github/workflows/deploy.yml
    ```

    `mkdir -p` : Crée le répertoire `.github` et son sous-répertoire `workflows`. L'option `-p` permet de créer toute l'arborescence d'un coup sans erreur si elle existe déjà.

    `nano` : Ouvre l'éditeur de texte en ligne de commande pour créer ou modifier le fichier `deploy.yml`.

    *Note : un template est disponible dans les dépôts de l'organisation sur GitHub pour éviter de devoir remettre la github Action à la main.*

2.  **Déclaration des instructions du pipeline.** Insérez le code suivant. Ce code utilise les secrets de l'organisation pour s'authentifier et transmet dynamiquement le nom du dépôt au script Wrapper du VPS.

    ```yaml
    name: Déploiement du Portfolio
    on:
      push:
        branches:
          - main
    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
          - name: Connexion SSH et déclenchement du Wrapper
            uses: appleboy/ssh-action@v1.0.3
            with:
              host: ${{ secrets.VPS_HOST }}
              username: github-deploy-portfolio
              key: ${{ secrets.SSH_PRIVATE_KEY }}
              script: ${{ github.event.repository.name }}
    ```

    `on: push: branches: - main` : Déclencheur. Le pipeline s'exécute automatiquement lorsqu'une modification est poussée sur la branche principale (`main`).

    `runs-on: ubuntu-latest` : Alloue un environnement éphémère Linux chez GitHub pour exécuter l'action.

    `uses: appleboy/ssh-action` : Utilise une action préconçue pour établir la connexion SSH.

    `host`, `key` : Appellent de manière sécurisée les valeurs stockées dans les secrets de l'organisation.

    `username: github-deploy-portfolio` : Spécifie le compte de service restreint à utiliser sur le VPS.

    `script: ${{ github.event.repository.name }}` : Variable native de GitHub Actions. Elle injecte automatiquement le nom exact du dépôt en cours (ex: "portfolio-louis"). C'est cette valeur qui sera interceptée par le script Wrapper sur le VPS pour savoir quel dossier mettre à jour.

---

## Annexe

  - [Documentation GitHub - Variables de contexte)](https://docs.github.com/fr/actions/learn-github-actions/contexts%23github-context)