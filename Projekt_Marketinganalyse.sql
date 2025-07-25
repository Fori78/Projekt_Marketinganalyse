/* Projekt_Marketinganalyse

SQL-Datenanalyse im Bereich Marketing – z. B. zur Auswertung von Kampagnen, Kundenverhalten und Umsatz

1. Zieldefinition der Analyse

Welche Marketingkampagne hat den höchsten ROI?
Welche Kundensegmente reagieren am besten auf bestimmte Kanäle?
Wie hoch ist die Conversion Rate von Newsletter-Kampagnen?
Welche Produkte verkaufen sich am besten in bestimmten Regionen?

Beispiel-Ziel:
Analyse des Erfolgs von E-Mail-Marketing-Kampagnen hinsichtlich Umsatz und Kundensegment.

2. Datenquellen und Struktur überlegen

Haupttabellen (Beispiel):
Tabelle	      Beschreibung
customers	  Kundendaten (Alter, Geschlecht, Region, etc.)
campaigns	  Informationen zu Marketingkampagnen
emails_sent	  Versanddaten von E-Mails an Kunden
orders	      Bestellungen der Kunden
order_items	  Einzelne Produkte innerhalb einer Bestellung

3. Datenmodell skizzieren
Wie hängen die Tabellen zusammen?

Ein customer kann mehrere emails_sent erhalten
Ein customer kann mehrere orders haben
Eine campaign kann mit mehreren emails_sent verknüpft sein
Eine order kann mehrere order_items enthalten
order_items sind mit Produkten verknüpft (optional: products-Tabelle)

4. KPIs (Key Performance Indicators) definieren
Kennzahlen-Beispiele:

Öffnungsrate der E-Mails
Klickrate
Conversion Rate nach E-Mail
Durchschnittlicher Bestellwert nach Kampagne
Umsatz pro Kampagne

5. Beispielhafte Fragen für SQL-Abfragen definieren
A) Wie viele Kunden haben eine bestimmte Kampagne per E-Mail erhalten?
B) Wie hoch war der Umsatz pro Kampagne?
C) Wie hoch ist die Conversion Rate nach Kampagne?
D) Welche Altersgruppe bestellt am meisten nach einer E-Mail-Kampagne?
E) Durchschnittlicher Bestellwert pro Kampagne?
F) Welche Produkte wurden am meisten verkauft – regional aufgeschlüsselt?

6. Umsetzung vorbereiten

Datenbank & Tabellen erstellen (DDL-Skripte)
Beispieldaten einfügen (DML-Skripte)
SQL-Abfragen schreiben und analysieren */

-- 1. Datenbank anlegen
CREATE DATABASE IF NOT EXISTS marketing_analytics;
USE marketing_analytics;

-- 2. Tabellen erstellen
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    age INT CHECK (age BETWEEN 18 AND 100),
    gender ENUM('m', 'f', 'd') NOT NULL,
    region VARCHAR(50) NOT NULL
);

CREATE TABLE campaigns (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (end_date >= start_date)
);

