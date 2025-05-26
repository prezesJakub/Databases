using System;
using System.Linq;

ProdContext prodContext = new ProdContext();
prodContext.Database.EnsureCreated();

Console.WriteLine("Podaj nazwę firmy dostawcy: ");
String? companyName = Console.ReadLine();
Console.WriteLine("Podaj miasto: ");
String? cityName = Console.ReadLine();
Console.WriteLine("Podaj ulicę: ");
String? streetName = Console.ReadLine();

var supplier = new Supplier
{
    CompanyName = companyName,
    Street = streetName,
    City = cityName,
};

prodContext.Suppliers.Add(supplier);
prodContext.SaveChanges();

Console.WriteLine("Podaj liczbę produktów:");
if (!int.TryParse(Console.ReadLine(), out int productCount) || productCount < 1)
{
    Console.WriteLine("Nieprawidłowa liczba produktów.");
    return;
}

for (int i = 0; i < productCount; i++)
{
    Console.WriteLine($"Podaj nazwę produktu {i + 1}:");
    String? productName = Console.ReadLine();

    var product = new Product 
    { 
        ProductName = productName,
        UnitsOnStock = 10,
        SupplierId = supplier.SupplierId
    };

    prodContext.Products.Add(product);
}

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