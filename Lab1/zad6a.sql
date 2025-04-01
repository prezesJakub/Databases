ALTER TRIGGER tr_add_reservation_6_before_insert DISABLE;
ALTER TRIGGER tr_modify_reservation_6_after_update DISABLE;
ALTER TRIGGER tr_modify_reservation_status_6_before_update DISABLE;

CREATE OR REPLACE PROCEDURE p_add_reservation_6a(
    p_trip_id IN RESERVATION.trip_id%TYPE,
    p_person_id IN RESERVATION.person_id%TYPE,
    p_no_tickets IN NUMBER
) AS
    v_available_places NUMBER;
    v_trip_date DATE;
BEGIN
    SELECT trip_date, no_available_places INTO v_trip_date, v_available_places
    FROM TRIP WHERE trip_id = p_trip_id FOR UPDATE;

    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nie można zarezerwować miejsc na wycieczkę, która już się odbyła');
    end if;

    IF v_available_places < p_no_tickets THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak wystarczających miejsc na wycieczkę');
    end if;

    INSERT INTO RESERVATION(trip_id, person_id, no_tickets, status)
    VALUES(p_trip_id, p_person_id, p_no_tickets, 'N');

    UPDATE TRIP
    SET no_available_places = no_available_places - p_no_tickets
    WHERE trip_id = p_trip_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znaleziono wycieczki');
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_6a(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_status IN RESERVATION.status%TYPE
) AS
    v_trip_id RESERVATION.trip_id%TYPE;
    v_no_tickets RESERVATION.no_tickets%TYPE;
    v_old_status RESERVATION.status%TYPE;
    v_available_places NUMBER;
BEGIN
    SELECT trip_id, no_tickets, status INTO v_trip_id, v_no_tickets, v_old_status
    FROM RESERVATION WHERE reservation_id = p_reservation_id FOR UPDATE;

    UPDATE RESERVATION SET status = p_status WHERE reservation_id = p_reservation_id;

    IF v_old_status IN ('N', 'P') AND p_status = 'C' THEN
        UPDATE TRIP SET no_available_places = no_available_places + v_no_tickets
        WHERE trip_id = v_trip_id;
    ELSIF v_old_status = 'C' AND p_status IN ('N', 'P') THEN
        SELECT no_available_places INTO v_available_places FROM TRIP
        WHERE trip_id = v_trip_id;

        IF v_available_places < v_no_tickets THEN
            RAISE_APPLICATION_ERROR(-20006, 'Brak wystarczających miejsc na przywrócenie rezerwacji');
        end if;

        UPDATE TRIP SET no_available_places = no_available_places - v_no_tickets
        WHERE trip_id = v_trip_id;
    end if;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Nie znaleziono rezerwacji');
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_6a(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_no_tickets IN NUMBER
) AS
    v_trip_id RESERVATION.trip_id%TYPE;
    v_old_no_tickets RESERVATION.no_tickets%TYPE;
    v_status RESERVATION.status%TYPE;
    v_available_places NUMBER;
BEGIN
    SELECT trip_id, no_tickets, status INTO v_trip_id, v_old_no_tickets, v_status
    FROM RESERVATION WHERE reservation_id = p_reservation_id FOR UPDATE;

    SELECT no_available_places INTO v_available_places FROM TRIP WHERE trip_id = v_trip_id;

    IF p_no_tickets > v_old_no_tickets AND v_available_places < (p_no_tickets - v_old_no_tickets) THEN
        RAISE_APPLICATION_ERROR(-20009, 'Brak wystarczającej liczby miejsc na wycieczkę');
    end if;

    UPDATE RESERVATION SET no_tickets = p_no_tickets WHERE reservation_id = p_reservation_id;

    UPDATE TRIP SET no_available_places = no_available_places - (p_no_tickets - v_old_no_tickets)
    WHERE trip_id = v_trip_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Nie znaleziono rezerwacji');
end;

CREATE OR REPLACE PROCEDURE p_modify_max_no_places_6a(
    p_trip_id IN TRIP.trip_id%TYPE,
    p_new_max_no_places IN TRIP.max_no_places%TYPE
) AS
    v_reserved_places NUMBER;
BEGIN
    SELECT SUM(no_tickets) INTO v_reserved_places
    FROM RESERVATION WHERE trip_id = p_trip_id AND status IN ('N', 'P');

    IF p_new_max_no_places < v_reserved_places THEN
        RAISE_APPLICATION_ERROR(-20007, 'Nowa maksymalna liczba miejc nie może być mniejsza niż liczba już zarezerwowanych miejsc');
    end if;

    UPDATE TRIP SET max_no_places = p_new_max_no_places WHERE trip_id = p_trip_id;

    p_recalculate_no_available_places_6;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008, 'Nie znaleziono wycieczki');
end;

SELECT * FROM VW_AVAILABLE_TRIP;
SELECT * FROM VW_RESERVATION;

BEGIN
    p_modify_max_no_places_6a(3, 8);
END;
BEGIN
    p_add_reservation_6a(3, 13, 2);
END;

BEGIN
    p_modify_reservation_status_6a(81, 'P');
end;