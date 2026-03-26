# Configuration d'Apache 2

![Bannière BTS SIO](../assets/banniere_bts-sio.png)

## Informations

- **Auteur :** Louis MEDO
- **Date de création :** 25/03/2026

---
## Contexte

Déploiement et sécurisation d'un serveur web Apache2 sur Debian 12 pour héberger les portfolios étudiants. La configuration applique le principe du moindre privilège, isole chaque projet via des VirtualHosts dédiés, et renforce la surface d'attaque avec des en-têtes HTTP stricts et un chiffrement TLS automatisé.

*Note : La procédure d'hébergement d'un portfolio est consultable en annexe.*

---
## Sommaire

1. Installation du serveur Web et des modules
2. Configuration du moteur PHP-FPM
3. Sécurité applicative (En-têtes HTTP)
4. Chiffrement TLS (Let's Encrypt et API DNS)

---
## 1. Installation du serveur Web et des modules

1. **Installation d'Apache2.** Mise à jour des paquets et installation du service web principal.

    ```bash
    sudo apt update
    sudo apt install -y apache2
    ```

    `apt update` : Met à jour la liste des paquets disponibles.
    `apt install` : Installe le paquet spécifié.
    `-y` : Valide automatiquement les demandes de confirmation.

2. **Désactivation des sites par défaut.** Suppression des pages d'accueil d'installation pour éviter d'exposer des informations sur le serveur.

    ```bash
    sudo a2dissite 000-default.conf default-ssl.conf
    ```

    `a2dissite` : Désactive un site en supprimant son lien symbolique de configuration.
    `000-default.conf` : Fichier de configuration du site HTTP par défaut.
    `default-ssl.conf` : Fichier de configuration du site sécurisé (HTTPS) par défaut.

3. **Activation des modules requis.** Activation des fonctionnalités nécessaires au chiffrement, à la performance et à la réécriture d'URL.

    ```bash
    sudo a2enmod ssl http2 headers rewrite
    ```

    `a2enmod` : Active un module Apache spécifique.
    `ssl` : Gère le protocole de chiffrement HTTPS.
    `http2` : Active le protocole HTTP/2 pour optimiser les performances de requêtage.
    `headers` : Permet la manipulation des en-têtes HTTP (nécessaire pour la sécurité).
    `rewrite` : Autorise la réécriture des URLs à la volée.

---
## 2. Configuration du moteur PHP-FPM

L'utilisation de PHP-FPM (FastCGI Process Manager) permet un traitement plus performant et isolé des scripts PHP par rapport au module Apache classique.

1. **Installation et interconnexion avec Apache.**

    ```bash
    sudo apt install -y php8.4-fpm 
    sudo a2enmod proxy_fcgi setenvif
    sudo a2enconf php8.4-fpm
    ```

    `php8.4-fpm` : Installe le service PHP 8.4 fonctionnant de manière autonome.
    `proxy_fcgi` et `setenvif` : Modules permettant de déléguer l'exécution du code PHP au service FPM.
    `a2enconf` : Active le fichier de configuration global liant Apache à PHP 8.4.

2. **Application des paramètres.**

    ```bash
    sudo systemctl reload apache2
    ```

    `systemctl reload` : Recharge la configuration d'Apache à chaud sans interrompre le service.

---
## 3. Sécurité applicative (En-têtes HTTP)

1. **Configuration des en-têtes de sécurité.** Édition du fichier de configuration global.

    ```bash
    sudo nano /etc/apache2/conf-available/security.conf
    ```

    *Ajouter à la fin du fichier :*

    ```apache
    # Force le navigateur à utiliser HTTPS
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"
    # Empêche le navigateur de deviner le type MIME (protection contre le sniffing)
    Header always set X-Content-Type-Options "nosniff"
    # Restreint les sources autorisées à charger des ressources
    Header always set Content-Security-Policy "default-src 'self';"
    ```

    `Header always set` : Ajoute l'en-tête de sécurité spécifié à chaque réponse HTTP.

2. **Vérification de la syntaxe et redémarrage.** S'assurer de la validité du code avant sa mise en production.

    ```bash
    sudo apachectl configtest
    sudo systemctl restart apache2
    ```

    `apachectl configtest` : Analyse la syntaxe des fichiers Apache (doit impérativement répondre `Syntax OK`).
    `systemctl restart` : Redémarre complètement le service pour appliquer la configuration de sécurité globale.

---
## 4. Chiffrement TLS (Let's Encrypt et API DNS)

L'infrastructure requiert des certificats Wildcard (`*.bts-sio.eu`). La validation s'effectue par un challenge DNS automatisé via l'API de l'hébergeur (Infomaniak).

1. **Installation du client ACME et de l'API.**

    ```bash
    sudo apt install -y certbot python3-pip
    sudo pip3 install certbot-dns-infomaniak --break-system-packages
    ```

    `certbot` : Client officiel pour l'obtention automatisée de certificats.
    `pip3 install` : Télécharge le module d'intégration DNS spécifique à Infomaniak.
    `--break-system-packages` : Force l'installation globale du paquet Python sur l'environnement système.

2. **Sécurisation des identifiants API.**

    ```bash
    sudo mkdir -p /etc/letsencrypt
    echo "dns_infomaniak_token = TOKEN_API" | sudo tee /etc/letsencrypt/infomaniak.ini
    sudo chmod 600 /etc/letsencrypt/infomaniak.ini
    ```

    `tee` : Écrit le jeton d'authentification dans le fichier cible avec les privilèges élevés.
    `chmod 600` : Restreint les droits de lecture et d'écriture au seul utilisateur administrateur (`root`).

3. **Provisionnement automatisé du certificat.**

    ```bash
    sudo certbot certonly --authenticator dns-infomaniak --dns-infomaniak-credentials /etc/letsencrypt/infomaniak.ini -d "*.bts-sio.eu" -d "bts-sio.eu" --non-interactive --agree-tos -m contact@bts-sio.eu
    ```

    `certonly` : Génère le certificat sans altérer la configuration d'Apache.
    `--authenticator dns-infomaniak` : Délègue la preuve de possession du domaine à l'API Infomaniak.
    `--non-interactive` : Exécute la commande de façon silencieuse sans invite utilisateur.
    `--agree-tos -m` : Valide les conditions d'utilisation et spécifie l'email de contact.

4. **Restriction d'accès aux clés cryptographiques.**

    ```bash
    sudo chmod 600 /etc/letsencrypt/live/bts-sio.eu/privkey.pem
    sudo chmod 644 /etc/letsencrypt/live/bts-sio.eu/fullchain.pem
    ```

    `privkey.pem` : Clé privée du certificat (droits `600` requis pour éviter toute compromission).
    `fullchain.pem` : Certificat public (droits `644` permettant la lecture par le service web).

5. **Automatisation du renouvellement.**

    ```bash
    sudo crontab -e
    ```

    *Ajouter la directive suivante :*

    ```bash
    0 3 * * * /usr/bin/certbot renew --quiet --post-hook "systemctl reload apache2"
    ```

    `crontab -e` : Édite la table de planification des tâches.
    `certbot renew` : Interroge l'autorité pour renouveler les certificats approchant de leur date d'expiration.
    `--quiet` : Masque les sorties standards dans les journaux.
    `--post-hook` : Action conditionnelle rechargeant Apache uniquement en cas de renouvellement effectif.

---
## Annexe

- [Déploiement portfolio étudiant](#)