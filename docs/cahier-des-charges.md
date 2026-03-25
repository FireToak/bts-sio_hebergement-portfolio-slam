# Cahier des charges : Infrastructure d'hébergement Web

![Bannière BTS SIO](assets/banniere_bts-sio.png)

## Informations

- **Auteur :** Louis MEDO
- **Date de création :** 25/03/2026

---
## 1. Contexte

Dans le cadre du BTS SIO, les étudiants doivent concevoir et mettre en ligne leur portfolio professionnel. L'objectif de ce projet est de déployer une infrastructure centralisée sur un serveur privé virtuel (VPS) permettant d'héberger ces sites web. Chaque étudiant disposera de son propre espace accessible via un sous-domaine nominatif. L'administration du serveur est strictement réservée au professeur référent, nécessitant la mise en place de processus de déploiement automatisés et sécurisés pour la mise à jour des portfolios.

---
## 2. Problématiques identifiées

- Comment héberger des sites dynamiques de façon fiable tout en cloisonnant les espaces de chaque étudiant ?
- Comment sécuriser le VPS contre les attaques informatiques (intrusions, déni de service) et garantir une reprise rapide après incident ?
- Comment automatiser la récupération des portfolios depuis les dépôts Git sans intervention manuelle sur le serveur, tout en gardant un contrôle sur les publications ?

---
## 3. Architectures

Nous avons fait le choix du prestataire **Infomaniak** pour l'hébergement de l'architecture du projet. Effectivement, son offre permet de bénéficier d'une infrastructure robuste pour un coût de 50€ par an avec un nom de domaine inclus. 

### 3.1 Zone DNS chez Infomaniak

Les éléments de configuration de la zone DNS :

- Enregistrement DNS `A` (IPv4) et `AAAA` (IPv6) génériques (Wildcard `*.bts-sio.eu`) pointant vers l'adresse IP publique du VPS `<insérer_hostname_vps>`.
- Enregistrement `CAA` pour restreindre les autorités de certification à émettre des certificats seulement via Let's Encrypt.

### 3.2 VPS chez Infomaniak

Les éléments du VPS `<insérer_hostname_vps>` :

- **Système d'exploitation :** Debian 13, choisi pour sa stabilité en environnement serveur.
- **Serveur web :** Apache2.
- **Espace de stockage :** 20GB
- **Mémoire vive :** 2GB
- **Bande passante :** 500Mo/s
- **Accès d'administration :** Protocole SSH restreint (authentification exclusive par paire de clés asymétriques Ed25519, utilisateur root désactivé).

### 3.3 Serveur web (Apache)

- **VirtualHosts (Hôtes virtuels) :** Configuration d'un fichier `.conf` par étudiant pour router le trafic du sous-domaine vers le bon dossier système (ex: `/var/www/portfolios/nom-prenom`).
- **Chiffrement (TLS) :** Génération et renouvellement automatisé des certificats HTTPS via Certbot (Let's Encrypt).
- **Cloisonnement des droits :** L'utilisateur `www-data` (Apache) aura uniquement des droits de lecture/exécution (`chmod 755` ou `555`) sur les fichiers web pour empêcher la modification de fichiers par des scripts malveillants.

---
## 4. Sécurité et sauvegarde

### 4.1 Mesures de sécurité

- **Pare-feu (UFW) :** Blocage strict de tout le trafic entrant par défaut. Seuls les ports 80 (HTTP), 443 (HTTPS) et un port 22 (SSH) seront ouverts.
- **Lutte contre le Bruteforce :** Déploiement de Crowdsec pour bannir temporairement les adresses IP tentant de forcer l'accès SSH ou Apache.
- **Sécurité Applicative :** Activation des en-têtes HTTP de sécurité (HSTS, X-Content-Type-Options, Content-Security-Policy) au niveau de la configuration globale d'Apache.

### 4.2 Plan de sauvegarde

- **Infrastructure as Code (IaC) :** Sauvegarde de l'intégralité des fichiers de configuration (fichiers Apache, scripts de déploiement, règles UFW) dans un dépôt Git privé externe.
- **Données Web :** Les codes sources des portfolios étant déjà versionnés sur Git, le serveur agit uniquement comme un miroir. En cas de crash, un script de provisionnement permettra de re-cloner l'ensemble des dépôts.

---
## 5. Workflow de déploiement des portfolios

Cette section recense deux scénarios possibles pour le déploiement automatisé des portfolios, basés sur une architecture "Push" (via Webhooks) pour optimiser les ressources du serveur.

### 5.1 Scénario A : Déploiement avec approbation (Validation professeur)

- **Fonctionnement :** L'étudiant développe sur une branche Git secondaire (ex: `dev`). Une fois son travail terminé, il crée une *Pull Request* (demande de fusion) vers la branche `main`.
- **Actions :** 
  1. Le professeur examine les modifications sur l'interface Git en ligne (GitHub/GitLab).
  2. S'il valide, il approuve la fusion (*Merge*).
  3. Cet événement de fusion déclenche un Webhook qui notifie le VPS.
  4. Le VPS exécute un script local réalisant un `git pull` sur le dossier de l'étudiant ciblé.

- **Avantage :** Contrôle total avant mise en production).

### 5.2 Scénario B : Déploiement continu (CI/CD)

- **Fonctionnement :** L'étudiant dispose des droits directs pour pousser (`git push`) ou fusionner son code sur la branche `main` de son dépôt.
- **Actions :**
  1. L'étudiant envoie son code sur la branche principale.
  2. Le dépôt Git envoie instantanément une requête HTTP (Webhook) au VPS.
  3. Le VPS s'authentifie, tire les nouvelles modifications et met à jour les fichiers web instantanément.

- **Avantage :** Responsabilisation de l'étudiant et fluidité, mais aucun contrôle préalable du code.