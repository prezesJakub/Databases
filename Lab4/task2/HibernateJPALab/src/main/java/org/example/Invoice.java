package org.example;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
public class Invoice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int invoiceId;

    private String invoiceNumber;

    @OneToMany(mappedBy = "invoice", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<InvoiceProduct> invoiceProducts = new ArrayList<>();

    public Invoice() {}

    public Invoice(String invoiceNumber) {
        this.invoiceNumber = invoiceNumber;
    }

    public int getInvoiceId() {
        return invoiceId;
    }
    public String getInvoiceNumber() {
        return invoiceNumber;
    }
    public List<InvoiceProduct> getInvoiceProducts() {
        return invoiceProducts;
    }
    public void addProduct(Product product, int quantity) {
        InvoiceProduct ip = new InvoiceProduct(this, product, quantity);
        invoiceProducts.add(ip);
        product.getInvoiceProducts().add(ip);
    }
}
