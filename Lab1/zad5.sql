CREATE OR REPLACE TRIGGER trg_check_available_places
BEFORE INSERT ON RESERVATION
FOR EACH ROW
DECLARE
    v_max_places TRIP.max_no_places%TYPE;
    v_reserved_places NUMBER;
BEGIN
    SELECT max_no_places INTO v_max_places FROM TRIP WHERE trip_id = :NEW.trip_id;

    SELECT COALESCE(SUM(no_tickets), 0) INTO v_reserved_places
    FROM RESERVATION
    WHERE trip_id = :NEW.trip_id AND status != 'C';

    IF v_reserved_places + :NEW.no_tickets > v_max_places THEN
        RAISE_APPLICATION_ERROR(-20010, 'Brak wystarczającej liczby miejsc na wycieczkę');
    end if;
end;

CREATE OR REPLACE TRIGGER trg_check_status_update
BEFORE UPDATE of status ON RESERVATION
FOR EACH ROW
WHEN (NEW.status IN ('N', 'P'))
DECLARE
    v_max_places TRIP.max_no_places%TYPE;
    v_reserved_places NUMBER;
BEGIN
    SELECT max_no_places INTO v_max_places FROM TRIP WHERE trip_id = :NEW.trip_id;

    SELECT COALESCE(SUM(no_tickets), 0) INTO v_reserved_places
    FROM RESERVATION
    WHERE trip_id = :NEW.trip_id AND status != 'C';

    IF v_reserved_places > v_max_places THEN
        RAISE_APPLICATION_ERROR(-20011, 'Brak miejsc na wycieczkę');
    end if;
end;

CREATE OR REPLACE TRIGGER trg_check_ticket_update
BEFORE UPDATE of no_tickets ON RESERVATION
FOR EACH ROW
DECLARE
    v_max_places TRIP.max_no_places%TYPE;
    v_reserved_places NUMBER;
BEGIN
    SELECT max_no_places INTO v_max_places FROM TRIP WHERE trip_id = :NEW.trip_id;

    SELECT COALESCE(SUM(no_tickets), 0) INTO v_reserved_places
    FROM RESERVATION
    WHERE trip_id = :NEW.trip_id AND status != 'C';

    IF v_reserved_places - :OLD.no_tickets + :NEW.no_tickets > v_max_places THEN
        RAISE_APPLICATION_ERROR(-20012, 'Brak miejsc na wycieczkę');
    end if;
end;

CREATE OR REPLACE PROCEDURE p_add_reservation_5(
    p_trip_id IN RESERVATION.trip_id%TYPE,
    p_person_id IN RESERVATION.person_id%TYPE,
    p_no_ticket IN NUMBER
) AS
    v_trip_date TRIP.trip_date%TYPE;
BEGIN
    SELECT TRIP_DATE INTO v_trip_date
    FROM TRIP WHERE TRIP_ID = p_trip_id;

    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie można zarezerwować miejsca na wycieczkę, która już się odbyła');
    end if;

    INSERT INTO RESERVATION(trip_id, person_id, NO_TICKETS, status)
    VALUES (p_trip_id, p_person_id, p_no_ticket,'N');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znalziono wycieczki');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_5(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_status IN RESERVATION.status%TYPE
) AS
    v_trip_id RESERVATION.trip_id%TYPE;
    v_old_status RESERVATION.status%TYPE;
BEGIN
    SELECT trip_id, status INTO v_trip_id, v_old_status
    FROM RESERVATION WHERE reservation_id = p_reservation_id;

    UPDATE RESERVATION SET status = p_status WHERE reservation_id = p_reservation_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Nie znaleziono rezerwacji');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_5(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_no_tickets IN NUMBER
) AS
BEGIN
    UPDATE RESERVATION SET no_tickets = p_no_tickets WHERE reservation_id = p_reservation_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, 'Nie znaleziono rezerwacji');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

BEGIN
    p_add_reservation_5(3, 9, 1);
END;

select * from VW_RESERVATION;

BEGIN
    p_modify_reservation_status_5(42, 'P');
end;

BEGIN
    p_modify_reservation_5(42, 2);
end;