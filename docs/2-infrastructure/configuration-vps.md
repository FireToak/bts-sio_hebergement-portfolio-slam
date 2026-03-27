# # Configuration Initiale d'un Serveur VPS

![Bannière BTS SIO](../assets/banniere_bts-sio.png)

## Informations

  - **Auteur :** Louis MEDO
  - **Date de création :** 26/03/2026

---

## Contexte

Procédure de configuration initiale d'un serveur VPS hébergé chez Infomaniak. L'environnement par défaut utilise le compte `debian`, la connexion par mot de passe est désactivée et le pare-feu est géré de manière externe via l'interface d'administration Infomaniak. L'objectif est de provisionner les outils de base, de créer un accès administrateur nominatif sécurisé et d'établir un message d'accueil (MOTD) rappelant le cadre légal et les bonnes pratiques.

---

## Sommaire

1.  Mise à jour du système et installation des paquets de base
2.  Création du compte administrateur nominatif
3.  Définition du message d'accueil (MOTD)
4.  Sécurisation renforcée du service SSH

---

## 1. Mise à jour du système et installation des paquets de base

1.  **Mise à jour des dépôts et des paquets existants.**

    ```bash
    sudo apt update && sudo apt upgrade -y
    ```

    `apt update` : Met à jour l'index local des paquets disponibles depuis les dépôts.

    `apt upgrade` : Installe les nouvelles versions des paquets déjà présents sur le système.

    `-y` : Valide automatiquement les demandes de confirmation lors de l'installation.

    `&&` : Exécute la seconde commande uniquement si la première a réussi.

2.  **Installation des outils de base.**

    ```bash
    sudo apt install -y git curl wget vim htop
    ```

    `apt install` : Commande d'installation de nouveaux paquets.

    `git` : Système de contrôle de version.

    `curl` / `wget` : Outils de transfert de données et de téléchargement en ligne de commande.

    `vim` : Éditeur de texte avancé en console.

    `htop` : Moniteur système interactif (variante améliorée de `top`).

---
## 2. Création du compte administrateur nominatif

La gestion par le compte générique `debian` doit être remplacée par un compte nominatif. La connexion SSH par mot de passe étant bloquée chez Infomaniak, il faut copier la clé SSH publique vers le nouveau compte.

1.  **Création de l'utilisateur nominatif sur le système.**

    ```bash
    sudo adduser <nom-prenom>
    ```

    `adduser` : Script interactif qui crée l'utilisateur, son répertoire personnel (`/home/louis`) et demande la définition d'un mot de passe (qui servira pour l'élévation de privilèges, pas pour la connexion).

2.  **Attribution des droits d'administration.**

    ```bash
    sudo usermod -aG sudo <nom-prenom>
    ```

    `usermod -aG` : Modifie les propriétés de l'utilisateur pour l'Ajouter (`-a`) à un Groupe (`-G`) supplémentaire.

    `sudo` : Groupe système conférant les droits d'exécution de commandes en tant que super-utilisateur.

3.  **Mise en place des clés SSH.**

    ```
    A faire
    ```

---

## 3. Définition du message d'accueil (MOTD)

Le *Message Of The Day* s'affiche à chaque connexion SSH. Il sert à identifier la machine et à rappeler les règles de sécurité.

1.  **Édition du fichier dynamique du MOTD.**

    ```bash
    sudo nano /etc/motd
    ```

    `nano` : Éditeur de texte simple en ligne de commande.

    `/etc/motd` : Fichier système contenant le texte brut affiché à la connexion.

2.  **Insertion du contenu.** 

    *Copier/coller le texte suivant :*

    ```text
    +-----------------------------------------------------+
    |                 VPS PORTFOLIO BTS                   |
    +-----------------------------------------------------+

    /!\ AVERTISSEMENT LÉGAL /!\
    L'accès à ce système informatique est strictement réservé
    aux personnes expressément autorisées. Tout accès ou 
    maintien frauduleux fera l'objet de poursuites pénales.

    *** BONNES PRATIQUES D'ADMINISTRATION LINUX ***
    1. Attention aux commandes destructrices (ex: rm -rf).
    2. Sauvegardez TOUJOURS avant modification : 
       cp config.conf config.conf.bak
    3. Documentez chaque modification de configuration.
    4. Limitez l'usage de 'sudo' au strict nécessaire.
    ```

---

## 4. Sécurisation renforcée du service SSH

Bien que l'installation Infomaniak soit déjà restrictive, il convient de figer les bonnes pratiques dans la configuration du démon SSH.

1.  **Édition du fichier de configuration SSH.**

    ```bash
    sudo nano /etc/ssh/sshd_config
    ```

2.  **Vérification et application des paramètres de sécurité.** *S'assurer que les lignes suivantes existent et sont décommentées :*

    ```ini
    PermitRootLogin no
    PasswordAuthentication no
    ```

    `PermitRootLogin no` : Interdit formellement la connexion directe avec le compte super-utilisateur (`root`). Les attaques ciblent majoritairement ce compte.
    
    `PasswordAuthentication no` : Refuse l'authentification par mot de passe, rendant obligatoire l'usage d'une clé cryptographique SSH.

3.  **Application de la nouvelle configuration.**

    ```bash
    sudo systemctl restart ssh
    ```

    `systemctl restart` : Commande du gestionnaire de services `systemd` permettant de redémarrer le service spécifié (`ssh`) pour qu'il lise ses nouveaux fichiers de configuration.