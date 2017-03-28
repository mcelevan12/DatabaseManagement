--Create Tables--

CREATE TABLE Zipcode(
  ZIP INTEGER not null primary key,
  City Varchar(50),
  State Varchar(2), 
)

CREATE TABLE Person(
  PID INTEGER not null primary key,
  FirstName Varchar(100) not null,
  LastName Varchar(100) not null,
  SpouseFirstName Varchar(100),
  SpouseLastName Varchar(100),
  StreetAddress Varchar(250),
  ZIP INTEGER references Zipcode(ZIP)
);

CREATE TABLE Actor(
  AID INTEGER not null primary key,
  PID INTEGER not null references Person(PID),
  HairColor Varchar(20) not null,
  EyeColor Varchar(20) not null,
  HeightInInches NUMERIC(8,1) not null,
  WeightInPounds NUMERIC(8,1) not null,
  FavoriteColor Varchar(20) not null,
  ScreenActorGuildAnniversityDate DATE
);
 
CREATE TABLE Director(
  DID INTEGER not null primary key,
  PID INTEGER not null references Person(PID),
  FilmSchool Varchar(35),
  DirectorsGuildAnniversityDate DATE,
  FavoriteLensmaker Varchar(50) not null
);

CREATE TABLE Movie(
  MID INTEGER not null primary key,
  Name Varchar(45) not null,
  YearReleased INTEGER(12) not null,
  MPAANumber INTEGER(20) not null,
  DomesticBoxSalesUSD DECIMAL(30,2) not null,
  ForiegnBoxSalesUSD DECIMAL(30,2) not null,
  DVDBlueRaySalesUSD DECIMAL(30,2) not null
)

CREATE TABLE Directed(
  DID INTEGER not null references Director(DID),
  MID INTEGER not null references Movie(MID),
  PRIMARY KEY(DID, MID)
)

CREATE TABLE ActedIn(
  AID INTEGER not null references Actor(AID),
  MID INTEGER not null references Movie(MID),
  PRIMARY KEY(AID, MID)
) 

CREATE VIEW FullPerson 
AS(
  SELECT * 
  FROM Person INNER JOIN Zipcode ON Person.ZIP = Zipcode.ZIP
)

CREATE VIEW FullActor
AS(
  SELECT *
  FROM Actor INNER JOIN FullPerson ON Actor.PID = Person.PID
)

CREATE VIEW FullDirector
AS(
  SELECT *
  FROM Director INNER JOIN FullPerson ON Director.PID = Person.PID
)


--QUERY--

SELECT * 
FROM FullDirector
WHERE DID IN(
  SELECT DID
  FROM Directed
  WHERE MID IN(
    SELECT MID 
    FROM Actedin
    WHERE AID IN(
      SELECT AID
      FROM Actor
      WHERE name = “Sean Connery”
    )
  )
)