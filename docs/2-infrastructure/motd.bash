#!/bin/bash
# ---
# Titre       : MOTD VPS - Lycée Paul-Louis Courier
# Auteur      : Louis MEDO
# Date        : 28/03/2026
# Rôle        : Affiche les informations système et les bonnes pratiques lors de la connexion SSH
# ---

# ─── Couleurs ───────────────────────────────────────────────────────────────
RESET="\e[0m"
BOLD="\e[1m"
CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
WHITE="\e[97m"
DIM="\e[2m"

# ─── Collecte des informations système ──────────────────────────────────────
KERNEL=$(uname -r)
DEBIAN_VERSION=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
HOSTNAME=$(hostname -f 2>/dev/null || hostname)
UPTIME=$(uptime -p 2>/dev/null | sed 's/up //')
DATE=$(date "+%A %d %B %Y, %H:%M:%S")

# Stockage (partition racine)
DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
DISK_USED=$(df -h / | awk 'NR==2{print $3}')
DISK_AVAIL=$(df -h / | awk 'NR==2{print $4}')
DISK_PCT=$(df / | awk 'NR==2{print $5}' | tr -d '%')

# RAM
RAM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
RAM_USED=$(free -h | awk '/^Mem:/{print $3}')
RAM_AVAIL=$(free -h | awk '/^Mem:/{print $7}')
RAM_PCT=$(free | awk '/^Mem:/{printf "%.0f", $3/$2*100}')

# Charge CPU
LOAD=$(cut -d' ' -f1-3 /proc/loadavg)

# Adresse IP locale
IP_LOCAL=$(hostname -I 2>/dev/null | awk '{print $1}')

# Nombre de processus
PROCS=$(ps aux --no-header | wc -l)

# Sessions SSH actives
SSH_SESSIONS=$(who | wc -l)

# ─── Fonction barre de progression ──────────────────────────────────────────
progress_bar() {
    local PCT=$1
    local FILLED=$(( PCT / 5 ))
    local EMPTY=$(( 20 - FILLED ))
    local BAR=""

    if [ "$PCT" -ge 85 ]; then
        COLOR=$RED
    elif [ "$PCT" -ge 60 ]; then
        COLOR=$YELLOW
    else
        COLOR=$GREEN
    fi

    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

    echo -e "${COLOR}${BAR}${RESET} ${BOLD}${PCT}%${RESET}"
}

# ─── Affichage ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║${RESET}         ${BOLD}${WHITE}   VPS Portfolio — Lycée Paul-Louis Courier${RESET}              ${BOLD}${CYAN}║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Informations générales
echo -e "  ${BOLD}${BLUE}▸ Hôte          :${RESET}  ${WHITE}${HOSTNAME}${RESET}"
echo -e "  ${BOLD}${BLUE}▸ Date          :${RESET}  ${WHITE}${DATE}${RESET}"
echo -e "  ${BOLD}${BLUE}▸ Uptime        :${RESET}  ${WHITE}${UPTIME}${RESET}"
echo -e "  ${BOLD}${BLUE}▸ IP locale     :${RESET}  ${WHITE}${IP_LOCAL}${RESET}"
echo ""

# Séparateur
echo -e "  ${DIM}──────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${CYAN}  Informations système${RESET}"
echo -e "  ${DIM}──────────────────────────────────────────────────────────────${RESET}"
echo ""

echo -e "  ${BOLD}${BLUE}▸ Noyau Linux   :${RESET}  ${WHITE}${KERNEL}${RESET}"
echo -e "  ${BOLD}${BLUE}▸ Système       :${RESET}  ${WHITE}${DEBIAN_VERSION}${RESET}"
echo -e "  ${BOLD}${BLUE}▸ Charge CPU    :${RESET}  ${WHITE}${LOAD}${RESET}"
echo -e "  ${BOLD}${BLUE}▸ Processus     :${RESET}  ${WHITE}${PROCS}${RESET}"
echo -e "  ${BOLD}${BLUE}▸ Sessions SSH  :${RESET}  ${WHITE}${SSH_SESSIONS}${RESET}"
echo ""

# Stockage
echo -e "  ${BOLD}${BLUE}▸ Stockage  (/):${RESET}  Utilisé ${BOLD}${DISK_USED}${RESET} / ${DISK_TOTAL}  —  Disponible ${BOLD}${DISK_AVAIL}${RESET}"
echo -ne "                     "
progress_bar "$DISK_PCT"
echo ""

# RAM
echo -e "  ${BOLD}${BLUE}▸ Mémoire RAM   :${RESET}  Utilisée ${BOLD}${RAM_USED}${RESET} / ${RAM_TOTAL}  —  Disponible ${BOLD}${RAM_AVAIL}${RESET}"
echo -ne "                     "
progress_bar "$RAM_PCT"
echo ""

# Bonnes pratiques
echo -e "  ${DIM}──────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${YELLOW}  Bonnes pratiques${RESET}"
echo -e "  ${DIM}──────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${YELLOW}✔${RESET}  Utiliser ${BOLD}sudo <commande>${RESET} — éviter de travailler en root directement."
echo -e "  ${YELLOW}✔${RESET}  Consulter régulièrement les logs système (${BOLD}/var/log/${RESET})."
echo -e "  ${YELLOW}✔${RESET}  Maintenir le système à jour : ${BOLD}apt update && apt upgrade${RESET}."
echo -e "  ${YELLOW}✔${RESET}  Sauvegarder avant toute modification : ${BOLD}cp fichier fichier.bak${RESET}."
echo -e "  ${YELLOW}✔${RESET}  Documenter chaque intervention pour assurer la traçabilité."
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║${RESET}   ${DIM}Toute action sur ce serveur est soumise à la politique de      ${RESET}${BOLD}${CYAN}║${RESET}"
echo -e "${BOLD}${CYAN}║${RESET}   ${DIM}sécurité du Lycée Paul-Louis Courier. Intervenez avec soin.    ${RESET}${BOLD}${CYAN}║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
echo ""