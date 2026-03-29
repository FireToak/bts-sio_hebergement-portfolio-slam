# Préparation du VPS pour le CI/CD

![Bannière BTS SIO](../assets/banniere_bts-sio.png)

## Informations

  - **Mainteneur :** Louis MEDO
  - **Date de création :** 29/03/2026

-----

## Contexte

Ce document décrit les étapes nécessaires pour configurer le serveur VPS afin de recevoir les déploiements automatisés depuis GitHub Actions. L'objectif est de créer un utilisateur système restreint couplé à un script de sécurité (Wrapper) permettant d'utiliser une seule clé SSH d'organisation pour déployer dynamiquement tous les portfolios de la classe, sans compromettre le cloisonnement du serveur.

-----

## Sommaire

1.  Création du compte de service restreint
2.  Cloisonnement des droits sur les dossiers web
3.  Création du script Wrapper de sécurité
4.  Verrouillage de la clé SSH

---

## 1. Création du compte de service restreint

1.  **Créer un utilisateur dédié sans mot de passe.** Nous créons un utilisateur nommé `github-deploy-portfolio` qui servira uniquement aux automatisations.

    ```bash
    sudo adduser --disabled-password --gecos "" github-deploy-portfolio
    ```

    `sudo` : Exécute la commande avec les droits d'administrateur.

    `adduser` : Utilitaire pour créer un nouvel utilisateur système.

    `--disabled-password` : Empêche la connexion par mot de passe, forçant l'utilisation exclusive d'une clé SSH asymétrique pour se connecter.

    `--gecos ""` : Ignore les questions interactives (nom, numéro de téléphone) lors de la création.

---

## 2. Cloisonnement des droits sur les dossiers web

1.  **Attribuer la propriété des dossiers au compte de service.** Le dossier contenant les portfolios doit pouvoir être modifié par l'utilisateur CI/CD, tout en restant lisible par le serveur web Apache (`www-data`).

    ```bash
    sudo chown -R github-deploy-portfolio:www-data /var/www/portfolios/
    ```

    `chown` : Commande pour modifier le propriétaire (CHange OWNer).

    `-R` : Applique la modification de manière récursive à tous les sous-dossiers et fichiers.

    `github-deploy-portfolio:www-data` : Définit `github-deploy-portfolio` comme propriétaire principal et `www-data` comme groupe propriétaire.

2.  **Verrouiller les permissions (Principe de moindre privilège).**

    ```bash
    sudo chmod -R 754 /var/www/portfolios/
    ```

    `chmod` : Modifie les permissions d'accès aux fichiers.

    `754` : Le propriétaire a tous les droits (7 = lire, écrire, exécuter), le groupe web peut lire et exécuter (5), et les autres utilisateurs du système peuvent uniquement lire (4).

---

## 3. Création du script Wrapper de sécurité

1.  **Rédiger le script d'interception.** Ce script va récupérer le nom du dépôt envoyé par GitHub et empêcher les attaques par injection de chemin.

    ```bash
    sudo su - github-deploy-portfolio
    mkdir ~/scripts
    nano ~/scripts/deploy_wrapper.sh
    ```

    `su - github-deploy-portfolio` : Bascule sur la session de notre nouvel utilisateur.

    `mkdir` : Crée le répertoire `scripts`.

    `nano` : Ouvre un éditeur de texte dans le terminal.

2.  **Ajouter la logique de déploiement.** Insérez le code suivant dans le fichier `deploy_wrapper.sh` :

    ```bash
    #!/bin/bash
    ETUDIANT="$SSH_ORIGINAL_COMMAND"

    if [[ ! "$ETUDIANT" =~ ^[a-zA-Z0-9-]+$ ]]; then
        exit 1
    fi

    git -C "/var/www/portfolios/$ETUDIANT" pull origin main
    ```

    `#!/bin/bash` : Indique au système d'utiliser Bash pour exécuter le script.

    `$SSH_ORIGINAL_COMMAND` : Variable système contenant le texte exact envoyé par GitHub (ici, le nom du dépôt).

    `=~ ^[a-zA-Z0-9-]+$` : Expression régulière (Regex) de sécurité. Elle vérifie que le nom contient *uniquement* des lettres, chiffres et tirets.

    `exit 1` : Arrête immédiatement le script avec une erreur si la validation échoue.

    `git -C ... pull ...` : Le flag `-C` indique à Git de se déplacer dans le dossier spécifique à l'étudiant avant de télécharger les modifications.

3.  **Rendre le script exécutable.**

    ```bash
    chmod +x ~/scripts/deploy_wrapper.sh
    ```

    `+x` : Ajoute le droit d'exécution au fichier.

---

## 4. Verrouillage de la clé SSH

1.  **Préparer le répertoire SSH de l'utilisateur.**

    ```bash
    mkdir ~/.ssh
    chmod 700 ~/.ssh
    nano ~/.ssh/authorized_keys
    ```

    `chmod 700` : Restreint l'accès au dossier contenant les clés de sécurité au seul propriétaire (lecture, écriture, exécution).

2.  **Ajouter et restreindre la clé publique de l'organisation GitHub.** Collez la clé publique Ed25519 dans `authorized_keys`.**Avant** le texte de la clé, ajoutez les options de restriction pour forcer l'utilisation du wrapper :

    ```text
    command="/home/github-deploy-portfolio/scripts/deploy_wrapper.sh",no-pty,no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-ed25519 AAAAC3...
    ```

    `command="..."` : Redirige de force toute connexion utilisant cette clé vers notre script `deploy_wrapper.sh`.

    `no-pty` : Interdit l'attribution d'un terminal interactif.
    
    `no-port-forwarding` / `no-X11-forwarding` / `no-agent-forwarding` : Bloque les fonctionnalités avancées de SSH pour empêcher la création de tunnels réseaux malveillants.

---

## Annexe

  - [Documentation OpenSSH - Format du fichier authorized_keys](https://man.openbsd.org/sshd.8%23AUTHORIZED_KEYS_FILE_FORMAT)