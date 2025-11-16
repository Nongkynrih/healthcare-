create database health;

-- reaname the table healthcare_dataset to hlth
rename table healthcare_dataset to hlth; 

select * from hlth;

-- droping colum name and room number 
alter table hlth
drop column `name`,
drop column `room number`;

-- cleaning the column gender , medical condition, medication and test result 
set sql_safe_updates = 0 ;

update hlth 
set gender = 
case 
	when lower(gender) like 'male' then 'Male'
    when lower(gender) like 'female' then 'Female'
    else gender 
end
where gender is not null and gender <> '';

select distinct `medical condition` from hlth;

update hlth 
set `medical condition`= 
case 
	when lower(`medical condition`) like '%cancer%' then 'Cancer'
	when lower(`medical condition`) like '%diabetes%' then 'Diabetes'
    when lower(`medical condition`) like '%arthritis%' then 'Arthritis'
    when lower(`medical condition`) like '%obesity%' then 'Obesity'
    when lower(`medical condition`) like '%hypertension%' then 'Hypertention'
	when lower(`medical condition`) like '%asthma%' then 'Asthma'
    else `medical condition`
end
where `medical condition` is not null and `medical condition` <> '';

select distinct medication from hlth;
update hlth 
set  medication = 
case 
	when lower(medication) like '%paracetamol%' then 'Paracetamol'
    when lower(medication) like '%ibuprofen%' then 'Ibuprofen'
    when lower(medication) like '%aspirin%' then 'Aspirin'
    when lower(medication) like '%pencil;in%' then 'Pencilin'
	when lower(medication) like '%lipitor%' then 'Lipitor'
    else medication 
end 
where medication is not null and medication <> ''; 

-- converting the column test result to binary number (0,1) for normal and banormal 
update hlth
set `test results` =
case 
	when lower(trim(`test results`)) like '%normal%' then 0
	when lower(trim(`test results`)) like '%abnormal%' then 1 
	else null
end ;

alter table hlth 
add column avgBilling int ;
update hlth 
set avgBilling = (select avg(`billing amount`) from hlth) ;

alter table hlth
modify column `test results` int ;
select sum(`test results`) from hlth;


-- feature engineering for the column (date of addmisssion , discharge date i.e to convert to date since it's a string )
-- column , age , billing amount and 
alter table hlth
add column length_of_stay int ;
update hlth
set length_of_stay= datediff(
	str_to_date(`discharge date`, '%Y-%m-%d'),
    str_to_date(`date of admission`, '%Y-%m-%d'));

alter table hlth 
add column admit_date date ,
add column discharge_date date ;

set sql_safe_updates = 0 ;

update hlth 
set admit_date = str_to_date(`date of admission`, '%Y-%m-%d'),
discharge_date = Str_To_Date(`discharge date`, '%Y-%m-%d');

alter table hlth 
drop column `date of admission`,
drop column `discharge date`;

select age ,
case 
	when age< 18 then 'Child'
    when age between 18 and 30 then 'Young_Adult'
    when age between 31 and 50 then 'Adult'
    when age between 51 and 70 then 'senior'
    else 'elderly'
end as AgeGroup
from hlth ;

alter table hlth 
add column Billing_level varchar(12);

update hlth 
set Billing_level =
case 
	when `billing amount` < 5000 then 'low'
    when `billing amount` between 5000 and 15000 then 'medium'
    else 'high'
end ;

-- looking for the admission of patient in which season , weekend 
alter table hlth 
add column Season varchar(10);
update  hlth
set Season= 
case 
	when month(`date of admission`) in (1,2,12) then 'Winter'
    when month(`date of admission`) in (3,4,5) then 'Spring'
    when month(`date of admission`) in (6,7,8) then 'Summer'
    else 'Autumn'
end ; 


alter table hlth 
add column AddmissionDay varchar(10); 
update hlth 
set AddmissionDay=
case 
	 when dayofweek(`date of admission`) in (1,7) then 'Weekend'
     else 'Weekday'
end ;

-- since the hlth table don't have a ID 
alter table hlth 
add column Patient_id int not null auto_increment primary key first ; 

select * from hlth ;

select distinct Patient_id from hlth;

select Patient_id,age from hlth ;
select distinct(patient_id) from hlth;