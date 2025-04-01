select * from person

ALTER TABLE reservation ADD no_tickets INT DEFAULT 1 NOT NULL;

ALTER TABLE log ADD no_tickets INT DEFAULT 1 NOT NULL;

BEGIN
    INSERT INTO reservation (trip_id, person_id, status, no_tickets)
    VALUES (3, 3, 'N', 2);

    INSERT INTO log (reservation_id, log_date, status, no_tickets)
    VALUES (s_reservation_seq.currval, SYSDATE, 'N', 2);

    COMMIT;
END;

begin
    insert into person (firstname, lastname)
    values ('Maciej', 'Antoniuk');
    insert into person (firstname, lastname)
    values ('Wiktor', 'Szczepaniak');

    rollback;
end;

select * from person;

begin
    insert into person (firstname, lastname)
    values ('Maciej', 'Antoniuk');
    insert into person (firstname, lastname)
    values ('Wiktor', 'Szczepaniak');

    commit;
end;

