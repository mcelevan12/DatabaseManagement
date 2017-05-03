DROP TRIGGER IF EXISTS backupLocationInsert ON Backups;
DROP TRIGGER IF EXISTS backupLocationUpdate ON Backups;
DROP TRIGGER IF EXISTS backupLocationServersInsert ON Servers;
DROP TRIGGER IF EXISTS backupLocationServersUpdate ON Servers;
DROP TRIGGER IF EXISTS backupLocationDatacentersInsert ON Datacenters;
DROP TRIGGER IF EXISTS backupLocationDatacentersUpdate ON Datacenters;

DROP FUNCTION IF EXISTS newQuarter();
DROP FUNCTION IF EXISTS expectedRevenue(REFCURSOR);
DROP FUNCTION IF EXISTS checkBackupLocation();

DROP VIEW IF EXISTS BusinessPayments;
DROP VIEW IF EXISTS ServerLocation;
DROP VIEW IF EXISTS FullAddress;
DROP VIEW IF EXISTS AverageUsers;

DROP TABLE IF EXISTS Backups;
DROP TABLE IF EXISTS Hosting;
DROP TABLE IF EXISTS PaymentsPerQuarter;
DROP TABLE IF EXISTS Servers;
DROP TABLE IF EXISTS ActiveUsersPerQuarter;
DROP TABLE IF EXISTS Websites;
DROP TABLE IF EXISTS Business;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Datacenters;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Zip;
DROP TABLE IF EXISTS Quarters;
DROP TABLE IF EXISTS RatesPerQuarter;

CREATE TABLE RatesPerQuarter(
  RID CHAR(5) NOT NULL,
  Name CHAR(15) NOT NULL,
  Cost NUMERIC(10,2) NOT NULL,
  ExpectedUsers INTEGER,
  Servers SMALLINT NOT NULL,
  PRIMARY KEY (RID)
);

CREATE TABLE Quarters(
  Quarter SMALLINT NOT NULL CHECK (Quarter = 1 OR Quarter = 2 OR Quarter = 3 OR Quarter = 4),
  Year SMALLINT NOT NULL,
  UNIQUE (Quarter, Year),
  PRIMARY KEY(Quarter, Year)
);

CREATE TABLE Zip ( 
  ZIP CHAR(5) NOT NULL,
  City CHAR(20) NOT NULL,
  State CHAR(2) NOT NULL,
  PRIMARY KEY (ZIP)
);

CREATE TABLE Address (
  AID CHAR(5) NOT NULL,
  ZIP CHAR(5) NOT NULL REFERENCES Zip(ZIP),
  StreetNumber SMALLINT NOT NULL,
  StreetName CHAR(25) NOT NULL,
  PRIMARY KEY (AID)
);

CREATE TABLE Datacenters (
  DSID CHAR(5) NOT NULL,
  AID CHAR(5) NOT NULL REFERENCES Address(AID),
  PRIMARY KEY (DSID)
);

CREATE TABLE Employees (
  EID CHAR(5) NOT NULL,
  AID CHAR(5) NOT NULL REFERENCES Address(AID),
  LastName CHAR(25) NOT NULL,
  FirstName CHAR(15) NOT NULL,
  DateOfBirth DATE NOT NULL,
  Email CHAR(35) NOT NULL,
  Salary NUMERIC(10,2) NOT NULL,
  PRIMARY KEY (EID)
);

CREATE TABLE Business (
  BID CHAR(5) NOT NULL,
  AID CHAR(5) NOT NULL REFERENCES Address(AID),
  Phone CHAR(14) NOT NULL, 
  Email CHAR(55) NOT NULL,
  Name CHAR(50) NOT NULL,
  PRIMARY KEY (BID)
);

CREATE TABLE Websites (
  WID CHAR(5) NOT NULL,
  BID CHAR(5) NOT NULL REFERENCES Business(BID),
  RID CHAR(5) NOT NULL REFERENCES RatesPerQuarter(RID),
  AddressURL CHAR(70) NOT NULL,
  Name CHAR(55) NOT NULL,
  UNIQUE(AddressURL),
  PRIMARY KEY (WID)
);

CREATE TABLE ActiveUsersPerQuarter(
  WID CHAR(5) NOT NULL REFERENCES Websites(WID),
  Quarter SMALLINT NOT NULL,
  Year SMALLINT NOT NULL,
  NearestDatacenterAID CHAR(5) REFERENCES Address(AID),
  Users INTEGER,
  FOREIGN KEY (Quarter, Year) REFERENCES Quarters(Quarter, Year),
  PRIMARY KEY (WID, Quarter, Year)
);