CREATE TABLE emails_sent (
    email_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    campaign_id INT NOT NULL,
    sent_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10,2) NOT NULL CHECK (price_per_unit >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 3. Tabellen befüllen
INSERT INTO customers (first_name, last_name, age, gender, region) VALUES
('Anna', 'Meyer', 28, 'f', 'Berlin'),
('Tom', 'Schulz', 35, 'm', 'Hamburg'),
('Lisa', 'Köhler', 42, 'f', 'München'),
('Max', 'Becker', 30, 'm', 'Berlin'),
('Nina', 'Hart', 25, 'f', 'Köln');

INSERT INTO campaigns (campaign_id, campaign_name, start_date, end_date) VALUES
(101, 'Sommer Sale', '2025-06-01', '2025-06-15'),
(102, 'Newsletter Juli', '2025-07-01', '2025-07-10');

INSERT INTO emails_sent (customer_id, campaign_id, sent_date) VALUES
(1, 101, '2025-06-01'),
(2, 101, '2025-06-02'),
(1, 102, '2025-07-01'),
(3, 102, '2025-07-02'),
(5, 102, '2025-07-03');

INSERT INTO orders (order_id, customer_id, order_date, total_amount) VALUES
(201, 1, '2025-06-05', 80.00),
(202, 2, '2025-06-06', 45.00),
(203, 1, '2025-07-03', 120.00),
(204, 5, '2025-07-05', 30.00);

INSERT INTO order_items (order_id, product_name, quantity, price_per_unit) VALUES
(201, 'T-Shirt', 2, 20.00),
(201, 'Shorts', 1, 40.00),
(202, 'Sonnenbrille', 1, 45.00),
(203, 'Kleid', 1, 60.00),
(203, 'Sandalen', 2, 30.00),
(204, 'T-Shirt', 1, 30.00);

-- 4. SQL-Abfragen

-- 4.1. Fragen A + B + C 
/* 	Frage A: einfache Zählung
	Frage B: Umsatz ermitteln mit JOIN-Abfrage
	Frage C: Conversion Rate als Verhältnis Käufer / Empfäng*/
    
-- Frage A: Wie viele Kunden haben eine bestimmte Kampagne per E-Mail erhalten?
-- Ziel: Zählen, wie oft eine Kampagne in emails_sent vorkommt → E-Mail-Reichweite

SELECT
	c.campaign_name,
    COUNT(e.email_id) AS emails_sent
FROM
	emails_sent e 
JOIN 
	campaigns c ON e.campaign_id = c.campaign_id
GROUP BY
	e.campaign_id, c.campaign_name;

-- Frage B: Wie hoch war der Umsatz pro Kampagne?
-- Ziel: Summe der Bestellungen von Kunden, die eine Kampagne erhalten haben.
SELECT
	c.campaign_name,
    SUM(o.total_amount) AS total_revenue
FROM campaigns c 
JOIN emails_sent e ON c.campaign_id = e.campaign_id
JOIN orders o ON e.customer_id = o.customer_id
WHERE o.order_date BETWEEN c.start_date AND c.end_date + INTERVAL 7 DAY 
GROUP BY c.campaign_id, c.campaign_name;

-- Frage C: Wie hoch ist die Conversion Rate pro Kampagne?
-- Ziel: Wieviel % der Empfänger haben mindestens 1 Bestellung aufgegeben?
SELECT
	c.campaign_name,
    COUNT(DISTINCT e.customer_id) AS recipients,
    COUNT(DISTINCT o.customer_id) AS buyers,
    ROUND(COUNT(DISTINCT o.customer_id) / COUNT(DISTINCT e.customer_id) * 100, 2)
FROM campaigns c 
JOIN emails_sent e ON c.campaign_id = e.campaign_id
LEFT JOIN
	orders o ON e.customer_id = o.customer_id
    	AND o.order_date BETWEEN c.start_date AND c.end_date + INTERVAL 7 DAY  
GROUP BY c.campaign_id, c.campaign_name;

-- Frage D: Welche Altersgruppe bestellt am meisten nach einer E-Mail-Kampagne?
-- Ziel: Ermitteln, welche Altersgruppe am häufigsten nach E-Mail-Kampagnen bestellt hat.
/* Altersgruppen definieren (z. B.):
Altersgruppe	Altersbereich
18–29 Jahre	    18–29
30–39 Jahre	    30–39
40–49 Jahre	    40–49*/
SELECT
	CASE
    	WHEN cu.age BETWEEN 18 AND 29 THEN '18-29'
        WHEN cu.age BETWEEN 30 AND 39 THEN '30-39'
        WHEN cu.age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS age_group,
    COUNT(DISTINCT o.order_id) AS orders_count
FROM emails_sent e 
JOIN customers cu ON e.customer_id = cu.customer_id
JOIN orders o ON e.customer_id = o.customer_id
				AND o.order_date BETWEEN e.sent_date AND e.sent_date + INTERVAL 7 DAY 
GROUP BY age_group
ORDER BY orders_count DESC;

-- Frage E: Durchschnittlicher Bestellwert pro Kampagne
-- Ziel: Wie viel geben Kunden im Schnitt pro Bestellung aus – pro Kampagne, nachdem sie eine E-Mail erhalten haben?
/* Definition:
Ø Bestellwert (AOV – Average Order Value) =
Summe total_amount / Anzahl Bestellungen
→ aber nur Bestellungen nach Kampagnenversand */
SELECT
	c.campaign_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM campaigns c 
JOIN emails_sent e ON c.campaign_id = e.campaign_id
JOIN orders o ON e.customer_id = o.customer_id
				AND o.order_date BETWEEN e.sent_date AND e.sent_date + INTERVAL 7 DAY 
GROUP BY c.campaign_id, c.campaign_name;

-- Frage F: Welche Produkte verkaufen sich am besten in bestimmten Regionen?
/* Ziel:
Für jede Region → die Top 3 Produkte (nach verkaufter Stückzahl)
Grundlage: order_items + orders + customers*/
WITH product_sales_per_region AS (
    SELECT
    	cu.region,
    	oi.product_name,
    	SUM(oi.quantity) AS total_quantity,
    	RANK() OVER (PARTITION BY cu.region ORDER BY SUM(oi.quantity) DESC) AS rank_in_region
   	FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN customers cu ON o.customer_id = cu.customer_id
    GROUP BY cu.region, oi.product_name
)
SELECT
	region,
    product_name,
    total_quantity,
    rank_in_region
FROM product_sales_per_region
WHERE rank_in_region <= 3
ORDER by region, rank_in_region;

-- 5. SQL-Analyse + Datenlogik
/* Wir erweitern unsere bisherigen Analysen durch:
5.1. Unterabfragen & Fensterfunktionen
5.2. Views für Management-Reporting
5.3. Prozeduren & Funktionen zur Automatisierung
5.4. Temporäre Tabellen & Transaktionen
5.5. Cursornutzung (Kontrollierter Datendurchlauf)
5.6. Indizes für Performance
5.7. Trigger für Automatisierung bei Änderungen*/

-- 5.1. Erweiterte Analyse mit Unterabfragen & Fensterfunktionen
-- Ziel: "Top-Kampagnen nach ROI" + gleichzeitige Darstellung von Conversion Rate und Umsatz
SELECT
	c.campaign_name,
    COUNT(DISTINCT e.customer_id) AS recepients,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
    ROUND(COUNT(DISTINCT o.customer_id) / COUNT(DISTINCT e.customer_id) * 100, 2) AS conversion_rate,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY COUNT(DISTINCT o.customer_id) / COUNT(DISTINCT e.customer_id) DESC) AS conversion_rank
