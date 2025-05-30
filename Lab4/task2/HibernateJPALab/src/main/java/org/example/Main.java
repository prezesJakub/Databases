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

        Supplier supplier = new Supplier("Firma Kredkowa", "Ulica Kolorowa 5", "Warszawa");
        session.save(supplier);

        Product product = new Product("Kredki", 111);
        session.save(product);

        product.setSupplier(supplier);

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