CREATE TABLE Servers (
  SID CHAR(5) NOT NULL,
  DSID CHAR(5) NOT NULL REFERENCES Datacenters(DSID),
  Model CHAR(45) NOT NULL,
  OS CHAR(35) NOT NULL,
  PRIMARY KEY (SID)
);

CREATE TABLE PaymentsPerQuarter (
  BID CHAR(5) NOT NULL REFERENCES Business(BID),
  Quarter SMALLINT NOT NULL,
  Year SMALLINT NOT NULL,
  Cost NUMERIC(10,2) NOT NULL,
  Payment NUMERIC(10,2),
  FOREIGN KEY (Quarter, Year) REFERENCES Quarters(Quarter, Year),
  PRIMARY KEY (BID, Quarter, Year)
);

CREATE TABLE Hosting (
  SID CHAR(5) NOT NULL REFERENCES Servers(SID),
  WID CHAR(5) NOT NULL REFERENCES Websites(WID),
  PRIMARY KEY (SID, WID)
);

CREATE TABLE Backups (
  SID CHAR(5) NOT NULL REFERENCES Servers(SID),
  BackupSID CHAR(5) NOT NULL REFERENCES Servers(SID)
);

CREATE VIEW BusinessPayments(BID, Name, TotalCost, TotalPayment) 
AS 
SELECT Business.BID, Business.Name, SUM(PaymentsPerQuarter.Cost) AS TotalCost, SUM(PaymentsPerQuarter.Payment) AS TotalPayment
FROM Business
INNER JOIN PaymentsPerQuarter on Business.BID = PaymentsPerQuarter.BID
GROUP BY Business.BID;

CREATE VIEW ServerLocation(SID, AID, ZIP) AS
SELECT S.SID, A.AID, Z.ZIP
FROM Servers S
  INNER JOIN Datacenters D ON S.DSID = D.DSID
  INNER JOIN Address A ON D.AID = A.AID
  INNER JOIN Zip Z ON A.ZIP = Z.ZIP;

CREATE VIEW FullAddress (AID, StreetNumber, StreetName, ZIP, City, State) AS
SELECT Address.AID, Address.StreetNumber, Address.StreetName, Zip.ZIP, Zip.City, Zip.State
FROM Address INNER JOIN Zip ON Address.ZIP = Zip.ZIP;

CREATE VIEW AverageUsers(WID, Name, AverageUsers, ExpectedUsers) AS
SELECT W.WID, W.Name, AVG(A.Users), R.ExpectedUsers
FROM Websites W
  INNER JOIN ActiveUsersPerQuarter A ON W.WID = A.WID
  INNER JOIN RatesPerQuarter R ON R.RID = W.RID
  INNER JOIN Hosting H ON H.WID = W.WID
GROUP BY W.WID, R.ExpectedUsers;

CREATE FUNCTION expectedRevenue(ResultSet REFCURSOR) RETURNS REFCURSOR 
AS
$$
DECLARE
  --
BEGIN
  OPEN ResultSet FOR 
    SELECT DISTINCT B.BID, SUM(R.Cost) AS ExpectedRevenue
    FROM RatesPerQuarter R
      INNER JOIN Websites W ON R.RID = W.RID
      INNER JOIN Business B ON W.BID = B.BID
      INNER JOIN Hosting H ON W.WID = H.WID
    GROUP BY B.BID;
  RETURN ResultSet;
END;
$$ 
LANGUAGE plpgsql;

CREATE FUNCTION newQuarter() 
RETURNS BOOLEAN AS
$$
DECLARE
  nQuarter INT;
  nYear INT;
  cWID TEXT;
  cBID TEXT;
  cCost DOUBLE PRECISION;
