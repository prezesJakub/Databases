package org.example;

import jakarta.persistence.Entity;

@Entity
public class Customer extends Company {
    public double discount;

    public Customer() {}

    public Customer(String companyName, String street, String city, String zipCode, double discount) {
        super(companyName, street, city, zipCode);
        this.discount = discount;
    }

    public double getDiscount() {
        return discount;
    }
}
