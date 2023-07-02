select * 
from GM

--Change Date Format
alter table GM
add BornDateConverted Date;

--Removing hours-minutes-seconds
update GM
 set BornDateConverted=convert(date, Born, 112) 

-- Split into Year, Month, Day
alter table GM
add BornYear int, BornMonth int, BornDay int

update GM
set
 BornYear = datepart(year, BornDateConverted),
 BornMonth = datepart(month, BornDateConverted),
 BornDay = datepart(day, BornDateConverted);

 --Split name into First Name and Last Name
 alter table GM
 add FirstName varchar(100), LastName varchar(100)

 update GM
 set 
 FirstName=parsename(replace(Name,',','.'),2),
 LastName=parsename(replace(Name,',','.'),1);