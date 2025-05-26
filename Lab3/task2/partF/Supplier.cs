using System.Collections.Generic;

public class Supplier : Company
{
    public String? BankAccountNumber { get; set; }

    public List<Product> Products { get; set; } = new();
}