FROM campaigns c 
JOIN emails_sent e ON c.campaign_id = e.campaign_id
LEFT JOIN orders o ON e.customer_id = o.customer_id
					AND o.order_date BETWEEN e.sent_date AND e.sent_date + INTERVAL 7 DAY 
ORDER by c.campaign_id, c.campaign_name;

-- 5.2. View für Management-Bericht mit aktuellen Kennzahlen
CREATE OR REPLACE VIEW vw_campaign_performance AS
SELECT
	c.campaign_name,
    COUNT(DISTINCT e.customer_id) AS recipients,
    COUNT(DISTINCT o.customer_id) AS buyers,
    ROUND(COUNT(DISTINCT o.customer_id) / COUNT(DISTINCT e.customer_id) * 100, 2) AS conversion_rate,
    SUM(o.total_amount) AS total_revenue,
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS avg_order_value
FROM campaigns c 
JOIN emails_sent e ON c.campaign_id = e.campaign_id
LEFT JOIN orders o ON e.customer_id = o.customer_id
					AND o.order_date BETWEEN e.sent_date AND e.sent_date + INTERVAL 7 DAY 
GROUP BY c.campaign_id, c.campaign_name;

-- 5.3. Prozeduren & Funktionen zur Automatisierung
-- Beispiel: Prozedur, die neue Kampagnen-Performance in Log-Tabelle schreibt

