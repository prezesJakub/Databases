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

        Supplier supplier1 = new Supplier("Biurmax", "Papierowa 8", "Gdańsk", "00-001", "11111111");
        Supplier supplier2 = new Supplier("PaperPro", "Uliczna 10", "Warszawa", "00-002", "22222222");
        Supplier supplier3 = new Supplier("NoProductCompany", "Pusta 1", "Poznań", "50-031", "13131313");

        Category officeSupplies = new Category("Artykuły biurowe");
        Category writingTools = new Category("Przybory do pisania");

        Product p1 = new Product("Spinacz", 10);
        Product p2 = new Product("Zszywacz", 15);
        Product p3 = new Product("Długopis", 50);
        Product p4 = new Product("Linijka", 25);

        supplier1.addProduct(p1);
        supplier1.addProduct(p2);
        supplier1.addProduct(p3);
        supplier2.addProduct(p4);

        officeSupplies.addProduct(p1);
        officeSupplies.addProduct(p2);
        officeSupplies.addProduct(p4);
        writingTools.addProduct(p3);

        session.persist(supplier1);
        session.persist(supplier2);
        session.persist(supplier3);
        session.persist(officeSupplies);
        session.persist(writingTools);

        Invoice invoice1 = new Invoice("0001");
        Invoice invoice2 = new Invoice("0002");

        invoice1.addProduct(p1, 3);
        invoice1.addProduct(p2, 2);

        invoice2.addProduct(p2, 5);
        invoice2.addProduct(p3, 1);

        session.persist(invoice1);
        session.persist(invoice2);

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