BEGIN
--select most recent quarter--
  SELECT Quarter, Year
  INTO nQuarter, nYear
  FROM Quarters
  ORDER BY Year DESC, Quarter DESC
  LIMIT 1;
  --increment quarter, year--
  IF nQuarter = 4
    THEN
      nYear := nYear + 1;
      nQuarter := 1; 
    ELSE
      nQuarter := nQuarter + 1;
  END IF;
  --Create new quarter--
  INSERT INTO Quarters(Quarter, Year)
  VALUES
  (nQuarter, nYear);
  --select from active websites--
  FOR cWID IN (
    SELECT DISTINCT W.WID 
    FROM Websites W 
      INNER JOIN Hosting H ON W.WID = H.WID
  )
  LOOP
    --insert active websites into ActiveUsersPerQuarter--
    INSERT INTO ActiveUsersPerQuarter(WID, Quarter, Year)
    VALUES
    (cWID, nQuarter, nYear);
  END LOOP;
  --select expected costs for every buisness--
  FOR cBID, cCost IN (
    SELECT DISTINCT B.BID, SUM(R.Cost)
    FROM RatesPerQuarter R
      INNER JOIN Websites W ON R.RID = W.RID
      INNER JOIN Business B ON W.BID = B.BID
      INNER JOIN Hosting H ON W.WID = H.WID
    GROUP BY B.BID
  )
  LOOP
    --insert into PaymentsPerQuarter--
    INSERT INTO PaymentsPerQuarter (BID, Quarter, Year, Cost)
    VALUES
    (cBID, nQuarter, nYear, cCost);
  END LOOP;
  
  RETURN true;
END;
$$
LANGUAGE PLPGSQL;

CREATE FUNCTION checkBackupLocation()
RETURNS TRIGGER AS
$$
DECLARE
   mainZip   TEXT;
   backupZip TEXT;
BEGIN
  SELECT zMain.ZIP,
         zBack.ZIP
  INTO mainZip, backupZip
  FROM Backups INNER JOIN Servers sMain ON sMain.SID = Backups.SID
    INNER JOIN Datacenters dMain ON dMain.DSID = sMain.DSID
    INNER JOIN Address aMain ON aMain.AID = dMain.AID
    INNER JOIN Zip zMain ON zMain.ZIP = aMain.ZIP
    INNER JOIN Servers sBack ON sBack.SID = Backups.BackupSID
    INNER JOIN Datacenters dBack ON dBack.DSID = sBack.DSID
    INNER JOIN Address aBack ON aBack.AID = dBack.AID
    INNER JOIN Zip zBack ON zBack.ZIP = aBack.ZIP;
  IF mainZip = backupZip
    THEN
     RAISE NOTICE 'BackupServer in same ZIP code location as main server.';
     RETURN NULL;
  END IF;
  RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER backupLocationInsert
AFTER INSERT ON Backups 
EXECUTE PROCEDURE checkBackupLocation();

CREATE TRIGGER backupLocationUpdate
AFTER UPDATE ON Backups 
EXECUTE PROCEDURE checkBackupLocation();

CREATE TRIGGER backupLocationServersInsert
AFTER INSERT ON Servers
EXECUTE PROCEDURE checkBackupLocation();

CREATE TRIGGER backupLocationServersUpdate
AFTER UPDATE ON Servers 
EXECUTE PROCEDURE checkBackupLocation();

CREATE TRIGGER backupLocationDatacentersInsert
AFTER INSERT ON Datacenters 
EXECUTE PROCEDURE checkBackupLocation();

CREATE TRIGGER backupLocationDatacentersUpdate
AFTER UPDATE ON Datacenters
EXECUTE PROCEDURE checkBackupLocation();

INSERT INTO RatesPerQuarter(RID, Name, Cost, ExpectedUsers, Servers)
VALUES
('r0001', 'Basic', 5000.00, 1500, 1),
('r0002', 'Redundant', 7500.00, 2500, 3),
('r0003', 'Preimum', 12500.00, 4500, 2); 

INSERT INTO Zip(ZIP, City, State)
VALUES
(07090, 'Westfield', 'NJ'),
(20815, 'Chevy Chase', 'MD'),
(60185, 'West Chicago', 'IL'),
(32904, 'Melbourne', 'FL '),
(01801, 'Woburn', 'MA'),
(19064, 'Springfield', 'PA'),
(11967, 'Shirley', 'NY'),
(08865, 'Phillipsburg', 'NJ'),
(54115, 'De Pere', 'WI'),
(14701, 'Jamestown', 'NY'),
(12601, 'Poughkeepsie', 'NY');

