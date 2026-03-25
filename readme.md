# Documentation - Hébergement externalisé des portfolios SLAM

![Bannière BTS SIO](docs/assets/banniere_bts-sio.png)

---

## Contexte

Ce dépôt Git héberge le code source de la documentation technique du projet d'infrastructure web pour les étudiants en BTS SIO (Lycée Paul-Louis Courier). Propulsée par **MkDocs** avec le thème Material, cette documentation centralise l'architecture, les configurations serveur (VPS Infomaniak, Apache) et les procédures d'exploitation (Runbooks). Le déploiement est automatisé via une pipeline d'intégration continue (GitHub Actions).

---

## Structure du projet

```text
.
├── .github/
│   └── workflows/
├── docs/
│   ├── assets/
│   ├── index.md
│   └── cahier-des-charges.md
└── mkdocs.yaml
````

  - **`.github/workflows/`** : Contient le pipeline CI/CD (`publish.yaml`) chargeant la génération et le déploiement automatique du site lors d'un *push* sur la branche `main`.
  - **`docs/`** : Répertoire source contenant les pages de la documentation au format Markdown (`.md`) ainsi que les médias dans le sous-dossier `assets/`.
  - **`mkdocs.yaml`** : Fichier de configuration principal définissant la navigation, le thème visuel et les extensions du site.

---

## Comment utiliser le projet en local

1.  **Cloner le dépôt et y accéder**

```bash
git clone <url_du_depot>
cd bts-sio_herbergement-portfolio-slam
```

  * **`git clone <url>`** : Télécharge une copie complète du dépôt distant sur ton poste de travail local.
  * **`cd <dossier>`** : (*Change Directory*) Modifie ton répertoire de travail actuel pour entrer dans le dossier du projet.

2.  **Installer les dépendances**

```bash
pip install mkdocs-material
```

  * **`pip install ...`** : Utilise le gestionnaire de paquets de Python pour télécharger et installer la bibliothèque `mkdocs-material`, requise pour compiler le site avec l'interface visuelle choisie.

3.  **Lancer le serveur de développement**

```bash
mkdocs serve
```

  * **`mkdocs serve`** : Démarre un mini-serveur web local (généralement accessible sur `http://127.0.0.1:8000`). Cette commande surveille tes fichiers et recharge automatiquement la page web dans ton navigateur dès que tu sauvegardes une modification dans un fichier Markdown. Idéal pour tester le rendu avant publication.

---

## Mainteneurs

**Louis MEDO** | [Linkedin](https://www.linkedin.com/in/louismedo/) | [Portfolio](https://louis.loutik.fr/) | [GitHub](https://github.com/FireToak)

---

<div align="center"\>
<br>
<small\><i\>Dernière mise à jour : 25 mars 2026</i\></small\>
</div\>