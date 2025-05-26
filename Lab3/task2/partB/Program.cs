using System;
using System.Linq;

ProdContext prodContext = new ProdContext();
prodContext.Database.EnsureCreated();

Console.WriteLine("Podaj nazwę produktu: ");
String? prodName = Console.ReadLine();

Product product = new Product 
{ 
    ProductName = prodName,
    UnitsOnStock = 10,
};

prodContext.Products.Add(product);
prodContext.SaveChanges();

Console.WriteLine("Podaj nazwę firmy dostawcy: ");
String? companyName = Console.ReadLine();
Console.WriteLine("Podaj miasto: ");
String? cityName = Console.ReadLine();
Console.WriteLine("Podaj ulicę: ");
String? streetName = Console.ReadLine();

Supplier supplier = new Supplier
{
    CompanyName = companyName,
    Street = streetName,
    City = cityName,
    ProductId = product.ProductId
};

prodContext.Suppliers.Add(supplier);
prodContext.SaveChanges();

var query = from prod in prodContext.Products
            select new 
            { 
                prod.ProductName, 
                Company = prod.Supplier != null ? prod.Supplier.CompanyName : "Brak dostawcy" 
            };

foreach (var item in query)
{
    Console.WriteLine($"Produkt: {item.ProductName}, Dostawca: {item.Company}");
}