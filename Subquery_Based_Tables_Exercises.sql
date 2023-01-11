
USE
	T618
GO


--Visa förnamn, efternamn, jobbtitel, och anställningsdatum för de tre först anställda personerna med respektive jobbtitel. 
--Skriv en enda query
SELECT
	*
FROM
	(SELECT
		Firstname,
		Lastname,
		Job,
		HireDate,
		ROW_NUMBER() OVER(PARTITION BY Job 							--rank should be better even here
						  ORDER BY HireDate) AS 'HiringOrder'
	FROM
		Employee) AS Hiring
WHERE
	HiringOrder <=  3
ORDER BY
	Job, 
	HiringOrder


--Visa förnamn, efternamn, jobbtitel, och lön för de tre personerna som har högst lön för respektive jobbtitel. Skriv en enda query. 
SELECT
	*
FROM
	(SELECT 
		Firstname,
		Lastname,
		Job,
		Salary,
		RANK() OVER(PARTITION BY Job
					ORDER BY Salary DESC) AS 'TopSalaries'
	FROM
		Employee) AS Salaries
WHERE
	TopSalaries <= 3
ORDER BY
	Job,
	TopSalaries