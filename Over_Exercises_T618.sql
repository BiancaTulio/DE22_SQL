USE 
	T618
GO

--1
--Ta fram resp anställds förnamn, efternamn, job, grundlön och total lönesumma för hela företaget (skapa en enda query, använd over)
SELECT
	Firstname,
	Lastname,
	Job,
	Salary,
	SUM(Salary) OVER() AS 'TotalSalaries'
FROM
	Employee


--2
--Som ovan men räkna även ut hur stor procentuell del av den total lönesumman varje anställd har. Avrunda procenten till en decimal
--(skapa en enda query, använd over)
SELECT
	Firstname,								
	Lastname,
	Job,
	Salary,
	SUM(Salary) OVER() AS 'TotalSalaries',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER()) AS float), 2) AS 'PercentOfTotal'
FROM
	Employee


--3
--Som ovan men räkna ut bade hur stor procentuell del av den total lönesumman samt hur stor procentuell del varje anställd har inom
--sin job-titel. Avrunda procent till en decimal (skapa en enda query, använd over)
SELECT
	Firstname,
	Lastname,
	Job,
	Salary,
	SUM(Salary) OVER() AS 'TotalSalaries',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER()) AS float), 2) AS 'PercentOfTotal',
	SUM(Salary) OVER(PARTITION BY Job ORDER BY Job) AS 'TotalByPosition',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER(PARTITION BY Job)) AS float), 2) AS 'PercentByPosition'
FROM
	Employee


--4
--Ta fram resp anställds förnamn, efternamn, grundlön, avdelningsnamn och räkna ut hur stor procentuell del av den total lönesumman 
--samt hur stor procentuell del varje anställd har inom sin avdelning. Avrunda procent till en decimal (skapa en enda query, använd over)
SELECT
	Firstname,
	Lastname,
	Salary,
	DeptName,
	SUM(Salary) OVER() AS 'TotalSalaries',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER()) AS float), 2) AS 'PercentOfTotal',
	SUM(Salary) OVER(PARTITION BY DeptName) AS 'TotalByDept',
	ROUND(CAST((Salary * 100) AS float) / CAST((SUM(Salary) OVER(PARTITION BY DeptName)) AS float), 2) AS 'PercentOfDept'
FROM
	Employee As E
INNER JOIN
	Department AS D
ON
	E.DeptID = D.DeptID
ORDER BY
	DeptName

	
