ALTER TRIGGER tr_add_reservation_6_before_insert DISABLE;
ALTER TRIGGER tr_modify_reservation_6_after_update DISABLE;
ALTER TRIGGER tr_modify_reservation_status_6_before_update DISABLE;

CREATE OR REPLACE TRIGGER tr_add_reservation_6b_before_insert
BEFORE INSERT ON RESERVATION
FOR EACH ROW
DECLARE
    v_available_places NUMBER;
    v_trip_date DATE;
BEGIN
    SELECT trip_date, no_available_places INTO v_trip_date, v_available_places
    FROM TRIP WHERE trip_id = :NEW.trip_id FOR UPDATE;

    IF v_trip_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nie można zarezerwować miejsc na wycieczkę, która już się odbyła');
    end if;

    IF v_available_places < :NEW.no_tickets THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak wystarczających miejsc na wycieczkę');
    end if;

    UPDATE TRIP
    SET no_available_places = no_available_places - :NEW.no_tickets
    WHERE trip_id = :NEW.trip_id;
end;

CREATE OR REPLACE TRIGGER tr_modify_reservation_6b_after_update
AFTER UPDATE OF no_tickets ON RESERVATION
FOR EACH ROW
BEGIN
    UPDATE TRIP
    SET no_available_places = no_available_places - (:NEW.no_tickets - :OLD.no_tickets)
    WHERE trip_id = :NEW.trip_id;
end;

CREATE OR REPLACE TRIGGER tr_modify_reservation_status_6b_before_update
BEFORE UPDATE OF status ON RESERVATION
FOR EACH ROW
DECLARE
    v_available_places NUMBER;
BEGIN
    IF :OLD.status IN ('N', 'P') AND :NEW.status = 'C' THEN
        UPDATE TRIP
        SET no_available_places = no_available_places + :OLD.no_tickets
        WHERE trip_id = :OLD.trip_id;
    ELSIF :OLD.status = 'C' AND :NEW.status IN ('N', 'P') THEN
        SELECT no_available_places INTO v_available_places FROM TRIP
        WHERE trip_id = :NEW.trip_id;

        IF v_available_places < :NEW.no_tickets THEN
            RAISE_APPLICATION_ERROR(-20006, 'Brak wystarczającej liczby miejsc na przywrócenie rezerwacji');
        end if;

        UPDATE TRIP
        SET no_available_places = no_available_places - :NEW.no_tickets
        WHERE trip_id = :NEW:trip_id;
    end if;
end;

CREATE OR REPLACE PROCEDURE p_add_reservation_6b(
    p_trip_id IN RESERVATION.trip_id%TYPE,
    p_person_id IN RESERVATION.person_id%TYPE,
    p_no_tickets IN NUMBER
) AS
BEGIN
    INSERT INTO RESERVATION(trip_id, person_id, no_tickets, status)
    VALUES(p_trip_id, p_person_id, p_no_tickets, 'N');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znaleziono wycieczki');
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_6b(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_status IN RESERVATION.status%TYPE
) AS
BEGIN
    UPDATE RESERVATION SET status = p_status WHERE reservation_id = p_reservation_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Nie znaleziono rezerwacji');
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_6b(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_no_tickets IN NUMBER
) AS
BEGIN
    UPDATE RESERVATION SET no_tickets = p_no_tickets WHERE reservation_id = p_reservation_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Nie znaleziono rezerwacji');
end;