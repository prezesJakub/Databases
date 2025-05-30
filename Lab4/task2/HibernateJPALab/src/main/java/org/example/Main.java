package org.example;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

import java.io.ObjectInputFilter;

public class Main {
    private static SessionFactory sessionFactory = null;

    public static void main(String[] args) {
        sessionFactory = getSessionFactory();

        Session session = sessionFactory.openSession();
        Transaction tx = session.beginTransaction();

        Product p1 = new Product("Spinacz", 10);
        Product p2 = new Product("Zszywacz", 15);

        Supplier supplier = new Supplier("Biurmax", "Papierowa 8", "Gdańsk");
        supplier.addProduct(p1);
        supplier.addProduct(p2);

        session.persist(p1);
        session.persist(p2);
        session.persist(supplier);

        tx.commit();
        session.close();
    }

    private static SessionFactory getSessionFactory() {
        if (sessionFactory == null) {
            Configuration configuration = new Configuration();
            sessionFactory = configuration.configure().buildSessionFactory();
        }
        return sessionFactory;
    }
}