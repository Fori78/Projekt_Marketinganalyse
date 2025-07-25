Marketing Analytics SQL-Projekt

Überblick:

Dieses Projekt enthält ein vollständiges SQL-Schema zur Analyse von Marketingkampagnen, Kundenwerten und Produktverkäufen. Ziel ist es, eine Grundlage für datengetriebene Entscheidungen im Marketing zu schaffen – inkl. Customer Lifetime Value (CLV)-Berechnung, ROI-Auswertung von Kampagnen und Segmentanalysen.

Inhalt:

Die Datei Projekt_Marketinganalyse.sql erstellt:

Tabellen:

customers	  Kundendaten (Alter, Geschlecht, Region, etc.)
campaigns	  Informationen zu Marketingkampagnen
emails_sent	  Versanddaten von E-Mails an Kunden
orders	      Bestellungen der Kunden
order_items	  Einzelne Produkte innerhalb einer Bestellung

Views und Funktionen:

customer_value_report: CLV und Bestellfrequenz pro Kunde
vw_campaign_performance: View für Management-Bericht mit aktuellen Kennzahlen


Beispieldaten (optional)

Nutzung:

1. SQL-Datei ausführen
In MySQL/MariaDB oder einer anderen SQL-Datenbank deiner Wahl:
mysql -u dein_benutzer -p < Projekt_Marketinganalyse.sql

2. Alternativ: Manuell in Workbench oder DBeaver öffnen und ausführen.
Voraussetzungen
MySQL 8.x oder kompatible Datenbank

(Optional) Workbench, DBeaver oder ein anderes SQL-Tool

Lizenz:

MIT License – frei zur Nutzung und Anpassung.

Autor:

Erstellt von Hristofor Hrisoskulov
Kontakt: GitHub-Profil: Fori78

Hinweis:

Dieses Projekt ist mein erstes Projekt in MySQL und dient sowohl Lern- als auch Analysezwecken. Für produktive Nutzung sollten Datenstrukturen ggf. weiter optimiert werden (z. B. Indizierung, Datensicherheit, Performance).
