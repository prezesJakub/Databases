using System;
using System.Linq;

ProdContext prodContext = new ProdContext();
prodContext.Database.EnsureCreated();

Console.WriteLine("Wybierz akcję:");
Console.WriteLine("1. Dodaj dostawcę i produkty");
Console.WriteLine("2. Dodaj klienta");
Console.WriteLine("3. Stwórz fakturę i dodaj produkty");
Console.WriteLine("4. Wyświetl produkty w fakturze");
Console.WriteLine("5. Znajdź faktury z produktem");
Console.WriteLine("6. Wyświetl wszystkie produkty");
Console.Write("Twój wybór: ");

String? choice = Console.ReadLine();

switch (choice)
{
    case "1":
        AddSupplierAndProducts();
        break;
    case "2":
        AddCustomer();
        break;
    case "3":
        CreateInvoice();
        break;
    case "4":
        ShowProductsInInvoice();
        break;
    case "5":
        ShowInvoiceWithProduct();
        break;
    case "6":
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
    Console.WriteLine("Podaj kod pocztowy: ");
    String? zipCode = Console.ReadLine();

    var supplier = new Supplier
    {
        CompanyName = companyName,
        Street = streetName,
        City = cityName,
        ZipCode = zipCode
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
            CompanyId = supplier.CompanyId
        };

        prodContext.Products.Add(product);
    }
    prodContext.SaveChanges();
    Console.WriteLine("Produkty i dostawca dodani");
}

void AddCustomer()
{
    Console.WriteLine("Podaj nazwę klienta:");
    String? name = Console.ReadLine();
    Console.WriteLine("Podaj miasto:");
    String? city = Console.ReadLine();
    Console.WriteLine("Podaj ulicę: ");
    String? streetName = Console.ReadLine();
    Console.WriteLine("Podaj kod pocztowy: ");
    String? zipCode = Console.ReadLine();
    Console.WriteLine("Podaj zniżkę (liczba):");
    var discount = double.Parse(Console.ReadLine() ?? "0");

    var customer = new Customer
    {
        CompanyName = name,
        City = city,
        Street = streetName,
        ZipCode = zipCode,
        Discount = discount
    };

    prodContext.Customers.Add(customer);
    prodContext.SaveChanges();

    Console.WriteLine("Klient dodany.");
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

    var customers = prodContext.Customers.ToList();

    if (customers.Count > 0)
    {
        Console.WriteLine("Wybierz klienta:");
        for (int i = 0; i < customers.Count; i++)
        {
            Console.WriteLine($"{i + 1}. {customers[i].CompanyName}");
        }

        if (int.TryParse(Console.ReadLine(), out int custIndex) && custIndex >= 1 && custIndex <= customers.Count)
        {
            invoice.CustomerId = customers[custIndex - 1].CompanyId;
        }
    }

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

    var invoice = prodContext.Invoices
        .Where(i => i.InvoiceNumber == invoiceNumber)
        .Select(i => new
        {
            i.InvoiceNumber,
            Customer = i.Customer,
            Products = i.InvoiceProducts.Select(ip => new
            {
                ip.Product.ProductName,
                ip.Quantity,
                Supplier = ip.Product.Supplier.CompanyName
            }).ToList()
        })
        .FirstOrDefault();

    if (invoice == null)
    {
        Console.WriteLine("Nie znaleziono faktury");
        return;
    }

    Console.WriteLine($"\nFaktura: {invoice.InvoiceNumber}");
    Console.WriteLine($"Klient: {invoice.Customer.CompanyName}, Miasto: {invoice.Customer.City}, Ulica: {invoice.Customer.Street}, Kod pocztowy: {invoice.Customer.ZipCode}");

    Console.WriteLine("\nProdukty na fakturze:");
    foreach (var product in invoice.Products)
    {
        Console.WriteLine($"- Produkt: {product.ProductName}, Ilość: {product.Quantity}, Dostawca: {product.Supplier}");
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