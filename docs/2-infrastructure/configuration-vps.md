# Initialisation du VPS Infomaniak

![Bannière BTS SIO](../assets/banniere_bts-sio.png)

## Informations

  - **Mainteneur :** Louis MEDO
  - **Date de création :** 28/03/2026

---

## Contexte

Cette procédure détaille la phase d'initialisation (Build) d'un serveur VPS sous Debian hébergé par Infomaniak. L'objectif est de préparer un socle système sécurisé, standardisé et prêt à accueillir le serveur web Apache, afin d'héberger les portfolios des étudiants en BTS SIO du lycée Paul-Louis Courier.

---

## Sommaire

1.  Ouverture des flux réseau (Pare-feu Infomaniak)
2.  Mise à jour et installation des paquets essentiels
3.  Configuration d'un MOTD dynamique
4.  Sécurisation du service SSH
5. Configuration de l'éditeur par défaut (Vim)
6.  Politique de gestion des accès administrateurs

---

## 1. Ouverture des flux réseau (Pare-feu Infomaniak)

1. **Autoriser le trafic Web.** Le serveur a pour vocation d'héberger des portfolios accessibles publiquement. Il faut ouvrir les ports de communication web depuis le pare-feu externe d'Infomaniak.

    ```bash
    # Action à réaliser sur l'interface cloud Infomaniak (Gestion du pare-feu VPS) :
    # 1. Autoriser le port TCP 80 (Trafic HTTP non chiffré)
    # 2. Autoriser le port TCP 443 (Trafic HTTPS chiffré)
    ```

---

## 2. Mise à jour et installation des paquets essentiels

1. **Actualiser le système et installer les utilitaires.** Il est fondamental de toujours travailler sur un système à jour pour combler les failles de sécurité, puis d'installer les outils de base d'administration.

    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y git curl wget vim htop
    ```

    `sudo` : Permet d'exécuter la commande avec les privilèges du super-administrateur (root).

    `apt update && sudo apt upgrade` : Met à jour la liste des paquets disponibles (`update`), puis installe les nouvelles versions (`upgrade`). L'opérateur `&&` permet de lier les deux commandes.

    `-y` : Option validant automatiquement les demandes de confirmation.

    `git` : Outil de versionning, indispensable pour automatiser la récupération des portfolios.

    `curl` / `wget` : Outils en ligne de commande pour télécharger des fichiers depuis des serveurs web.

    `vim` : Éditeur de texte avancé en console.

    `htop` : Moniteur interactif permettant de visualiser la consommation CPU/RAM du VPS.

---

## 3. Configuration d'un MOTD dynamique

1.  **Créer le script de Message of the Day (MOTD).** Le MOTD est le texte affiché à la connexion SSH. Un MOTD dynamique renvoie des informations système en temps réel et affiche les mentions légales d'accès.

    ```bash
    sudo truncate -s 0 /etc/motd
    sudo vim /etc/update-motd.d/99-custom
    ```

    `sudo truncate -s 0` : Désactive le MOTD par défaut de Debian.

    `/etc/update-motd.d/` : Dossier contenant les scripts exécutés à chaque nouvelle connexion.

2.  **Insérer le contenu du script bash.** Copiez ce bloc dans le fichier ouvert avec `vim`.

    👉 [Script MOTD pour les VPS](./motd.bash)

    `#!/bin/bash` : Indique au système que ce fichier doit être lu avec l'interpréteur de commandes Bash.

    `echo` : Affiche la chaîne de caractères sur la console de l'utilisateur.

    `$(...)` : Exécute la commande contenue à l'intérieur et affiche son résultat dynamique (ex: le nom de la machine avec `hostname`).

3.  **Rendre le script exécutable.**

    ```bash
    sudo chmod +x /etc/update-motd.d/99-custom
    ```

    `chmod +x` : Ajoute les droits d'exécution (`x`) au fichier pour que le système puisse le lancer.

4. **Tester le MOTD**

    ```bash
    sudo run-parts /etc/update-motd.d/
    ```

---

## 4. Sécurisation du service SSH

1.  **Durcir le fichier de configuration SSH.** L'hébergeur Infomaniak bloque par défaut les mots de passe. Il faut s'assurer que cette règle est bien présente et bloquer la connexion directe du compte "root".

    ```bash
    sudo vim /etc/ssh/sshd_config
    ```

    `sshd_config` : Fichier de configuration maître du démon (service) SSH.

2.  **Appliquer les règles de sécurité.** Vérifiez ou modifiez les lignes suivantes dans le fichier :

    ```text
    PermitRootLogin no
    PasswordAuthentication no
    ```

    `PermitRootLogin no` : Interdit la connexion directe en tant que super-administrateur, forçant l'utilisation d'un compte standard avec élévation de privilèges (`sudo`).

    `PasswordAuthentication no` : Interdit définitivement l'usage de mots de passe, rendant la connexion par clé cryptographique obligatoire.

3.  **Redémarrer le service.**

    ```bash
    sudo systemctl restart ssh
    ```

    `systemctl restart` : Relance le service pour appliquer la nouvelle configuration immédiatement.

---

## 5. Configuration de l'éditeur par défaut (Vim)

1.  **Définir Vim comme éditeur global.** Sur la distribution Debian, l'éditeur de texte par défaut (utilisé par des commandes comme `sudoedit` ou `visudo`) est souvent Nano. Afin d'uniformiser les environnements et de s'adapter aux standards d'administration système, nous le remplaçons par Vim pour l'ensemble des utilisateurs.

    ```bash
    sudo update-alternatives --set editor /usr/bin/vim.basic
    ```

    `update-alternatives` : Utilitaire natif de Debian permettant de gérer les liens symboliques déterminant les commandes par défaut du système (ici, l'éditeur de texte).

    `--set editor` : Argument forçant l'attribution de la fonction "éditeur" à un programme spécifique sans interaction manuelle.

    `/usr/bin/vim.basic` : Chemin absolu vers l'exécutable de base de Vim, garantissant que l'outil correct est appelé.

---

## 6. Politique de gestion des accès administrateurs

1.  **Désactiver le compte système par défaut.** Selon les règles de l'art, le partage de comptes (ex: utiliser tous le même utilisateur `debian`) est proscrit car cela empêche la traçabilité et l'auditabilité des actions. Chaque administrateur doit disposer de son propre compte nominatif (ex: `l.medo`). Une fois ces comptes créés, le compte générique fourni à l'installation doit être verrouillé.

    **⚠️ Attention ! Vérifiez bien que vos compte administrateur nominatif fonctionnent avant de désactiver le compte `debian`.

    ```bash
    sudo passwd -l debian
    ```

    `passwd -l` : L'argument `-l` (*Lock*) verrouille le compte utilisateur ciblé, empêchant toute future connexion avec celui-ci.

---

## Annexe

  - [Procédure : Création d'un utilisateur nominatif et configuration d'une clé SSH](../6-runbooks/creation-utilisateur-nominatif-vps.md)