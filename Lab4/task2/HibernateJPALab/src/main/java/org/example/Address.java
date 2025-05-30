package org.example;

import jakarta.persistence.*;
import org.h2.engine.User;

@Entity
public class Address {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String street;
    private String city;

    @OneToOne(mappedBy = "address")
    private Supplier supplier;

    public Address() {}

    public Address(String street, String city) {
        this.street = street;
        this.city = city;
    }

    public int getId() {
        return id;
    }

    public String getStreet() {
        return street;
    }

    public String getCity() {
        return city;
    }
    public Supplier getSupplier() {
        return supplier;
    }
}
