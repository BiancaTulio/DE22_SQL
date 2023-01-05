USE 
	T618
GO

--1
--Ta fram resp anst�llds f�rnamn, efternamn, job, grundl�n och total l�nesumma f�r hela f�retaget (skapa en enda query, anv�nd over)
--(skapa en enda query, anv�nd over)
--sin job-titel. Avrunda procent till en decimal (skapa en enda query, anv�nd over)
--samt hur stor procentuell del varje anst�lld har inom sin avdelning. Avrunda procent till en decimal (skapa en enda query, anv�nd over)
SELECT
	Firstname,
	Lastname,
	Salary,
	DeptName,
	SUM(Salary) OVER() AS 'TotalSalaries',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER()) AS float), 2) AS 'PercentOfTotal',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER(PARTITION BY DeptName)) AS float), 2) AS 'PercentOfDept'
FROM
	Employee As E
INNER JOIN
	Department AS D
ON
	E.DeptID = D.DeptID
