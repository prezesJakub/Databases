using System;
using System.Linq;

ProdContext prodContext = new ProdContext();
prodContext.Database.EnsureCreated();

Console.WriteLine("Wybierz akcję:");
Console.WriteLine("1. Dodaj dostawcę i produkty");
Console.WriteLine("2. Stwórz fakturę i dodaj produkty");
Console.WriteLine("3. Wyświetl produkty w fakturze");
Console.WriteLine("4. Znajdź faktury z produktem");
Console.WriteLine("5. Wyświetl wszystkie produkty");
Console.Write("Twój wybór: ");

String? choice = Console.ReadLine();

switch (choice)
{
    case "1":
        AddSupplierAndProducts();
        break;
    case "2":
        CreateInvoice();
        break;
    case "3":
        ShowProductsInInvoice();
        break;
    case "4":
        ShowInvoiceWithProduct();
        break;
    case "5":
        ShowAllProducts();
        break;
    default:
        Console.WriteLine("Nieznana opcja");
        break;
}

void AddSupplierAndProducts()
{
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
    Console.WriteLine("Produkty i dostawca dodani");
}

void CreateInvoice()
{
    Console.WriteLine("Podaj numer faktury:");
    String? invoiceNumber = Console.ReadLine();

    var invoice = new Invoice
    {
        InvoiceNumber = invoiceNumber
    };
    prodContext.Invoices.Add(invoice);
    prodContext.SaveChanges();

    var allProducts = prodContext.Products.ToList();

    Console.WriteLine("Wybierz produkty do dodania do faktury:");

    for (int i = 0; i < allProducts.Count; i++)
    {
        Console.WriteLine($"{i + 1}. {allProducts[i].ProductName}");
    }

    while (true)
    {
        Console.WriteLine("Podaj numer produktu (0 aby zakończyć):");
        if (!int.TryParse(Console.ReadLine(), out int prodIndex) || prodIndex == 0)
            break;
    
        if (prodIndex < 1 || prodIndex > allProducts.Count)
        {
            Console.WriteLine("Nieprawidłowy numer produktu");
            continue;
        }

        var selectedProduct = allProducts[prodIndex - 1];

        Console.WriteLine($"Podaj ilość dla produktu {selectedProduct.ProductName}:");
        if (!int.TryParse(Console.ReadLine(), out int qty) || qty < 1)
        {
            Console.WriteLine("Nieprawidłowa ilość");
            continue;
        }

        prodContext.InvoiceProducts.Add(new InvoiceProduct
        {
            InvoiceId = invoice.InvoiceId,
            ProductId = selectedProduct.ProductId,
            Quantity = qty
        });
    }
    prodContext.SaveChanges();
    Console.WriteLine("Faktura utworzona.");
}

void ShowProductsInInvoice()
{
    Console.WriteLine("Podaj numer faktury:");
    String? invoiceNumber = Console.ReadLine();

    var invoice = prodContext.Invoices.FirstOrDefault(i => i.InvoiceNumber == invoiceNumber);
    if (invoice == null)
    {
        Console.WriteLine("Nie znaleziono faktury");
        return;
    }

    var soldProducts = prodContext.InvoiceProducts
        .Where(ip => ip.InvoiceId == invoice.InvoiceId)
        .Select(ip => new
        {
            ip.Product.ProductName,
            ip.Quantity
        });

    Console.WriteLine($"\nProdukty sprzedane w fakturze {invoice.InvoiceNumber}:");

    foreach (var item in soldProducts)
    {
        Console.WriteLine($"Produkt: {item.ProductName}, Ilość: {item.Quantity}");
    }
}

void ShowInvoiceWithProduct()
{
    Console.WriteLine("\nPodaj nazwę produktu, aby zobaczyć związane faktury:");
    String? productName = Console.ReadLine();

    var invoicesWithProduct = prodContext.InvoiceProducts
        .Where(ip => ip.Product.ProductName == productName)
        .Select(ip => ip.Invoice.InvoiceNumber)
        .Distinct()
        .ToList();

    if (invoicesWithProduct.Count == 0)
    {
        Console.WriteLine("Brak faktur zawierających ten produkt.");
    }
    else
    {
        Console.WriteLine($"Faktury zawierające produkt '{productName}':");

        foreach (var inv in invoicesWithProduct)
        {
            Console.WriteLine($"Faktura: {inv}");
        }
    }
}

void ShowAllProducts()
{
    var query = from prod in prodContext.Products
                select new 
                { 
                    prod.ProductName, 
                    Company = prod.Supplier != null ? prod.Supplier.CompanyName : "Brak dostawcy" 
                };

    Console.WriteLine("\nWszystkie produkty:");
    foreach (var item in query)
    {
        Console.WriteLine($"Produkt: {item.ProductName}, Dostawca: {item.Company}");
    }
}