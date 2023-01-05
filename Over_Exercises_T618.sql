USE 
	T618
GO

--1
--Ta fram resp anst�llds f�rnamn, efternamn, job, grundl�n och total l�nesumma f�r hela f�retaget (skapa en enda query, anv�nd over)SELECT	Firstname,	Lastname,	Job,	Salary,	SUM(Salary) OVER() AS 'TotalSalaries'FROM	Employee--2--Som ovan men r�kna �ven ut hur stor procentuell del av den total l�nesumman varje anst�lld har. Avrunda procenten till en decimal
--(skapa en enda query, anv�nd over)SELECT	Firstname,									Lastname,	Job,	Salary,	SUM(Salary) OVER() AS 'TotalSalaries',	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER()) AS float), 2) AS 'PercentOfTotal'FROM	Employee--3--Som ovan men r�kna ut bade hur stor procentuell del av den total l�nesumman samt hur stor procentuell del varje anst�lld har inom
--sin job-titel. Avrunda procent till en decimal (skapa en enda query, anv�nd over)SELECT	Firstname,	Lastname,	Job,	Salary,	SUM(Salary) OVER() AS 'TotalSalaries',	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER()) AS float), 2) AS 'PercentOfTotal',	SUM(Salary) OVER(PARTITION BY Job ORDER BY Job) AS 'TotalByPosition',	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER(PARTITION BY Job)) AS float), 2) AS 'PercentByPosition'FROM	Employee--4--Ta fram resp anst�llds f�rnamn, efternamn, grundl�n, avdelningsnamn och r�kna ut hur stor procentuell del av den total l�nesumman 
--samt hur stor procentuell del varje anst�lld har inom sin avdelning. Avrunda procent till en decimal (skapa en enda query, anv�nd over)
SELECT
	Firstname,
	Lastname,
	Salary,
	DeptName,
	SUM(Salary) OVER() AS 'TotalSalaries',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER()) AS float), 2) AS 'PercentOfTotal',	SUM(Salary) OVER(PARTITION BY DeptName ORDER BY DeptName) AS 'TotalByDept',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER(PARTITION BY DeptName)) AS float), 2) AS 'PercentOfDept'
FROM
	Employee As E
INNER JOIN
	Department AS D
ON
	E.DeptID = D.DeptID

