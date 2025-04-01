CREATE OR REPLACE TYPE t_reservation_view_row AS OBJECT (
    reservation_id INT,
    country VARCHAR2(50),
    trip_date DATE,
    trip_name VARCHAR2(100),
    firstname VARCHAR2(50),
    lastname VARCHAR2(50),
    status CHAR(1),
    trip_id INT,
    person_id INT,
    no_tickets INT
);

CREATE OR REPLACE TYPE t_reservation_view_table AS TABLE OF t_reservation_view_row;

CREATE OR REPLACE FUNCTION f_trip_participants(trip_id IN INT)
RETURN t_reservation_view_table PIPELINED AS
BEGIN
    FOR rec IN (
        SELECT
            R.RESERVATION_ID,
            T.COUNTRY,
            T.TRIP_DATE,
            T.TRIP_NAME,
            P.FIRSTNAME,
            P.LASTNAME,
            R.STATUS,
            R.TRIP_ID,
            R.PERSON_ID,
            R.NO_TICKETS
        FROM RESERVATION R
        JOIN TRIP T ON R.TRIP_ID=T.TRIP_ID
        JOIN PERSON P ON R.PERSON_ID=P.PERSON_ID
        WHERE R.TRIP_ID = f_trip_participants.trip_id
    )
    LOOP
        PIPE ROW (t_reservation_view_row(
                rec.RESERVATION_ID, rec.COUNTRY, rec.TRIP_DATE,
                rec.TRIP_NAME, rec.FIRSTNAME, rec.LASTNAME,
                rec.STATUS, rec.TRIP_ID, rec.PERSON_ID,
                rec.NO_TICKETS
                  ));
    end loop;
    return;
end;

SELECT * FROM TABLE(f_trip_participants(4));

CREATE OR REPLACE FUNCTION f_person_reservations(person_id IN INT)
RETURN t_reservation_view_table PIPELINED AS
BEGIN
    FOR rec IN (
        SELECT
            R.RESERVATION_ID,
            T.COUNTRY,
            T.TRIP_DATE,
            T.TRIP_NAME,
            P.FIRSTNAME,
            P.LASTNAME,
            R.STATUS,
            R.TRIP_ID,
            R.PERSON_ID,
            R.NO_TICKETS
        FROM RESERVATION R
        JOIN TRIP T ON R.TRIP_ID=T.TRIP_ID
        JOIN PERSON P ON R.PERSON_ID=P.PERSON_ID
        WHERE R.PERSON_ID = f_person_reservations.PERSON_ID
    )
    LOOP
        PIPE ROW (t_reservation_view_row(
                rec.RESERVATION_ID, rec.COUNTRY, rec.TRIP_DATE,
                rec.TRIP_NAME, rec.FIRSTNAME, rec.LASTNAME,
                rec.STATUS, rec.TRIP_ID, rec.PERSON_ID,
                rec.NO_TICKETS
                  ));
    end loop;
    return;
end;

SELECT * FROM TABLE(f_person_reservations(10));

CREATE OR REPLACE TYPE trip_view_row AS OBJECT (
    trip_id INT,
    trip_name VARCHAR2(100),
    country VARCHAR2(50),
    trip_date DATE,
    max_no_places INT,
    no_available_places INT
);

CREATE OR REPLACE TYPE trip_view_table AS TABLE OF trip_view_row;

CREATE OR REPLACE FUNCTION f_available_trips_to(
    country IN VARCHAR2,
    date_from IN DATE,
    date_to IN DATE
)
RETURN trip_view_table PIPELINED AS
BEGIN
    FOR rec IN (
        SELECT T.TRIP_ID, T.TRIP_NAME, T.COUNTRY, T.TRIP_DATE, T.MAX_NO_PLACES, T.NO_AVAILABLE_PLACES
        FROM VW_TRIP T
        WHERE T.country = f_available_trips_to.country
        AND (T.TRIP_DATE BETWEEN date_from AND date_to)
        AND T.NO_AVAILABLE_PLACES > 0
    )
    LOOP
        PIPE ROW (trip_view_row(
            rec.TRIP_ID, rec.TRIP_NAME, rec.COUNTRY, rec.TRIP_DATE, rec.MAX_NO_PLACES, rec.NO_AVAILABLE_PLACES
        ));
    end loop;
    return;
end;

SELECT * FROM TABLE(f_available_trips_to('Polska', TO_DATE('2025-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD')));

SELECT * FROM VW_TRIP;
SELECT * FROM VW_AVAILABLE_TRIP;

SELECT * FROM VW_RESERVATION;