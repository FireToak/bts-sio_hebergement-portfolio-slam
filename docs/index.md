# 📚 Accueil

![Bannière BTS SIO](assets/banniere_bts-sio.png)

Bienvenue sur le portail de documentation technique dédié à l'**hébergement externalisé des portfolios étudiants**. Ce wiki centralise l'architecture, les configurations et les procédures d'exploitation du projet.

---
## 🏢 Contexte et Enjeux

Les étudiants doivent concevoir et déployer un portfolio professionnel dynamique (PHP, bases de données, etc.). Face à l'absence de solutions gratuites répondant aux exigences techniques et de sécurité de la formation, une infrastructure sur-mesure a été déployée. Reposant sur un Serveur Privé Virtuel (VPS) et le nom de domaine **bts-sio.eu**, elle garantit un hébergement professionnel, isolé et performant pour chaque étudiant.

---
## 🎞️ Architecture et Flux de Données

![Schéma - Fonctionnement de l'hébergement des portfolios](assets/schéma_fonctionnement-hebergement-portfolio.png)
*Architecture de résolution et de routage des requêtes HTTP*

**Fonctionnement de l'infrastructure :**

1. **Résolution DNS :** Le navigateur du client effectue une requête vers les serveurs faisant autorité d'Infomaniak. La zone DNS traduit le sous-domaine de l'étudiant (ex: `jean-pierre.bts-sio.eu`) en adresse IP (IPv4 ou IPv6) pointant vers le VPS.

2. **Routage HTTP/Web :** Le client envoie sa requête web au VPS. Le service **Apache** réceptionne la demande et, grâce à sa configuration en **VirtualHosts**, identifie le sous-domaine ciblé pour servir le bon dossier système contenant les fichiers web de l'étudiant, tout en isolant les environnements.

---
## 💡 Naviguer dans la documentation

Cette documentation est structurée selon les standards de l'industrie (de la conception à l'exploitation) pour faciliter la recherche d'informations.

### 📂 Arborescence de la documentation

* **🏠 Vue d'ensemble** : Contexte et architecture globale.
* **🏗️ Infrastructure** : Configuration DNS et paramètres du VPS.
* **🔒 Sécurité** : Durcissement serveur (Fail2ban, Crowdsec, UWF).
* **⚙️ Serveur Web** : Déploiement d'Apache et des VirtualHosts.
* **🚀 CI/CD** : Automatisation des mises à jour Git via Webhooks.
* **📘 Runbooks** :
    * Gérer les accès SSH (Création et connexion).
    * Déployer le portfolio d'un nouvel étudiant.
    * Procédures de sauvegarde et restauration.

### 📌 Guide de navigation

- **Phase d'initialisation (Build) :** Suivez l'ordre chronologique de **Infrastructure** à **CI/CD** pour monter le serveur de zéro.
- **Phase d'exploitation (Run) :** Référez-vous directement aux **Runbooks** pour les opérations quotidiennes ou la résolution d'incidents.