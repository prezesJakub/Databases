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
    private String street;
    private String city;

    @OneToMany(mappedBy = "supplier", cascade = CascadeType.ALL)
    private List<Product> products = new ArrayList<>();

    public Supplier() {}

    public Supplier(String companyName, String street, String city) {
        this.companyName = companyName;
        this.street = street;
        this.city = city;
    }

    public int getId() {
        return id;
    }
    public String getCompanyName() {
        return companyName;
    }
    public String getStreet() {
        return street;
    }
    public String getCity() {
        return city;
    }

    public void addProduct(Product product) {
        products.add(product);
        product.setSupplier(this);
    }
}