INSERT INTO Address(AID, ZIP, StreetNumber, StreetName)
VALUES 
('a0001', 07090, 635, 'Lenox Ave.'),
('a0002', 12601, 3399, 'North Rd.'),
('a0003', 07090, 634, 'Lenox Ave.'),
('a0004', 20815, 71, 'Pilgrim, Ave.'),
('a0005', 60185, 44, 'Shirley Ave.'),
('a0006', 32904, 123, '6th St'),
('a0007', 54115, 599, 'Glendale Street'),
('a0008', 08865, 912, 'Old Talbot Dr.'),
('a0009', 11967, 410, 'Brickyard Dr.'),
('a0010', 19064, 545, 'St Margarets Ave.'),
('a0011', 01801, 160, 'S. Woodsman Court'),
('a0012', 01801, 12, 'Main St'),
('a0013', 01801, 15, 'Main St'),
('a0014', 14701, 797, 'W. High Point St.'),
('a0015', 14701, 9187, 'Green Ave.');

INSERT INTO Employees(EID, AID, LastName, FirstName, DateOfBirth, Email, Salary)
VALUES
('e0001', 'a0003', 'McElheny', 'Evan', TO_DATE('29/08/1997', 'DD/MM/YYYY'), 'mcelevan12@gmail.com', 1000000.00),
('e0002', 'a0004', 'Gornendaz', 'Sean', TO_DATE('09/11/1993', 'DD/MM/YYYY'), 'sgorrrr@gmail.com', 35000.00),
('e0003', 'a0002', 'Labouseur', 'Alan', TO_DATE('01/02/1963', 'DD/MM/YYYY'), 'alan@3NFconsulting.com', 12345.00),
('e0004', 'a0001', 'Liengtiraphan', 'Pradon', TO_DATE('06/05/1991', 'DD/MM/YYYY'), 'Minion@3NFconsulting.com', 54321.00);


INSERT INTO Datacenters(DSID, AID)
VALUES
('ds001', 'a0011'),
('ds002', 'a0012'),
('ds003', 'a0013'),
('ds004', 'a0014'),
('ds005', 'a0015'),
('ds006', 'a0004'),
('ds007', 'a0005');

INSERT INTO Servers(SID, DSID, Model, OS)
VALUES
('s0001', 'ds001', 'HP ProLiant DL360p Gen8', 'Windows Server 2003'),
('s0002', 'ds001', 'HP ProLiant ML115 G5 Server', 'Red Hat Enterprise'),
('s0003', 'ds003', 'HP ProLiant DL360p Gen8', 'Ubuntu'),
('s0004', 'ds003', 'HP ProLiant DL360 G6', 'Windows Server 2003'),
('s0005', 'ds004', 'HPE BladeSystem', 'Ubuntu'),
('s0006', 'ds005', 'Dell PowerEdge T620', 'Red Hat Enterprise'),
('s0007', 'ds001', 'HP ProLiant DL360p Gen8', 'Windows Server 2008'),
('s0008', 'ds002', 'HPE BladeSystem', 'Ubuntu'),
('s0009', 'ds007', 'Plex', 'Windows Server 2008'),
('s0010', 'ds003', 'HPE BladeSystem', 'Red Hat Enterprise'),
('s0011', 'ds002', 'Serviio', 'Windows Server 2012'),
('s0012', 'ds006', 'HP ProLiant DL360p Gen8', 'Ubuntu');

INSERT INTO Quarters(Quarter, Year)
VALUES
(3, 2015),
(4, 2015),
(1, 2016),
(2, 2016),
(3, 2016),
(4, 2016),
(1, 2017);

INSERT INTO Business(BID, AID, Phone, Email, Name)
VALUES 
('b0001', 'a0005', '(908)-380-8693', 'Cool@coolCatz.com', 'CoolCatz'),
('b0002', 'a0006', '(202)-555-0132', 'SOEA@SOE.com', 'SOE'),
('b0003', 'a0007', '(302)-555-0192', 'JenidMarkets@Jenid.com', 'Jenid Markets'),
('b0004', 'a0008', '(317)-555-0114', 'Marc@MarcRentals.com', 'Marc Rentals'),
('b0005', 'a0009', '(410)-555-0124', 'ASEE@ASEE.com', 'American Society Electrical Engineering');

INSERT INTO Websites (WID, BID, RID, AddressURL, Name)
VALUES
('w0001', 'b0001', 'r0001', 'CoolCatz.com', 'CoolCatz'),
('w0002', 'b0001', 'r0001', 'UglyDogs.com', 'Ugly Dogs'),
('w0003', 'b0002', 'r0002', 'SOEA.com', 'SOE Americia'),
('w0004', 'b0003', 'r0001', 'JenidMarkets.com', 'Jenid Markets'),
('w0005', 'b0003', 'r0003', 'JenidBlackMarkets.onion', 'Jenid Black Markets'),
('w0006', 'b0004', 'r0001', 'MarcRentals.com', 'Marcs Rentals'),
('w0007', 'b0005', 'r0001', 'AmericanSocietyElectricalEngineering.edu', 'American Society Electrical Engineering');

