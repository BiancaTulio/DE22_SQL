
--1. Skapa login f�r PELLE och ANNA med SQL authentication, med ett enkla l�senord.
--has to have numbers and small and capital letters
CREATE LOGIN Pelle WITH PASSWORD = '123Abc'
CREATE LOGIN Anna WITH PASSWORD = 'Abc123'
GO


--2. Se till att ANNA och PELLE �r en databas-anv�ndare i T618
USE T618
CREATE USER Pelle FOR LOGIN Pelle
CREATE USER Anna FOR LOGIN Anna
GO


--3. Tilldela r�ttigheter till PELLE att k�ra SELECT p� Employee-tabellen
GRANT SELECT ON Employee TO Pelle 
GO


--4. Logga in som PELLE med SQL Manager Studio, l�s samtliga rader i Employee. Gick det bra?
--Yes


--5. Kan PELLE l�sa Department? 
--No


--6. Om ni skriver en join mellan Employee och Department, vad f�r PELLE se (ingenting, eller bara de poster fr�n Employee)?
--Nothing


--7. V�xla tillbaks till motsvarande SA och tilldela PELLE �ven r�tten att skapa en vy.
--first need to give him permission to alter the schema
GRANT ALTER ON SCHEMA ::dbo TO Pelle
GO

GRANT CREATE VIEW TO Pelle
GO


--8. V�xla till Pelle och se till att PELLE skapar en vy med underliggande data s�som SELECT firstname, lastname FROM Employee.
SELECT * FROM PellesView
GO


--9. Tilldela r�ttigheter till ANNA s� hon kan k�ra SELECT mot PELLEs vy.
GRANT SELECT ON PellesView TO Anna
GO


--10. Logga in som ANNA. L�t ANNA k�ra SELECT * FROM PELLESVY. Hur gick det? F�rklara
--She can select PellesView even though she doesn't have access to the Employee table
