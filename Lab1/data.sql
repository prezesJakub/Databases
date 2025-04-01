-- trip
insert into trip(trip_name, country, trip_date, max_no_places)
values ('Romantyczny Paryz', 'Francja', to_date('2023-09-12', 'YYYY-MM-DD'), 3);

insert into trip(trip_name, country, trip_date, max_no_places)
values ('Piekny Krakow', 'Polska', to_date('2025-05-03','YYYY-MM-DD'), 6);

insert into trip(trip_name, country, trip_date, max_no_places)
values ('Urokliwe kaniony', 'USA', to_date('2025-05-01','YYYY-MM-DD'), 6);

insert into trip(trip_name, country, trip_date, max_no_places)
values ('Hel', 'Polska', to_date('2025-05-01','YYYY-MM-DD'), 2);
-- person
insert into person(firstname, lastname)
values ('Jan', 'Nowak');

insert into person(firstname, lastname)
values ('Jan', 'Kowalski');

insert into person(firstname, lastname)
values ('Jan', 'Nowakowski');

insert into person(firstname, lastname)
values ('Novak', 'Nowak');

insert into person(firstname, lastname)
values ('Grzegorz', 'Brzeczyszczykiewicz');

insert into person(firstname, lastname)
values ('Michal', 'Kichal');

insert into person(firstname, lastname)
values ('Grzegorz', 'Brzeczyszczykiewicz');

insert into person(firstname, lastname)
values ('Leon', 'Michalak');

insert into person(firstname, lastname)
values ('Wieslaw', 'Parowka');

insert into person(firstname, lastname)
values ('Julia', 'Dymecka');
-- reservation
-- trip1
insert into reservation(trip_id, person_id, status)
values (1, 1, 'P');

insert into reservation(trip_id, person_id, status)
values (1, 2, 'N');

insert into reservation(trip_id, person_id, status)
values (1, 10, 'P');

insert into reservation(trip_id, person_id, status)
values (1, 8, 'P');

-- trip 2
insert into reservation(trip_id, person_id, status)
values (2, 1, 'P');

insert into reservation(trip_id, person_id, status)
values (2, 4, 'C');

insert into reservation(trip_id, person_id, status)
values (2, 6, 'N');

insert into reservation(trip_id, person_id, status)
values (2, 10, 'P');

-- trip 3
insert into reservation(trip_id, person_id, status)
values (3, 4, 'P');

insert into reservation(trip_id, person_id, status)
values (3, 5, 'C');