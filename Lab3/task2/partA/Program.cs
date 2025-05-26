using System;
using System.Linq;

ProdContext prodContext = new ProdContext();

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
    City = cityName
};

prodContext.Suppliers.Add(supplier);
prodContext.SaveChanges();

Console.WriteLine("Podaj nazwę produktu: ");
String? prodName = Console.ReadLine();

Product product = new Product 
{ 
    ProductName = prodName,
    UnitsOnStock = 10,
    SupplierId = supplier.SupplierId
};

prodContext.Products.Add(product);
prodContext.SaveChanges();

var query = from prod in prodContext.Products
            select new { prod.ProductName, prod.Supplier.CompanyName };

foreach (var item in query)
{
    Console.WriteLine($"Produkt: {item.ProductName}, Dostawca: {item.CompanyName}");
}
