curl -F "release=2011-09-30" -F "senior-csv=@government-staff-and-salary-data-template---October-2011---Defra---Revised-senior-data.csv" -F "junior-csv=@government-staff-and-salary-data-template---October-2011---Defra---Revised-junior-data.csv" http://localhost:8080/convert > result.ttl

curl -F "release=2011-09-30" -F "senior-csv=@Environment-Agency-September-2013-Final-senior.csv" -F "junior-csv=@Environment-Agency-September-2013-Final-junior.csv" http://localhost:8080/convert > result.ttl