-- Log-Tabelle vorbereiten
CREATE TABLE campaign_performance_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_name VARCHAR(100),
    total_revenue DECIMAL(10,2),
    conversion_rate DECIMAL(5,2),
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Prozedur
DELIMITER //

CREATE PROCEDURE log_campaign_performance()
BEGIN
    INSERT INTO campaign_performance_log (campaign_name, total_revenue, conversion_rate)
    SELECT 
        campaign_name,
        total_revenue,
        conversion_rate
    FROM vw_campaign_performance;
END //

DELIMITER ;
-- Aufruf
CALL log_campaign_performance();

-- 5.4. Temporäre Tabellen + Transaktion + Cursor
-- Temporäre Tabelle für Kampagnen mit Conversion > 50%
START TRANSACTION;

CREATE TEMPORARY TABLE tmp_high_performance_campaigns AS
SELECT
	campaign_name,
    total_revenue,
    conversion_rate
FROM vw_campaign_performance
WHERE conversion_rate > 50;

COMMIT;

-- Ergebnisfrage
SELECT * FROM tmp_high_performance_campaigns;

-- Cursor – Durch alle Kampagnen "schleifen" und Umsatz prüfen (Beispiel)
DELIMITER //

CREATE PROCEDURE check_campaigns_cursor()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE campaign VARCHAR(100);
    DECLARE revenue DECIMAL(10,2);
    DECLARE cur CURSOR FOR 
        SELECT campaign_name, total_revenue FROM vw_campaign_performance;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    campaign_loop: LOOP
        FETCH cur INTO campaign, revenue;
        IF done THEN
            LEAVE campaign_loop;
        END IF;
        -- Beispiel-Ausgabe:
        SELECT CONCAT('Kampagne: ', campaign, ' Umsatz: ', revenue) AS info;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;

-- 5.5. Index, Trigger
-- Index für schnellere Bestellungssuche nach Kunde + Datum:
CREATE INDEX idx_customer_date ON orders (customer_id, order_date);

-- Trigger: Logge neue Bestellung automatisch
-- Log-Tabelle:
CREATE TABLE order_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger:
CREATE TRIGGER trg_order_insert AFTER INSERT ON orders
FOR EACH ROW
INSERT INTO order_log (order_id) VALUES (NEW.order_id);

-- 6. Trigger für automatische ROI-Berechnung pro Kampagne
/*Jede neue Bestellung könnte den ROI einer Kampagne beeinflussen.
Der Trigger soll automatisch:
	prüfen, ob Bestellung zu einer Kampagne gehört
	Umsatz aufsummieren
	ROI neu berechnen = (Gesamtumsatz - Kosten) / Kosten*/
