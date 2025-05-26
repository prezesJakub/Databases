using System;
using System.Linq;
ProdContext prodContext = new ProdContext();
Console.WriteLine("Podaj nazwę produktu: ");
String? prodName = Console.ReadLine();
Product product = new Product { ProductName = prodName };
prodContext.Products.Add(product);
prodContext.SaveChanges();

var query = from prod in prodContext.Products
            select prod.ProductName;

foreach (var pName in query)
{
    Console.WriteLine(pName);
}
