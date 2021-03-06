#!/bin/bash

echo "Nettoyage des anciennes règles : OK"
iptables -t filter -F
iptables -t mangle -F
iptables -t nat -F

iptables -t filter -X
iptables -t mangle -X
iptables -t nat -X

echo "[IMPORTANT] Fermeture de tous les accés par défaut : OK"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo "[IMPORTANT] Autorisation des échanges locaux : OK"
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

echo "[IMPORTANT] Autorisation de la machine a aller sur internet : OK"
iptables -t filter -A OUTPUT -o eth0 -m state ! --state INVALID -j ACCEPT
iptables -t filter -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A OUTPUT -o vmbr0 -m state ! --state INVALID -j ACCEPT
iptables -t filter -A INPUT -i vmbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "Réponse aux requêtes de PING : OK"
iptables -A INPUT -p icmp -j ACCEPT

echo "[IMPORTANT] Ouverture du port SSH : OK"
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state ! --state INVALID -j ACCEPT

# Fonction pour ouvrir les ports rapidement :
function openp() { # Ouvre un port pour tout le monde
iptables -A INPUT -i eth0 -p $1 --dport $2 -m state ! --state INVALID -j ACCEPT
}
function openip() { # Ouvre un port a une IP
iptables -A INPUT -i eth0 -p $1 -s $2 --dport $3 -m state ! --state INVALID -j ACCEPT
}

echo "Mise en place des autres règles : OK"

echo "Affichage des règles initialisés :"
iptables -L

echo "Le firewall est désormais initialisé :)."
