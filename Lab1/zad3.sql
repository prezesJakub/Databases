CREATE OR REPLACE PROCEDURE p_add_reservation(
    p_trip_id IN RESERVATION.trip_id%TYPE,
    p_person_id IN RESERVATION.person_id%TYPE,
    p_no_ticket IN NUMBER
) AS
    v_max_places TRIP.max_no_places%TYPE;
    v_reserved_places NUMBER;
    v_trip_date TRIP.trip_date%TYPE;
BEGIN
    SELECT MAX_NO_PLACES, TRIP_DATE INTO v_max_places, v_trip_date
    FROM TRIP WHERE TRIP_ID = p_trip_id;

    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie można zarezerwować miejsca na wycieczkę, która już się odbyła');
    end if;

    SELECT COALESCE(SUM(no_tickets), 0) INTO v_reserved_places FROM RESERVATION WHERE TRIP_ID = p_trip_id AND status != 'C';;

    IF v_reserved_places + p_no_ticket > v_max_places THEN
        RAISE_APPLICATION_ERROR(-20002, 'Brak wystarczającej liczby miejsc na wycieczkę');
    end if;

    INSERT INTO RESERVATION(trip_id, person_id, status)
    VALUES (p_trip_id, p_person_id, 'N');

    INSERT INTO log (reservation_id, LOG_DATE, status)
    VALUES (S_RESERVATION_SEQ.currval, SYSDATE, 'N');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znalziono wycieczki');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_status(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_status IN RESERVATION.status%TYPE
) AS
    v_trip_id RESERVATION.trip_id%TYPE;
    v_max_places TRIP.max_no_places%TYPE;
    v_reserved_places NUMBER;
    v_old_status RESERVATION.status%TYPE;
BEGIN
    SELECT trip_id, status INTO v_trip_id, v_old_status
    FROM reservation WHERE reservation_id = p_reservation_id;

    SELECT max_no_places INTO v_max_places FROM TRIP WHERE trip_id = v_trip_id;
    SELECT COALESCE(SUM(no_tickets), 0) INTO v_reserved_places FROM RESERVATION WHERE trip_id = v_trip_id AND status != 'C';

    IF v_old_status = 'C' AND v_reserved_places >= v_max_places THEN
        RAISE_APPLICATION_ERROR(-20004, 'Brak miejsc na wycieczkę');
    end if;

    UPDATE RESERVATION SET status = p_status WHERE reservation_id = p_reservation_id;

    INSERT INTO log (reservation_id, log_date, status)
    VALUES (p_reservation_id, SYSDATE, p_status);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Nie znaleziono rezerwacji');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_no_tickets IN NUMBER
) AS
    v_trip_id RESERVATION.trip_id%TYPE;
    v_max_places TRIP.max_no_places%TYPE;
    v_reserved_places NUMBER;
    v_current_tickets NUMBER;
BEGIN
    SELECT trip_id, no_tickets INTO v_trip_id, v_current_tickets FROM RESERVATION WHERE reservation_id = p_reservation_id;
    SELECT max_no_places INTO v_max_places FROM TRIP WHERE trip_id = v_trip_id;
    SELECT COALESCE(SUM(no_tickets), 0) INTO v_reserved_places FROM RESERVATION WHERE trip_id = v_trip_id AND status != 'C';

    IF v_reserved_places - v_current_tickets + p_no_tickets > v_max_places THEN
        RAISE_APPLICATION_ERROR(-20006, 'Brak wystarczającej liczby miejsc na wycieczkę');
    end if;

    UPDATE RESERVATION SET no_tickets = p_no_tickets WHERE reservation_id = p_reservation_id;

    INSERT INTO log (reservation_id, log_date, status)
    VALUES (p_reservation_id, SYSDATE, 'P');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, 'Nie znaleziono rezerwacji');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

CREATE OR REPLACE PROCEDURE p_modify_max_no_places(
    p_trip_id IN TRIP.trip_id%TYPE,
    p_max_no_places IN TRIP.max_no_places%TYPE
) AS
    v_reserved_places NUMBER;
BEGIN
    SELECT COALESCE(SUM(no_tickets), 0) INTO v_reserved_places FROM RESERVATION WHERE trip_id = p_trip_id AND status != 'C';

    IF p_max_no_places < v_reserved_places THEN
        RAISE_APPLICATION_ERROR(-20008, 'Nie można zmniejszyć liczby miejsc poniżej liczby zarezerwowanych miejsc');
    end if;

    UPDATE TRIP SET max_no_places = p_max_no_places WHERE trip_id = p_trip_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20009, 'Nie znaleziono wycieczki');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

--test
select * from RESERVATION;
BEGIN
    p_modify_reservation_status(21, 'P');
END;
BEGIN
    p_modify_reservation(21, 3);
END;
BEGIN
    p_modify_max_no_places(4, 3);
END;

select * from VW_AVAILABLE_TRIP;
SELECT * FROM TABLE(f_trip_participants(2));