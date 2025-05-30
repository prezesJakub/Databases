package org.example;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class Supplier {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String companyName;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "address_id")
    private Address address;

    @OneToMany(mappedBy = "supplier", cascade = CascadeType.ALL)
    private List<Product> products = new ArrayList<>();

    public Supplier() {}

    public Supplier(String companyName, String street, String city) {
        this.companyName = companyName;
        this.address = new Address(street, city);
    }

    public int getId() {
        return id;
    }
    public String getCompanyName() {
        return companyName;
    }
    public Address getAddress() {
        return address;
    }

    public void addProduct(Product product) {
        products.add(product);
        product.setSupplier(this);
    }
}
