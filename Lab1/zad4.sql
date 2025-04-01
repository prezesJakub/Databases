CREATE OR REPLACE TRIGGER trg_log_add_reservation
AFTER INSERT ON RESERVATION
FOR EACH ROW
BEGIN
    INSERT INTO log (reservation_id, log_date, status)
    VALUES (:NEW.reservation_id, SYSDATE, :NEW.status);
end;

CREATE OR REPLACE TRIGGER trg_log_modify_status
AFTER UPDATE OF status ON RESERVATION
FOR EACH ROW
WHEN (OLD.status != NEW.status)
BEGIN
    INSERT INTO log (reservation_id, log_date, status)
    VALUES (:NEW.reservation_id, SYSDATE, :NEW.status);
end;

CREATE OR REPLACE TRIGGER trg_log_modify_tickets
AFTER UPDATE OF no_tickets ON RESERVATION
FOR EACH ROW
WHEN (OLD.no_tickets != NEW.no_tickets)
BEGIN
    INSERT INTO log (reservation_id, log_date, status)
    VALUES (:NEW.reservation_id, SYSDATE, :NEW.status);
end;

CREATE OR REPLACE TRIGGER trg_prevent_delete_reservation
BEFORE DELETE ON RESERVATION
FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20010, 'Usunięcie rezerwacji jest zabronione');
end;

CREATE OR REPLACE PROCEDURE p_add_reservation_4(
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
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znalziono wycieczki');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_status_4(
    p_reservation_id IN RESERVATION.reservation_id%TYPE,
    p_status IN RESERVATION.status%TYPE
) AS
    v_trip_id RESERVATION.trip_id%TYPE;
    v_max_places TRIP.max_no_places%TYPE;
    v_reserved_places NUMBER;
    v_old_status RESERVATION.status%TYPE;
BEGIN
    SELECT trip_id, status INTO v_trip_id, v_old_status
    FROM RESERVATION WHERE reservation_id = p_reservation_id;

    SELECT max_no_places INTO v_max_places FROM TRIP WHERE trip_id = v_trip_id;
    SELECT COALESCE(SUM(no_tickets), 0) INTO v_reserved_places FROM RESERVATION WHERE trip_id = v_trip_id AND status != 'C';

    IF v_old_status = 'C' AND v_reserved_places >= v_max_places THEN
        RAISE_APPLICATION_ERROR(-20004, 'Brak miejsc na wycieczkę');
    end if;

    UPDATE RESERVATION SET status = p_status WHERE reservation_id = p_reservation_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Nie znaleziono rezerwacji');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;

CREATE OR REPLACE PROCEDURE p_modify_reservation_4(
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
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, 'Nie znaleziono rezerwacji');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end;