-- Vorbereitung: Neue Tabelle campaign_roi
CREATE TABLE campaign_roi (
	campaign_id INT PRIMARY KEY,
    total_revenue DECIMAL(10,2) DEFAULT 0,
    cost DECIMAL(10,2), -- Kosten der Kampagne (manuell befüllt)
    roi DECIMAL(6,2), -- ROI in %
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- Trigger zur Umsatzaktualisierung + ROI-Neuberechnung
DELIMITER //
CREATE TRIGGER trg_order_update_roi AFTER INSERT ON orders
FOR EACH ROW
BEGIN
	DECLARE camp_id INT;
    -- Prüfe: Hat Kunde zu einer Kampagne E-Mails bekommen?
    SELECT campaign_id INTO camp_id
    FROM emails_sent
    WHERE customer_id = NEW.customer_id
    	AND NEW.order_date BETWEEN sent_date AND sent_date + INTERVAL 7 DAY 
    LIMIT 1;
    -- Falls ja, aktualisiere Umsatz & ROI in campaign_roi
    IF camp_id IS NOT NULL THEN
    	-- Update Umsatz
        UPDATE campaign_roi
        SET total_revenue = total_revenue + NEW.total_amount
        WHERE campaign_id = camp_id;
        -- ROI neu berechnen
        UPDATE campaign_roi
        SET roi = ROUND(((total_revenue - cost) / cost) * 100, 2)
        WHERE campaign_id = camp_id;
    END IF;
END //

DELIMITER ;
/* Ablauf: 
Neue Bestellung → Trigger feuert
Sucht passende Kampagne → aktualisiert campaign_roi
Berechnet automatisch aktuellen ROI*/

-- 7. Funktion mit Rückgabewert: Kundenwert berechnen
/* Ziel:
Gib den Customer Lifetime Value (CLV) eines Kunden zurück:
CLV = Durchschnittlicher Bestellwert × Anzahl Bestellungen*/

DELIMITER //

CREATE FUNCTION calculate_customer_value(cust_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_orders INT DEFAULT 0;
    DECLARE total_spent DECIMAL(10,2) DEFAULT 0;
    DECLARE clv DECIMAL(10,2) DEFAULT 0;

    SELECT 
        COUNT(*), COALESCE(SUM(total_amount), 0)
    INTO total_orders, total_spent
    FROM orders
    WHERE customer_id = cust_id;

    IF total_orders = 0 THEN
        SET clv = 0;
    ELSE
        SET clv = total_spent;
    END IF;

    RETURN clv;
END //

DELIMITER ;

-- Beispiel-Aufruf

SELECT calculate_customer_value(1) AS clv;

-- 8. Massenanalyse aller Customer Lifetime Values (CLVs)
/* Was soll die Procedure tun?
	Jeden Kunden durchgehen
	Für jeden den CLV berechnen (Gesamtumsatz)
	Ergebnis in eine Tabelle schreiben (Report-Tabelle)
	Optional: Kunden in Segmente (Gold/Silber/Bronze) einteilen*/

--  Tabelle für Ergebnisse
CREATE TABLE customer_value_report (
    customer_id INT PRIMARY KEY,
    total_orders INT,
    total_spent DECIMAL(10,2),
    clv DECIMAL(10,2),
    customer_segment VARCHAR(20)
);

-- Stored Procedure zur Massenverarbeitung
DELIMITER //

CREATE PROCEDURE calculate_all_customer_values()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE cust_id INT;
    DECLARE total_orders INT;
    DECLARE total_spent DECIMAL(10,2);
    DECLARE clv DECIMAL(10,2);
    DECLARE segment VARCHAR(20);

    -- Cursor für alle Kunden
    DECLARE cust_cursor CURSOR FOR 
        SELECT customer_id FROM customers;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Lösche alte Reportdaten
    TRUNCATE TABLE customer_value_report;

    OPEN cust_cursor;

    read_loop: LOOP
        FETCH cust_cursor INTO cust_id;
        IF done THEN 
            LEAVE read_loop;
        END IF;

        -- Berechne Werte je Kunde
        SELECT 
            COUNT(*), COALESCE(SUM(total_amount), 0)
        INTO total_orders, total_spent
        FROM orders
        WHERE customer_id = cust_id;

        SET clv = total_spent;

        -- Segmentierung nach CLV
        IF clv >= 500 THEN
            SET segment = 'Gold';
        ELSEIF clv >= 200 THEN
            SET segment = 'Silber';
        ELSE
            SET segment = 'Bronze';
        END IF;

        -- Einfügen in Report-Tabelle
        INSERT INTO customer_value_report (customer_id, total_orders, total_spent, clv, customer_segment)
        VALUES (cust_id, total_orders, total_spent, clv, segment);
    END LOOP;

    CLOSE cust_cursor;
END //

DELIMITER ;

-- Aufruf der Prozedur:
CALL calculate_all_customer_values();

-- Ergebnisse prüfen:
SELECT * FROM customer_value_report;

-- 9. Optionale Indexe für Performance aufwerten
-- Index für schnelleres Aggregieren in orders
CREATE INDEX idx_orders_customer ON orders (customer_id);

-- Index auf emails_sent zur besseren Kampagnenverknüpfung
CREATE INDEX idx_emails_customer_date ON emails_sent (customer_id, sent_date);

-- 10. Optionale Erweiterungen
-- Reporting-View für Segmente:
CREATE OR REPLACE VIEW vw_customer_segments AS
SELECT customer_segment, COUNT(*) AS customers_in_segment,
       ROUND(AVG(clv),2) AS avg_clv
FROM customer_value_report
GROUP BY customer_segment;

-- 11. Export der CLV-Werte z. B. als CSV ausgeben (via SELECT ... INTO OUTFILE)
/* Die Customer Lifetime Value (CLV)-Werte aus der Tabelle customer_value_report als CSV-Datei mit dem folgenden Befehl in MySQL exportieren:
Hinweis: SELECT ... INTO OUTFILE funktioniert nur, wenn du MySQL-Zugriff auf den Server hast und der MySQL-Server Schreibrechte für das Zielverzeichnis besitzt. 
Standardmäßig darf nur in das tmpdir-Verzeichnis oder in festgelegte Pfade geschrieben werden (je nach MySQL-Konfiguration).*/
SELECT 
    customer_id,
    total_orders,
    total_spent,
    clv,
    customer_segment
INTO OUTFILE '/var/lib/mysql-files/customer_value_report.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
FROM customer_value_report;

/* Details zur Syntax:
FIELDS TERMINATED BY ',': CSV-Trennung mit Kommas.
ENCLOSED BY '"': Werte in Anführungszeichen setzen.
LINES TERMINATED BY '\n': Zeilenumbruch.
Der Pfad /var/lib/mysql-files/ ist oft der einzige erlaubte Export-Pfad aus Sicherheitsgründen.*/

-- Sicherheit und Rechte: Der MySQL-Nutzer muss das Recht FILE besitzen:
SHOW GRANTS FOR CURRENT_USER;

-- 12.  Für Tableau: Welche Formate sind sinnvoll?
/*
1. CSV-Export → Optimal für Tableau
Tableau kann CSV-Dateien problemlos importieren.

2. Direkte Verbindung zur MySQL-Datenbank (besser für dynamische Daten)
In Tableau: "Datenquelle hinzufügen" > MySQL auswählen > Zugangsdaten eingeben

Vorteil: Live-Updates oder periodische Aktualisierung möglich.

Formatierung der Daten in Tableau – Tipps für CLV-Analysen:
Feldname			Tableau-Datenformat			Verwendung in Tableau
customer_id			Ganzzahl oder String		Dimension / Filter
total_orders		Ganzzahl					Kennzahl
total_spent			Dezimal (Währung)			Kennzahl
clv					Dezimal (Währung)			Wichtige Kennzahl für Visualisierungen
customer_segment	String						Dimension (für Segmentierung, Farbe etc.)

Beispiele für Tableau-Dashboards:
Visualisierung			Beschreibung
CLV-Verteilung			Histogramm oder Boxplot von clv
Segmentanalyse			Balkendiagramm: Durchschnittlicher CLV pro Segment
Top-Kunden				Tabelle oder Rangliste nach CLV
Zeitverlauf				Wenn du Zeitdimensionen hast: CLV-Entwicklung
KPI-Widgets				Summe CLV, Durchschnitt CLV, Segmentanteile */