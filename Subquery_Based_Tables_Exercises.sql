
USE
	T618
GO


--Visa f�rnamn, efternamn, jobbtitel, och anst�llningsdatum f�r de tre f�rst anst�llda personerna med respektive jobbtitel. 
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


--Visa f�rnamn, efternamn, jobbtitel, och l�n f�r de tre personerna som har h�gst l�n f�r respektive jobbtitel. Skriv en enda query. 
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