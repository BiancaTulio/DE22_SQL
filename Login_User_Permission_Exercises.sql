
--1. Skapa login för PELLE och ANNA med SQL authentication, med ett enkla lösenord.
--has to have numbers and small and capital letters
CREATE LOGIN Pelle WITH PASSWORD = '123Abc'
CREATE LOGIN Anna WITH PASSWORD = 'Abc123'
GO


--2. Se till att ANNA och PELLE är en databas-användare i T618
USE T618
CREATE USER Pelle FOR LOGIN Pelle
CREATE USER Anna FOR LOGIN Anna
GO


--3. Tilldela rättigheter till PELLE att köra SELECT på Employee-tabellen
GRANT SELECT ON Employee TO Pelle 
GO


--4. Logga in som PELLE med SQL Manager Studio, läs samtliga rader i Employee. Gick det bra?
--Yes


--5. Kan PELLE läsa Department? 
--No


--6. Om ni skriver en join mellan Employee och Department, vad får PELLE se (ingenting, eller bara de poster från Employee)?
--Nothing


--7. Växla tillbaks till motsvarande SA och tilldela PELLE även rätten att skapa en vy.
--first need to give him permission to alter the schema
GRANT ALTER ON SCHEMA ::dbo TO Pelle
GO

GRANT CREATE VIEW TO Pelle
GO


--8. Växla till Pelle och se till att PELLE skapar en vy med underliggande data såsom SELECT firstname, lastname FROM Employee.
SELECT * FROM PellesView
GO


--9. Tilldela rättigheter till ANNA så hon kan köra SELECT mot PELLEs vy.
GRANT SELECT ON PellesView TO Anna
GO


--10. Logga in som ANNA. Låt ANNA köra SELECT * FROM PELLESVY. Hur gick det? Förklara
--She can select PellesView even though she doesn't have access to the Employee table
