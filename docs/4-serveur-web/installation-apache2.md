# Cahier des charges : Infrastructure d'hébergement Web

![Bannière BTS SIO](../assets/banniere_bts-sio.png)

## Informations

- **Auteur :** Louis MEDO
- **Date de création :** 25/03/2026

---
## Contexte

Déploiement et sécurisation d'un serveur web Apache2 sur Debian 12 pour héberger les portfolios étudiants. La configuration applique le principe du moindre privilège (fichiers en lecture seule pour le service web), isole chaque projet via des VirtualHosts dédiés, et renforce la surface d'attaque avec des en-têtes HTTP stricts et un chiffrement TLS automatisé.

---
## Sommaire

1. Installation du serveur Web
2. Sécurité applicative (En-têtes HTTP)
3. Création de l'arborescence et cloisonnement des droits
4. Configuration du VirtualHost étudiant
5. Chiffrement TLS (Let's Encrypt)

---
## 1. Installation du serveur Web

1. **Installation d'Apache2.** Mise à jour des paquets et installation du service web principal.

    ```bash
    sudo apt update
    sudo apt install -y apache2
    ```

    `apt update` : Met à jour la liste des paquets disponibles sur les dépôts Debian.

    `apt install` : Installe le paquet spécifié.

    `-y` : Valide automatiquement les demandes de confirmation durant l'installation.

2. **Désactivation du VirtualHost par défaut.** Suppression de la page d'accueil d'installation d'Apache pour éviter d'exposer des informations sur le serveur et s'assurer que seuls les sites configurés répondent.

    ```Bash
    sudo a2dissite 000-default.conf
    sudo systemctl reload apache2
    ```

    `a2dissite (Apache2 Disable Site)` : Désactive un site en supprimant le lien symbolique correspondant dans le répertoire `/etc/apache2/sites-enabled/`.

    `systemctl reload` : Demande au service de recharger sa configuration à chaud, ce qui applique la désactivation sans interrompre les autres sites en cours d'exécution.

---
## 2. Sécurité applicative (En-têtes HTTP)

1. **Activation du module headers.** Permet à Apache de manipuler les en-têtes des requêtes et réponses HTTP.

    ```bash
    sudo a2enmod headers
    ```

    `a2enmod` (Apache2 Enable Module) : Crée un lien symbolique pour activer un module spécifique.

2. **Configuration des en-têtes de sécurité.** Édition du fichier de configuration global pour appliquer les directives de sécurité du cahier des charges.

    ```bash
    sudo nano /etc/apache2/conf-available/security.conf
    ```

    *Ajouter à la fin du fichier :*

    ```apache
    # Force le navigateur à utiliser HTTPS
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"
    # Empêche le navigateur de deviner le type MIME (protection contre le sniffing)
    Header always set X-Content-Type-Options "nosniff"
    # Restreint les sources autorisées à charger des ressources (scripts, images)
    Header always set Content-Security-Policy "default-src 'self';"
    ```

    `Header always set` : Ajoute l'en-tête spécifié à chaque réponse HTTP.

3. **Application des changements.**

    ```bash
    sudo systemctl restart apache2
    ```

    `systemctl restart` : Redémarre complètement le service pour appliquer la configuration globale.

---
## 3. Création de l'arborescence et cloisonnement des droits

1. **Création du dossier projet.** Préparation de l'espace de stockage pour un étudiant.

    ```bash
    sudo mkdir -p /var/www/portfolio_etu_nom
    ```

    `mkdir -p` : Crée le répertoire et ses parents s'ils n'existent pas.

2. **Configuration des permissions.** Application d'un accès en lecture seule pour Apache (`www-data`), empêchant la modification de fichiers par des scripts malveillants.

    ```bash
    sudo chown -R ton_utilisateur_de_deploiement:www-data /var/www/portfolio_etu_nom
    sudo find /var/www/portfolio_etu_nom -type d -exec chmod 750 {} \;
    sudo find /var/www/portfolio_etu_nom -type f -exec chmod 640 {} \;
    ```

    `chown -R` : Change le propriétaire et le groupe récursivement. Ici, ton utilisateur gère les fichiers, le groupe web (`www-data`) y accède.

    `find ... -type d -exec chmod 750` : Cherche les dossiers (`-type d`) et donne les droits de lecture/exécution (7) au propriétaire, et lecture/accès (5) au groupe web. Rien (0) pour les autres.

    `find ... -type f -exec chmod 640` : Cherche les fichiers (`-type f`) et donne les droits de lecture/écriture (6) au propriétaire, et uniquement lecture (4) au groupe web. 

---
## 4. Configuration du VirtualHost étudiant

1. **Création du fichier VHost.** Routage du trafic selon le nom de domaine.

    ```bash
    sudo nano /etc/apache2/sites-available/etu_nom.conf
    ```

    *Contenu :*

    ```apache
    <VirtualHost *:80>
        ServerName etu_nom.domaine_vps.ext
        DocumentRoot /var/www/portfolio_etu_nom

        <Directory /var/www/portfolio_etu_nom>
            AllowOverride None
            Require all granted
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/etu_nom_error.log
        CustomLog ${APACHE_LOG_DIR}/etu_nom_access.log combined
    </VirtualHost>
    ```

    `<VirtualHost *:80>` : Définit la configuration pour le port HTTP (80).

    `ServerName` : Le sous-domaine spécifique à l'étudiant.

    `DocumentRoot` : Le chemin vers les fichiers du site.

    `AllowOverride None` : Désactive l'utilisation des fichiers `.htaccess` pour des raisons de performance et de sécurité centralisée.

2. **Activation du site.**

    ```bash
    sudo a2ensite etu_nom.conf
    sudo systemctl reload apache2
    ```

    `a2ensite` (Apache2 Enable Site) : Active le VirtualHost.

    `systemctl reload` : Recharge la configuration à chaud sans interrompre les connexions en cours.

---
## 5. Chiffrement TLS (Let's Encrypt - Certificat Wildcard)

Voici la section rédigée avec un ton professionnel et intégrant l'automatisation complète de la zone DNS.

---
## 5. Chiffrement TLS (Let's Encrypt et API DNS)

L'infrastructure requiert des certificats Wildcard (`*.bts-sio.eu`) pour couvrir dynamiquement les sous-domaines des projets. La validation s'effectue par un challenge DNS (preuve de possession) automatisé via l'API de l'hébergeur (Infomaniak).

1. **Installation du client ACME et du module d'interface de programmation (API).** Mise en place de Certbot et de son greffon spécifique pour communiquer avec le fournisseur de nom de domaine.

    ```bash
    sudo apt install -y certbot python3-pip
    sudo pip3 install certbot-dns-infomaniak --break-system-packages
    ```

    `apt install` : Installe le client Certbot et le gestionnaire de paquets Python (`pip`).

    `pip3 install` : Télécharge le module d'intégration DNS Infomaniak.

    `--break-system-packages` : Autorise l'installation globale du paquet Python sur Debian 12 en dérogeant à la politique d'environnement virtuel strict.

2. **Sécurisation des identifiants d'authentification API.** Création et restriction d'accès au fichier contenant le jeton d'authentification (Token) de l'hébergeur.

    ```bash
    sudo mkdir -p /etc/letsencrypt
    echo "dns_infomaniak_token = TOKEN_API" | sudo tee /etc/letsencrypt/infomaniak.ini
    sudo chmod 600 /etc/letsencrypt/infomaniak.ini
    ```

    `echo ... | tee` : Écrit la variable et la valeur du token dans le fichier de configuration avec les privilèges administrateur.

    `chmod 600` : Restreint les droits de lecture et d'écriture au seul utilisateur `root` pour prévenir toute compromission du jeton d'API.

3. **Provisionnement automatisé du certificat Wildcard.** Lancement de la requête de création. Le module se connecte à l'API, crée l'enregistrement DNS TXT temporaire de validation, valide le domaine et supprime la trace DNS.

    ```bash
    sudo certbot certonly --authenticator dns-infomaniak --dns-infomaniak-credentials /etc/letsencrypt/infomaniak.ini -d "*.bts-sio.eu" -d "bts-sio.eu" --non-interactive --agree-tos -m contactn@bts-sio.eu
    ```

    `certonly` : Demande uniquement la génération du certificat sans modifier la configuration du serveur web.

    `--authenticator dns-infomaniak` : Délègue le challenge de validation au module Infomaniak.

    `--dns-infomaniak-credentials` : Cible le fichier sécurisé contenant le token API.

    `-d` : Spécifie les domaines à couvrir (Wildcard et domaine racine).

    `--non-interactive` : Exécute la commande sans demander de saisie utilisateur (idéal pour les scripts d'industrialisation).

    `--agree-tos -m` : Accepte les conditions d'utilisation et définit l'adresse de contact technique.

4. **Automatisation du cycle de vie (Renouvellement).** Planification d'une tâche de maintenance pour prolonger la validité des certificats avant leur expiration (90 jours) et application de la nouvelle cryptographie.

    ```bash
    sudo crontab -e
    ```

    *Ajouter la directive suivante :*

    ```bash
    0 3 * * * /usr/bin/certbot renew --quiet --post-hook "systemctl reload apache2"
    ```

    `0 3 * * *` : Déclenche le processus de contrôle quotidiennement à 03h00.

    `certbot renew` : Interroge l'autorité de certification pour renouveler les certificats expirant dans moins de 30 jours (l'API DNS sera appelée automatiquement).

    `--quiet` : Supprime les sorties standards (logs) sauf en cas d'erreur.

    `--post-hook` : Exécute le rechargement du service Apache2 (`systemctl reload`) de manière conditionnelle, uniquement si un certificat a été effectivement renouvelé.