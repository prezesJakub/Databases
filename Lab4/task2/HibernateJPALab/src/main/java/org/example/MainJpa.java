package org.example;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Persistence;

public class MainJpa {
    public static void main(String[] args) {
        EntityManagerFactory emf = Persistence.createEntityManagerFactory("myJpaUnit");
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();

        tx.begin();

        Supplier supplier1 = new Supplier("Biurmax", "Papierowa 8", "Gdańsk");
        Supplier supplier2 = new Supplier("PaperPro", "Uliczna 10", "Warszawa");
        Supplier supplier3 = new Supplier("NoProductCompany", "Pusta 1", "Poznań");

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

        em.persist(supplier1);
        em.persist(supplier2);
        em.persist(supplier3);
        em.persist(officeSupplies);
        em.persist(writingTools);

        Invoice invoice1 = new Invoice("0001");
        Invoice invoice2 = new Invoice("0002");

        invoice1.addProduct(p1, 3);
        invoice1.addProduct(p2, 2);

        invoice2.addProduct(p2, 5);
        invoice2.addProduct(p3, 1);

        Invoice invoice3 = new Invoice("0003");

        Product p5 = new Product("Kalkulator", 20);
        Product p6 = new Product("Marker", 30);

        invoice3.addProduct(p5, 2);
        invoice3.addProduct(p6, 3);

        em.persist(invoice1);
        em.persist(invoice2);
        em.persist(invoice3);

        Product p7 = new Product("Teczka", 10);

        Invoice invoice4 = new Invoice("0004");

        invoice4.addProduct(p7, 1);

        em.persist(invoice4);

        tx.commit();
        em.close();
        emf.close();
    }
}
