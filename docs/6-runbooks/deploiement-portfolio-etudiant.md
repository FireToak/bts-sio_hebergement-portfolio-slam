# Déploiement d'un Portfolio Étudiant

![Bannière BTS SIO](../assets/banniere_bts-sio.png)

## Informations

- **Auteur :** Louis MEDO
- **Date de création :** 26/03/2026

---
## Contexte

Procédure de déploiement d'un portfolio pour les étudiants du BTS SIO sur le serveur web Apache 2. Afin de prévenir toute élévation de privilèges ou mouvement latéral en cas de compromission d'un site étudiant, une politique de sécurité stricte est appliquée. Chaque portfolio dispose de son propre utilisateur système et d'un pool d'exécution PHP-FPM dédié, garantissant une isolation totale des environnements.

---
## Sommaire

1. Création du compte de service et de l'arborescence (Cloisonnement)
2. Configuration de l'isolation PHP-FPM
3. Déploiement du code source
4. Configuration du VirtualHost
5. Application et vérification

---
## 1. Création du compte de service et de l'arborescence (Cloisonnement)

Chaque étudiant se voit attribuer un utilisateur système sans droit de connexion. Le serveur web (`www-data`) est autorisé à lire les fichiers via une appartenance de groupe.

1. **Création de l'utilisateur dédié.** (Remplacer `<nom-prenom>` par l'identifiant de l'étudiant comme par exemple : `pierre-jean`).

    ```bash
    sudo adduser --system --group --disabled-login www-<nom-prenom>
    ```

    `adduser` : Crée un nouvel utilisateur et un groupe du même nom.

    `--system` : Définit le compte comme un compte de service (identifiant inférieur à 1000).

    `--disabled-login` : Interdit l'ouverture d'une session shell avec ce compte (sécurité).

2. **Ajout d'Apache au groupe de l'étudiant.**

    ```bash
    sudo usermod -aG www-<nom-prenom> www-data
    ```

    `usermod -aG` : Ajoute l'utilisateur système `www-data` (Apache) au groupe `www-<nom-prenom>` pour lui permettre de lire les fichiers statiques (HTML, CSS, images).

3. **Création du répertoire web et application des droits.**

    ```bash
    sudo mkdir -p /var/www/etu-nom/public_html
    sudo chown -R etu-nom:etu-nom /var/www/www-<nom-prenom>
    sudo chmod -R 750 /var/www/www-<nom-prenom>
    ```

    `mkdir -p` : Crée l'arborescence complète du répertoire cible.

    `chown -R` : Attribue la propriété du dossier et de son contenu à l'utilisateur et au groupe `etu-nom`.

    `chmod -R 750` : Accorde tous les droits au propriétaire (`7`), les droits de lecture et d'exécution au groupe (`5` - permet à Apache de lire), et aucun droit aux autres utilisateurs (`0`).

---
## 2. Configuration de l'isolation PHP-FPM

La création d'un "Pool" FPM spécifique force l'exécution des scripts PHP sous l'identité de l'étudiant, interdisant ainsi à un script malveillant de modifier les fichiers d'un autre étudiant ou du système.

1. **Création du fichier de configuration du pool.**

    ```bash
    sudoedit /etc/php/8.4/fpm/pool.d/www-<nom-prenom>.conf
    ```

2. **Ajout des directives de configuration.** 

    *Insérer le contenu suivant :*

    ```ini
    [etu-nom]
    user = www-<nom-prenom>
    group = www-<nom-prenom>

    listen = /run/php/php8.4-fpm-www-<nom-prenom>.sock
    listen.owner = www-data
    listen.group = www-data

    pm = dynamic
    pm.max_children = 5
    pm.start_servers = 2
    pm.min_spare_servers = 1
    pm.max_spare_servers = 3
    ```

    `[www-<nom-prenom>]` : Nomme le pool d'exécution.

    `user / group` : Définit l'identité sous laquelle le code PHP sera exécuté.

    `listen` : Crée un socket Unix unique pour la communication entre Apache et ce pool FPM précis.

    `listen.owner / group` : Autorise Apache (`www-data`) à transmettre des requêtes à ce socket.

    `pm.*` : Gère dynamiquement l'allocation de la mémoire et des processus pour ce portfolio.

---
## 3. Déploiement du code source

1. **Transfert des fichiers.** Copier les fichiers du portfolio de l'étudiant dans le répertoire `/var/www/www-<nom-prenom>/public_html/`.

2. **Sécurisation finale des fichiers.** S'assurer que les droits sont corrects après l'importation.

    ```bash
    sudo chown -R www-<nom-prenom>:www-<nom-prenom> /var/www/www-<nom-prenom>/public_html
    sudo find /var/www/www-<nom-prenom>/public_html -type d -exec chmod 750 {} \;
    sudo find /var/www/www-<nom-prenom>/public_html -type f -exec chmod 640 {} \;
    ```

    `find -type d -exec chmod 750` : Applique les droits de lecture/exécution (accès) uniquement aux dossiers.

    `find -type f -exec chmod 640` : Rend les fichiers lisibles, mais non exécutables directement par le système.

---
## 4. Configuration du VirtualHost

Pour router le trafic vers le bon dossier et le bon socket PHP, un hôte virtuel doit être créé.

1. **Création du fichier de configuration.**

    ```bash
    sudoedit /etc/apache2/sites-available/www-<nom-prenom>.conf
    ```

2. **Application du modèle.** Copier le contenu du modèle standardisé et remplacer les variables d'environnement (nom de domaine, chemins et socket FPM).

    👉 [Consulter le Template de configuration VirtualHost](./template-virtualhost-apache.conf)

---
## 5. Application et vérification

1. **Activation du site.**

    ```bash
    sudo a2ensite www-<nom-prenom>.conf
    ```

    `a2ensite` : Crée le lien symbolique activant le nouveau VirtualHost.

2. **Validation et redémarrage des services.**

    ```bash
    sudo apachectl configtest
    sudo systemctl restart php8.4-fpm
    sudo systemctl reload apache2
    ```

    `apachectl configtest` : Vérifie l'absence d'erreurs de syntaxe dans les configurations d'hôtes virtuels.

    `systemctl restart php8.4-fpm` : Démarre le nouveau pool d'isolation dédié à l'étudiant.

    `systemctl reload apache2` : Prend en compte le nouveau site web de manière transparente.