INSERT INTO ActiveUsersPerQuarter(WID, Quarter, Year, NearestDatacenterAID, Users)
VALUES
('w0001', 1, 2016, 'a0011', 750),
('w0001', 2, 2016, 'a0012', 583),
('w0001', 3, 2016, 'a0011', 1067),
('w0001', 4, 2016, 'a0011', 1007),
('w0001', 1, 2017, 'a0011', 1381),
('w0002', 3, 2016, 'a0011', 305),
('w0002', 4, 2016, 'a0013', 248),
('w0002', 1, 2017, 'a0012', 638),
('w0003', 3, 2015, 'a0015', 173),
('w0003', 4, 2015, 'a0015', 1002),
('w0003', 1, 2016, 'a0015', 1356),
('w0003', 2, 2016, 'a0012', 1482),
('w0003', 3, 2016, 'a0015', 2038),
('w0003', 4, 2016, 'a0014', 2344),
('w0003', 1, 2017, 'a0015', 2612),
('w0004', 1, 2016, 'a0012', 243),
('w0004', 2, 2016, 'a0012', 214),
('w0004', 3, 2016, 'a0013', 148),
('w0004', 4, 2016, 'a0012', 342),
('w0004', 1, 2017, 'a0011', 178),
('w0005', 1, 2016, 'a0013', 2043),
('w0005', 2, 2016, 'a0014', 2531),
('w0005', 3, 2016, 'a0011', 4219),
('w0005', 4, 2016, 'a0012', 3521),
('w0005', 1, 2017, 'a0015', 3957),
('w0006', 3, 2015, 'a0013', 213),
('w0006', 4, 2015, 'a0013', 423),
('w0006', 1, 2016, 'a0013', 311),
('w0006', 2, 2016, 'a0013', 184),
('w0007', 3, 2016, 'a0015', 1384),
('w0007', 4, 2016, 'a0015', 762),
('w0007', 1, 2017, 'a0015', 926);


INSERT INTO PaymentsPerQuarter (BID, Quarter, Year, Cost, Payment)
VALUES
('b0001', 1, 2016, 5000.00, 5000.00),
('b0001', 2, 2016, 5000.00, 5000.00),
('b0001', 3, 2016, 10000.00, 10000.00),
('b0001', 4, 2016, 10000.00, 10000.00),
('b0001', 1, 2017, 10000.00, 10000.00),
('b0002', 3, 2015, 5000.00, 5000.00),
('b0002', 4, 2015, 5000.00, 5000.00),
('b0002', 1, 2016, 7500.00, 7500.00),
('b0002', 2, 2016, 7500.00, 7500.00),
('b0002', 3, 2016, 7500.00, 7500.00),
('b0002', 4, 2016, 7500.00, 7500.00),
('b0002', 1, 2017, 7500.00, 7500.00),
('b0003', 1, 2016, 17500.00, 17500.00),
('b0003', 2, 2016, 17500.00, 17500.00),
('b0003', 3, 2016, 17500.00, 17500.00),
('b0003', 4, 2016, 17500.00, 17500.00),
('b0003', 1, 2017, 17500.00, 17500.00),
('b0004', 3, 2015, 5000.00, 5000.00),
('b0004', 4, 2015, 5000.00, 5000.00),
('b0004', 1, 2016, 5000.00, 5000.00),
('b0004', 2, 2016, 5000.00, 5000.00),
('b0005', 3, 2016, 5000.00, 5000.00),
('b0005', 4, 2016, 5000.00, 5000.00),
('b0005', 1, 2017, 5000.00, null);

INSERT INTO Hosting (SID, WID)
VALUES
('s0001', 'w0001'),
('s0003', 'w0002'),
('s0005', 'w0003'),
('s0008', 'w0003'),
('s0012', 'w0003'),
('s0004', 'w0004'),
('s0001', 'w0005'),
('s0005', 'w0005'),
('s0007', 'w0007');

INSERT INTO Backups (SID, BackupSID)
VALUES
('s0001', 's0009'), 
('s0003', 's0006'),
('s0005', 's0009'),
('s0008', 's0006'),
('s0012', 's0002'),
('s0004', 's0009'),
('s0001', 's0009'),
('s0005', 's0010'),
('s0008', 's0006'),
('s0007', 's0012');