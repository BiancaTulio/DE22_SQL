
CREATE FUNCTION 
	KontrollSiffra(@pNummer VARCHAR(13))
RETURNS INT													      --returns 1 if everything is ok or 0 if there's any error
AS
BEGIN
	DECLARE @scoreIndex INT = CHARINDEX('-', @pNummer)			  --index for character -
	DECLARE @plusIndex INT = CHARINDEX('+', @pNummer)			  --index for character +
	DECLARE @length INT = LEN(@pNummer)							  --length of @pNummer
	DECLARE @cnt INT = 1    								 	  --count for while
	DECLARE @char CHAR(1)										  --character to be tested in first while
	DECLARE @num INT										      --number to be calculated in second while
	DECLARE @control INT = 0									  --variable to store the control number

	IF
		@length < 10										      --if there are too few characters
		RETURN 0 											      --return wrong

	IF
		(@length <= 11											  --if the input was YYMMDD
		and	ISDATE(SUBSTRING(@pNummer, 1, 6)) = 0)				  --and it's not a valid date
		RETURN 0												  --return wrong		
	ELSE
		IF
			(@length > 11										  --if the input was YYYYMMDD
			and ISDATE(SUBSTRING(@pNummer, 1, 8)) = 0)			  --and it's not a valid date
			RETURN 0											  --return wrong

	IF 
		@scoreIndex > 0	 				   						  --if there is a - character  		
		BEGIN
			IF
				(@scoreIndex != (@length - 4)					  --if it's not after the birthdate
				or @plusIndex > 0)								  --or if there's also a + character
				RETURN 0										  --return wrong
			ELSE
			SET @pNummer = REPLACE(@pNummer, '-', '')			  --otherwise, remove it
		END
	ELSE
		IF	
			@plusIndex > 0 										  --if there is a + character  		
			BEGIN
				IF
					@plusIndex != (@length - 4)					  --if it's not after the birthdate
					RETURN 0									  --return wrong
				ELSE
					SET	@pNummer = REPLACE(@pNummer, '+', '')	  --otherwise, remove it
			 END

	SET @pNummer = RIGHT(@pNummer, 10)					          --set the all inputs to format YYMMDDXXXX 	

	WHILE
		(@cnt <= 10)											  --loop through @pNummer
	BEGIN
		SET @char = SUBSTRING(@pNummer, @cnt, 1)				  --single out each character
		IF 													      
			(ASCII(@char) >= 48 and ASCII(@char) <= 57)			  --if the character is a number from 0 to 9	
			SET	@cnt += 1					     				  --continue loop			
		ELSE
			RETURN 0											  --otherwise, return wrong
	END	   	

	SET @cnt = 1												  --reset the count to 1

	WHILE
		(@cnt <= 10)											  --loop through @pNummer again	
	BEGIN
		SET @num = CAST((SUBSTRING(@pNummer, @cnt, 1)) AS int)	  --single out each character and cast it as int
		IF 
			@cnt % 2 != 0 										  --for every other number in @pNummer
			BEGIN
				SET @num = @num * 2								  --multiply it by 2	      
				IF 
					@num > 9								      --if the result has two digits (is between 10 and 18)
					SET @control += ((@num - 10) + 1)			  --add the left digit (1) and the right digit (@num - 10) to @control
				ELSE
					SET @control += @num						  --otherwise, just add it to @control
				SET @cnt += 1									  --continue the loop
			END
		ELSE
			IF 
				@cnt != 10										  --for the other numbers in @pNummer but the last 
				BEGIN	
					SET @control += @num				          --add it to @control
					SET @cnt += 1								  --continue the loop
				END																													    												  	
			ELSE												  --for the last number in @pNummer
				BEGIN											  --cast @control as varchar, select only the rightmost digit
					SET @control = 														 --cast it as int again and substract it from 10 
						(10 - CAST(RIGHT(CAST(@control AS VARCHAR(2)), 1) AS int)) 			   
					IF
						@control = 10							  --if the result was 10
						SET @control = 0						  --set @control to 0
					IF
						@num != @control						  --if the last number in @pNummer is not the same as @control
						RETURN 0								  --return wrong
					BREAK										  --break the loop
				 END
	END	 

	RETURN 1													  --if nothing was wrong, return right	

END
GO

