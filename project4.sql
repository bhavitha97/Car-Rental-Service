-- List the name and address of customers with 4 or more rentals
select customer_name, address from sys.customer@orclgrp7 where customer_id in (select cust_id from sys.rents@orclgrp7 group by cust_id having count(trip_id) >=4)

--List models of vehicle(s) with the most fault reports
select * from sys.vehicle@orclgrp7 where veh_id in (select veh_id from sys.faultreport@orclgrp7 group by veh_id having count(*) =  (select max(count(*)) from sys.faultreport@orclgrp7 group by veh_id ));

--List model(s) of vehicles with the most rentals.
select veh_model from sys.vehicle@orclgrp7 where veh_id in (select veh_id from sys.rents@orclgrp7 group by veh_id having count(*) =  (select max(count(*)) from sys.rents@orclgrp7 group by veh_id ));

--What is the outlet with the least rentals
select * from sys.facility@orclgrp7 where facilityid in(select facility from sys.rents group by facility having count(*) = (select min(count(*)) from sys.rents group by facility))

--List outlet with employees making more than $50,000 and having less than 3 rentals.
select * from SYS.facility@orclgrp7 f where f.facilityid in (select location from SYS.employee e where e.salary>=50000 and e.location=f.facilityid) and f.facilityid in (select facility from SYS.rents group by facility having count(*)<3)

-- What is the car color with the least number of reservations/rentals?
select color from sys.rents@orclgrp7 r join SYS.vehicle@orclgrp7 e on
r.veh_id = e.veh_id group by color having count(*) = (select min(count(*)) from sys.rents@orclgrp7 r join SYS.vehicle@orclgrp7 e on
r.veh_id = e.veh_id group by color)

-- List Customers and total mileage who rented for more than 300 miles
select cust_id,sum(end_mileage - start_mileage) from sys.rents@orclgrp7 group by cust_id having sum(end_mileage - start_mileage) >300;

-- List the customer names whose payments failed
select c.customer_name from sys.customer@orclgrp7 c join SYS.rents@orclgrp7 r on c.customer_id = r.cust_id
join SYS.payment@orclgrp7 p on r.trip_id = p.trip_id and payment_status = 'FAILED';

-- Display reviews for trips with rating less than 3 
select review from SYS.reviews@orclgrp7 where rating < 3 

-- Display number of reservations for vehicles with transmission fault
select r.veh_id, count(*) as num_reservations from sys.vehicle@orclgrp7 v join (select * from sys.rents@orclgrp7 where veh_id in(select distinct veh_id from SYS.faultreport@orclgrp7 where lower(description) like '%transmission%')) r
on r.veh_id = v.veh_id group by r.veh_id


-- Display cars with no faults
select v.* from sys.vehicle@orclgrp7 v left join SYS.faultreport@orclgrp7 f on
f.veh_id  = v.veh_id where f.veh_id is null

-- Display Liability insurance details whose coverage is more than 55%
select * from SYS.insurance_policy@orclgrp7 where coverage_perc >55 and liability_only = 1;


-- Display the customers who rented the same car multiple times4
select * from sys.customer@orclgrp7 where customer_id in
( select cust_id from SYS.rents@orclgrp7 group by veh_id, cust_id having count(*) > 1)


-- Display the top customer in terms of billing
select customer_id, sum(amount) from SYS.customer c join sys.rents@orclgrp7 r on c.customer_id = r.cust_id
join SYS.payment@orclgrp7 p on 
r.trip_id = p.trip_id where p.payment_status = 'SUCCESS' group by customer_id
having sum(amount) =(select max(sum(amount)) from SYS.customer c join sys.rents@orclgrp7 r on c.customer_id = r.cust_id
join SYS.payment@orclgrp7 p on 
r.trip_id = p.trip_id where p.payment_status = 'SUCCESS' group by customer_id);


--update employee salary who are not managers
update SYS.employee@orclgrp7 set salary = salary * 1.2
where empno not in (select distinct manager from SYS.employee@orclgrp7 where manager is not null);
 
commit;


--update employee salary by 10% hike who are managers
update SYS.employee@orclgrp7 set salary = salary * 1.1
where empno  in (select distinct manager from SYS.employee@orclgrp7);
 
commit;

--User for trip 107 wants to update the rating to 3. Please write a query
update SYS.reviews@orclgrp7 set rating = 3 where trip_id = 107;
commit;

--Customer 16605312 updated their license details with new expiry as 01-January-2023.
update SYS.driver_license@orclgrp7 set date_expired = '01-January-2023' where customer_id = '16605312';
 commit;
 
 --Update Trip 110 end mileage to 750
update SYS.rents@orclgrp7 set end_mileage = 750 where trip_id = 110; 
commit;

--Update Insurance Policy P005 coverage t0 100%
update SYS.insurance_policy@orclgrp7 set coverage_perc = 100 where policyid = 'P005';
commit;

--Delete customers with Expired License
delete from sys.customer@orclgrp7 where customer_id in (select customer_id from sys.driver_license@orclgrp7 where date_expired < current_date)
commit;

delete from sys.vehicle@orclgrp7 where veh_id in (select vehicle_id from sys.reviews@orclgrp7 group by 
vehicle_id having avg(rating) = (select min(avg(rating)) from sys.reviews@orclgrp7 group by vehicle_id));
commit;

--Delete the least earning employee
delete from sys.employeer@orclgrp7 where salary =(select min(salary) from sys.employeer@orclgrp7)
commit;

--Delete cars make older than 2 yrs
delete from sys.vehicle@orclgrp7 where to_char(current_date,'yyyy') - make_year > 2;
commit;

--Delete Offices with no bookings
delete from sys.facility@orclgrp7 where facilityid in (select facilityid from sys.facility@orclgrp7 f left join sys.rents@orclgrp7 r on r.facility = f.facilityid where r.facility is null);
commit;


--Delete all failure payments
delete from SYS.payment@orclgrp7 where payment_status = 'FAILED');
commit;
