# Dokumentowe bazy danych – MongoDB

Ćwiczenie/zadanie


---

**Imiona i nazwiska autorów:** Jakub Zając, Szymon Borusiewicz

--- 

Odtwórz z backupu bazę north0

```
mongorestore --nsInclude='north0.*' ./dump/
```

```
use north0
```


# Zadanie 1 - operacje wyszukiwania danych,  przetwarzanie dokumentów

# a)

stwórz kolekcję  `OrdersInfo`  zawierającą następujące dane o zamówieniach
- pojedynczy dokument opisuje jedno zamówienie

```js
[  
  {  
    "_id": ...
    
    OrderID": ... numer zamówienia
    
    "Customer": {  ... podstawowe informacje o kliencie skladającym  
      "CustomerID": ... identyfikator klienta
      "CompanyName": ... nazwa klienta
      "City": ... miasto 
      "Country": ... kraj 
    },  
    
    "Employee": {  ... podstawowe informacje o pracowniku obsługującym zamówienie
      "EmployeeID": ... idntyfikator pracownika 
      "FirstName": ... imie   
      "LastName": ... nazwisko
      "Title": ... stanowisko  
     
    },  
    
    "Dates": {
       "OrderDate": ... data złożenia zamówienia
       "RequiredDate": data wymaganej realizacji
    }

    "Orderdetails": [  ... pozycje/szczegóły zamówienia - tablica takich pozycji 
      {  
        "UnitPrice": ... cena
        "Quantity": ... liczba sprzedanych jednostek towaru
        "Discount": ... zniżka  
        "Value": ... wartośc pozycji zamówienia
        "product": { ... podstawowe informacje o produkcie 
          "ProductID": ... identyfikator produktu  
          "ProductName": ... nazwa produktu 
          "QuantityPerUnit": ... opis/opakowannie
          "CategoryID": ... identyfikator kategorii do której należy produkt
          "CategoryName" ... nazwę tej kategorii
        },  
      },  
      ...   
    ],  

    "Freight": ... opłata za przesyłkę
    "OrderTotal"  ... sumaryczna wartosc sprzedanych produktów

    "Shipment" : {  ... informacja o wysyłce
        "Shipper": { ... podstawowe inf o przewoźniku 
           "ShipperID":  
            "CompanyName":
        }  
        ... inf o odbiorcy przesyłki
        "ShipName": ...
        "ShipAddress": ...
        "ShipCity": ... 
        "ShipCountry": ...
    } 
  } 
]  
```


# b)

stwórz kolekcję  `CustomerInfo`  zawierającą następujące dane kazdym klencie
- pojedynczy dokument opisuje jednego klienta

```js
[  
  {  
    "_id": ...
    
    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta
    "City": ... miasto 
    "Country": ... kraj 

	"Orders": [ ... tablica zamówień klienta o strukturze takiej jak w punkcie a) (oczywiście bez informacji o kliencie)
	  
	]

		  
]  
```

# c) 

Napisz polecenie/zapytanie: Dla każdego klienta pokaż wartość zakupionych przez niego produktów z kategorii 'Confections'  w 1997r
- Spróbuj napisać to zapytanie wykorzystując
	- oryginalne kolekcje (`customers, orders, orderdertails, products, categories`)
	- kolekcję `OrderInfo`
	- kolekcję `CustomerInfo`

- porównaj zapytania/polecenia/wyniki

```js
[  
  {  
    "_id": 
    
    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta
	"ConfectionsSale97": ... wartość zakupionych przez niego produktów z kategorii 'Confections'  w 1997r

  }		  
]  
```

# d)

Napisz polecenie/zapytanie:  Dla każdego klienta poaje wartość sprzedaży z podziałem na lata i miesiące
Spróbuj napisać to zapytanie wykorzystując
	- oryginalne kolekcje (`customers, orders, orderdertails, products, categories`)
	- kolekcję `OrderInfo`
	- kolekcję `CustomerInfo`

- porównaj zapytania/polecenia/wyniki

```js
[  
  {  
    "_id": 
    
    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta

	"Sale": [ ... tablica zawierająca inf o sprzedazy
	    {
            "Year":  ....
            "Month": ....
            "Total": ...	    
	    }
	    ...
	]
  }		  
]  
```

# e)

Załóżmy że pojawia się nowe zamówienie dla klienta 'ALFKI',  zawierające dwa produkty 'Chai' oraz "Ikura"
- pozostałe pola w zamówieniu (ceny, liczby sztuk prod, inf o przewoźniku itp. możesz uzupełnić wg własnego uznania)
Napisz polecenie które dodaje takie zamówienie do bazy
- aktualizując oryginalne kolekcje `orders`, `orderdetails`
- aktualizując kolekcję `OrderInfo`
- aktualizując kolekcję `CustomerInfo`

Napisz polecenie 
- aktualizując oryginalną kolekcję orderdetails`
- aktualizując kolekcję `OrderInfo`
- aktualizując kolekcję `CustomerInfo`

# f)

Napisz polecenie które modyfikuje zamówienie dodane w pkt e)  zwiększając zniżkę  o 5% (dla każdej pozycji tego zamówienia) 

Napisz polecenie 
- aktualizując oryginalną kolekcję `orderdetails`
- aktualizując kolekcję `OrderInfo`
- aktualizując kolekcję `CustomerInfo`



UWAGA:
W raporcie należy zamieścić kod poleceń oraz uzyskany rezultat, np wynik  polecenia `db.kolekcka.fimd().limit(2)` lub jego fragment


## Zadanie 1  - rozwiązanie

> Wyniki: 
> 
> przykłady, kod, zrzuty ekranów, komentarz ...

a)

```js
db.orders.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "CustomerID",
            foreignField: "CustomerID",
            as: "Customer"
        }
    },
    { $unwind: "$Customer" },

    {
        $lookup: {
            from: "employees",
            localField: "EmployeeID",
            foreignField: "EmployeeID",
            as: "Employee"
        }
    },
    { $unwind: "$Employee"},

    {
        $lookup: {
            from: "orderdetails",
            localField: "OrderID",
            foreignField: "OrderID",
            as: "Orderdetails"
        }
    },
    { $unwind: "$Orderdetails"},

    {
        $lookup: {
            from: "products",
            localField: "Orderdetails.ProductID",
            foreignField: "ProductID",
            as: "Product"
        }
    },
    { $unwind: "$Product"},

    {
        $lookup: {
            from: "categories",
            localField: "Product.CategoryID",
            foreignField: "CategoryID",
            as: "Category"
        }
    },
    { $unwind: "$Category"},

    {
        $addFields: {
            "Orderdetails.Value": {
                $multiply: [
                    "$Orderdetails.UnitPrice",
                    "$Orderdetails.Quantity",
                    { $subtract: [1, "$Orderdetails.Discount"]}
                ]
            },
            "Orderdetails.product": {
                ProductID: "$Product.ProductID",
                ProductName: "$Product.ProductName",
                QuantityPerUnit: "$Product.QuantityPerUnit",
                CategoryID: "$Category.CategoryID",
                CategoryName: "$Category.CategoryName"
            }
        }
    },

    {
        $group: {
            _id: "$OrderID",
            OrderID: { $first: "$OrderID" },
            Customer: {
                $first: {
                    CustomerID: "$Customer.CustomerID",
                    CompanyName: "$Customer.CompanyName",
                    City: "$Customer.City",
                    Country: "$Customer.Country"
                }
            },
            Employee: {
                $first: {
                    EmployeeID: "$Employee.EmployeeID",
                    FirstName: "$Employee.FirstName",
                    LastName: "$Employee.LastName",
                    Title: "$Employee.Title"
                }
            },
            Dates: {
                $first: {
                    OrderDate: "$OrderDate",
                    RequiredDate: "$RequiredDate"
                }
            },
            Orderdetails: { $push: "$Orderdetails" },
            Freight: { $first: "$Freight" },
            OrderTotal: { $sum: "$Orderdetails.Value" },
            ShipName: { $first: "$ShipName" },
            ShipAddress: { $first: "$ShipAddress" },
            ShipCity: { $first: "$ShipCity" },
            ShipCountry: { $first: "$ShipCountry" },
            ShipVia: { $first: "$ShipVia" }
        }
    },

    {
        $lookup: {
            from: "shippers",
            localField: "ShipVia",
            foreignField: "ShipperID",
            as: "Shipper"
        }
    },
    { $unwind: "$Shipper" },

    {
        $addFields: {
            Shipment: {
                Shipper: {
                    ShipperID: "$Shipper.ShipperID",
                    CompanyName: "$Shipper.CompanyName"
                },
                ShipName: "$ShipName",
                ShipAddress: "$ShipAddress",
                ShipCity: "$ShipCity",
                ShipCountry: "$ShipCountry"
            }
        }
    },

    {
        $project: {
            _id: 1,
            OrderID: 1,
            Customer: 1,
            Employee: 1,
            Dates: 1,
            Orderdetails: 1,
            Freight: 1,
            OrderTotal: 1,
            Shipment: 1
        }
    },

    {
        $out: "OrdersInfo"
    }
])
```

```js
[
  {
    "_id": 10417,
    "Customer": {
      "CustomerID": "SIMOB",
      "CompanyName": "Simons bistro",
      "City": "Kobenhavn",
      "Country": "Denmark"
    },
    "Dates": {
      "OrderDate": {"$date": "1997-01-16T00:00:00.000Z"},
      "RequiredDate": {"$date": "1997-02-13T00:00:00.000Z"}
    },
    "Employee": {
      "EmployeeID": 4,
      "FirstName": "Margaret",
      "LastName": "Peacock",
      "Title": "Sales Representative"
    },
    "Freight": 70.29,
    "OrderID": 10417,
    "OrderTotal": 11188.4,
    "Orderdetails": [
      {
        "_id": {"$oid": "63a06016bb3b972d6f4e187d"},
        "OrderID": 10417,
        "ProductID": 38,
        "UnitPrice": 210.8,
        "Quantity": 50,
        "Discount": 0,
        "Value": 10540,
        "product": {
          "ProductID": 38,
          "ProductName": "Côte de Blaye",
          "QuantityPerUnit": "12 - 75 cl bottles",
          "CategoryID": 1,
          "CategoryName": "Beverages"
        }
      },
      {
        "_id": {"$oid": "63a06016bb3b972d6f4e187e"},
        "OrderID": 10417,
        "ProductID": 46,
        "UnitPrice": 9.6,
        "Quantity": 2,
        "Discount": 0.25,
        "Value": 14.399999999999999,
        "product": {
          "ProductID": 46,
          "ProductName": "Spegesild",
          "QuantityPerUnit": "4 - 450 g glasses",
          "CategoryID": 8,
          "CategoryName": "Seafood"
        }
      },
      {
        "_id": {"$oid": "63a06016bb3b972d6f4e187f"},
        "OrderID": 10417,
        "ProductID": 68,
        "UnitPrice": 10,
        "Quantity": 36,
        "Discount": 0.25,
        "Value": 270,
        "product": {
          "ProductID": 68,
          "ProductName": "Scottish Longbreads",
          "QuantityPerUnit": "10 boxes x 8 pieces",
          "CategoryID": 3,
          "CategoryName": "Confections"
        }
      },
      {
        "_id": {"$oid": "63a06016bb3b972d6f4e1880"},
        "OrderID": 10417,
        "ProductID": 77,
        "UnitPrice": 10.4,
        "Quantity": 35,
        "Discount": 0,
        "Value": 364,
        "product": {
          "ProductID": 77,
          "ProductName": "Original Frankfurter grüne Soße",
          "QuantityPerUnit": "12 boxes",
          "CategoryID": 2,
          "CategoryName": "Condiments"
        }
      }
    ],
    "Shipment": {
      "Shipper": {
        "ShipperID": 3,
        "CompanyName": "Federal Shipping"
      },
      "ShipName": "Simons bistro",
      "ShipAddress": "Vinbæltet 34",
      "ShipCity": "Kobenhavn",
      "ShipCountry": "Denmark"
    }
  },
  {
    "_id": 10554,
    "Customer": {
      "CustomerID": "OTTIK",
      "CompanyName": "Ottilies Käseladen",
      "City": "Köln",
      "Country": "Germany"
    },
    "Dates": {
      "OrderDate": {"$date": "1997-05-30T00:00:00.000Z"},
      "RequiredDate": {"$date": "1997-06-27T00:00:00.000Z"}
    },
    "Employee": {
      "EmployeeID": 4,
      "FirstName": "Margaret",
      "LastName": "Peacock",
      "Title": "Sales Representative"
    },
    "Freight": 120.97,
    "OrderID": 10554,
    "OrderTotal": 1728.5249986443669,
    "Orderdetails": [
      {
        "_id": {"$oid": "63a06016bb3b972d6f4e19ef"},
        "OrderID": 10554,
        "ProductID": 16,
        "UnitPrice": 17.45,
        "Quantity": 30,
        "Discount": 0.05000000074505806,
        "Value": 497.3249996099621,
        "product": {
          "ProductID": 16,
          "ProductName": "Pavlova",
          "QuantityPerUnit": "32 - 500 g boxes",
          "CategoryID": 3,
          "CategoryName": "Confections"
        }
      },
      {
        "_id": {"$oid": "63a06016bb3b972d6f4e19f0"},
        "OrderID": 10554,
        "ProductID": 23,
        "UnitPrice": 9,
        "Quantity": 20,
        "Discount": 0.05000000074505806,
        "Value": 170.99999986588955,
        "product": {
          "ProductID": 23,
          "ProductName": "Tunnbröd",
          "QuantityPerUnit": "12 - 250 g pkgs.",
          "CategoryID": 5,
          "CategoryName": "Grains/Cereals"
        }
      },
      {
        "_id": {"$oid": "63a06016bb3b972d6f4e19f1"},
        "OrderID": 10554,
        "ProductID": 62,
        "UnitPrice": 49.3,
        "Quantity": 20,
        "Discount": 0.05000000074505806,
        "Value": 936.6999992653728,
        "product": {
          "ProductID": 62,
          "ProductName": "Tarte au sucre",
          "QuantityPerUnit": "48 pies",
          "CategoryID": 3,
          "CategoryName": "Confections"
        }
      },
      {
        "_id": {"$oid": "63a06016bb3b972d6f4e19f2"},
        "OrderID": 10554,
        "ProductID": 77,
        "UnitPrice": 13,
        "Quantity": 10,
        "Discount": 0.05000000074505806,
        "Value": 123.49999990314245,
        "product": {
          "ProductID": 77,
          "ProductName": "Original Frankfurter grüne Soße",
          "QuantityPerUnit": "12 boxes",
          "CategoryID": 2,
          "CategoryName": "Condiments"
        }
      }
    ],
    "Shipment": {
      "Shipper": {
        "ShipperID": 3,
        "CompanyName": "Federal Shipping"
      },
      "ShipName": "Ottilies Käseladen",
      "ShipAddress": "Mehrheimerstr. 369",
      "ShipCity": "Köln",
      "ShipCountry": "Germany"
    }
  }
]
```

b)


```js
db.OrdersInfo.aggregate([
    {
        $group: {
            _id: "$Customer.CustomerID",
            CustomerID: { $first: "$Customer.CustomerID" },
            CompanyName: { $first: "$Customer.CompanyName" },
            City: { $first: "$Customer.City" },
            Country: { $first: "$Customer.Country" },
            Orders: {
                $push: {
                    OrderID: "$OrderID",
                    Employee: "$Employee",
                    Dates: "$Dates",
                    Orderdetails: "$Orderdetails",
                    Freight: "$Freight",
                    OrderTotal: "$OrderTotal",
                    Shipment: "$Shipment"
                }
            }
        }
    },
    { $out: "CustomerInfo" }
]);
```

```js
[
  {
    "_id": "LILAS",
    "City": "Barquisimeto",
    "CompanyName": "LILA-Supermercado",
    "Country": "Venezuela",
    "CustomerID": "LILAS",
    "Orders": [
      {
        "OrderID": 10543,
        "Employee": {
          "EmployeeID": 8,
          "FirstName": "Laura",
          "LastName": "Callahan",
          "Title": "Inside Sales Coordinator"
        },
        "Dates": {
          "OrderDate": {"$date": "1997-05-21T00:00:00.000Z"},
          "RequiredDate": {"$date": "1997-06-18T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e19d2"},
            "OrderID": 10543,
            "ProductID": 12,
            "UnitPrice": 38,
            "Quantity": 30,
            "Discount": 0.15000000596046448,
            "Value": 968.9999932050705,
            "product": {
              "ProductID": 12,
              "ProductName": "Queso Manchego La Pastora",
              "QuantityPerUnit": "10 - 500 g pkgs.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e19d3"},
            "OrderID": 10543,
            "ProductID": 23,
            "UnitPrice": 9,
            "Quantity": 70,
            "Discount": 0.15000000596046448,
            "Value": 535.4999962449074,
            "product": {
              "ProductID": 23,
              "ProductName": "Tunnbröd",
              "QuantityPerUnit": "12 - 250 g pkgs.",
              "CategoryID": 5,
              "CategoryName": "Grains/Cereals"
            }
          }
        ],
        "Freight": 48.17,
        "OrderTotal": 1504.4999894499779,
        "Shipment": {
          "Shipper": {
            "ShipperID": 2,
            "CompanyName": "United Package"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10899,
        "Employee": {
          "EmployeeID": 5,
          "FirstName": "Steven",
          "LastName": "Buchanan",
          "Title": "Sales Manager"
        },
        "Dates": {
          "OrderDate": {"$date": "1998-02-20T00:00:00.000Z"},
          "RequiredDate": {"$date": "1998-03-20T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1d61"},
            "OrderID": 10899,
            "ProductID": 39,
            "UnitPrice": 18,
            "Quantity": 8,
            "Discount": 0.15000000596046448,
            "Value": 122.39999914169312,
            "product": {
              "ProductID": 39,
              "ProductName": "Chartreuse verte",
              "QuantityPerUnit": "750 cc per bottle",
              "CategoryID": 1,
              "CategoryName": "Beverages"
            }
          }
        ],
        "Freight": 1.21,
        "OrderTotal": 122.39999914169312,
        "Shipment": {
          "Shipper": {
            "ShipperID": 3,
            "CompanyName": "Federal Shipping"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10499,
        "Employee": {
          "EmployeeID": 4,
          "FirstName": "Margaret",
          "LastName": "Peacock",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1997-04-08T00:00:00.000Z"},
          "RequiredDate": {"$date": "1997-05-06T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1952"},
            "OrderID": 10499,
            "ProductID": 28,
            "UnitPrice": 45.6,
            "Quantity": 20,
            "Discount": 0,
            "Value": 912,
            "product": {
              "ProductID": 28,
              "ProductName": "Rössle Sauerkraut",
              "QuantityPerUnit": "25 - 825 g cans",
              "CategoryID": 7,
              "CategoryName": "Produce"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1953"},
            "OrderID": 10499,
            "ProductID": 49,
            "UnitPrice": 20,
            "Quantity": 25,
            "Discount": 0,
            "Value": 500,
            "product": {
              "ProductID": 49,
              "ProductName": "Maxilaku",
              "QuantityPerUnit": "24 - 50 g pkgs.",
              "CategoryID": 3,
              "CategoryName": "Confections"
            }
          }
        ],
        "Freight": 102.02,
        "OrderTotal": 1412,
        "Shipment": {
          "Shipper": {
            "ShipperID": 2,
            "CompanyName": "United Package"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10997,
        "Employee": {
          "EmployeeID": 8,
          "FirstName": "Laura",
          "LastName": "Callahan",
          "Title": "Inside Sales Coordinator"
        },
        "Dates": {
          "OrderDate": {"$date": "1998-04-03T00:00:00.000Z"},
          "RequiredDate": {"$date": "1998-05-15T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1e46"},
            "OrderID": 10997,
            "ProductID": 32,
            "UnitPrice": 32,
            "Quantity": 50,
            "Discount": 0,
            "Value": 1600,
            "product": {
              "ProductID": 32,
              "ProductName": "Mascarpone Fabioli",
              "QuantityPerUnit": "24 - 200 g pkgs.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1e47"},
            "OrderID": 10997,
            "ProductID": 46,
            "UnitPrice": 12,
            "Quantity": 20,
            "Discount": 0.25,
            "Value": 180,
            "product": {
              "ProductID": 46,
              "ProductName": "Spegesild",
              "QuantityPerUnit": "4 - 450 g glasses",
              "CategoryID": 8,
              "CategoryName": "Seafood"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1e48"},
            "OrderID": 10997,
            "ProductID": 52,
            "UnitPrice": 7,
            "Quantity": 20,
            "Discount": 0.25,
            "Value": 105,
            "product": {
              "ProductID": 52,
              "ProductName": "Filo Mix",
              "QuantityPerUnit": "16 - 2 kg boxes",
              "CategoryID": 5,
              "CategoryName": "Grains/Cereals"
            }
          }
        ],
        "Freight": 73.91,
        "OrderTotal": 1885,
        "Shipment": {
          "Shipper": {
            "ShipperID": 2,
            "CompanyName": "United Package"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10283,
        "Employee": {
          "EmployeeID": 3,
          "FirstName": "Janet",
          "LastName": "Leverling",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1996-08-16T00:00:00.000Z"},
          "RequiredDate": {"$date": "1996-09-13T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1717"},
            "OrderID": 10283,
            "ProductID": 15,
            "UnitPrice": 12.4,
            "Quantity": 20,
            "Discount": 0,
            "Value": 248,
            "product": {
              "ProductID": 15,
              "ProductName": "Genen Shouyu",
              "QuantityPerUnit": "24 - 250 ml bottles",
              "CategoryID": 2,
              "CategoryName": "Condiments"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1718"},
            "OrderID": 10283,
            "ProductID": 19,
            "UnitPrice": 7.3,
            "Quantity": 18,
            "Discount": 0,
            "Value": 131.4,
            "product": {
              "ProductID": 19,
              "ProductName": "Teatime Chocolate Biscuits",
              "QuantityPerUnit": "10 boxes x 12 pieces",
              "CategoryID": 3,
              "CategoryName": "Confections"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1719"},
            "OrderID": 10283,
            "ProductID": 60,
            "UnitPrice": 27.2,
            "Quantity": 35,
            "Discount": 0,
            "Value": 952,
            "product": {
              "ProductID": 60,
              "ProductName": "Camembert Pierrot",
              "QuantityPerUnit": "15 - 300 g rounds",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e171a"},
            "OrderID": 10283,
            "ProductID": 72,
            "UnitPrice": 27.8,
            "Quantity": 3,
            "Discount": 0,
            "Value": 83.4,
            "product": {
              "ProductID": 72,
              "ProductName": "Mozzarella di Giovanni",
              "QuantityPerUnit": "24 - 200 g pkgs.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          }
        ],
        "Freight": 84.81,
        "OrderTotal": 1414.8,
        "Shipment": {
          "Shipper": {
            "ShipperID": 3,
            "CompanyName": "Federal Shipping"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10461,
        "Employee": {
          "EmployeeID": 1,
          "FirstName": "Nancy",
          "LastName": "Davolio",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1997-02-28T00:00:00.000Z"},
          "RequiredDate": {"$date": "1997-03-28T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e18f2"},
            "OrderID": 10461,
            "ProductID": 21,
            "UnitPrice": 8,
            "Quantity": 40,
            "Discount": 0.25,
            "Value": 240,
            "product": {
              "ProductID": 21,
              "ProductName": "Sir Rodney's Scones",
              "QuantityPerUnit": "24 pkgs. x 4 pieces",
              "CategoryID": 3,
              "CategoryName": "Confections"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e18f3"},
            "OrderID": 10461,
            "ProductID": 30,
            "UnitPrice": 20.7,
            "Quantity": 28,
            "Discount": 0.25,
            "Value": 434.70000000000005,
            "product": {
              "ProductID": 30,
              "ProductName": "Nord-Ost Matjeshering",
              "QuantityPerUnit": "10 - 200 g glasses",
              "CategoryID": 8,
              "CategoryName": "Seafood"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e18f4"},
            "OrderID": 10461,
            "ProductID": 55,
            "UnitPrice": 19.2,
            "Quantity": 60,
            "Discount": 0.25,
            "Value": 864,
            "product": {
              "ProductID": 55,
              "ProductName": "Pâté chinois",
              "QuantityPerUnit": "24 boxes x 2 pies",
              "CategoryID": 6,
              "CategoryName": "Meat/Poultry"
            }
          }
        ],
        "Freight": 148.61,
        "OrderTotal": 1538.7,
        "Shipment": {
          "Shipper": {
            "ShipperID": 3,
            "CompanyName": "Federal Shipping"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10330,
        "Employee": {
          "EmployeeID": 3,
          "FirstName": "Janet",
          "LastName": "Leverling",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1996-10-16T00:00:00.000Z"},
          "RequiredDate": {"$date": "1996-11-13T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1798"},
            "OrderID": 10330,
            "ProductID": 26,
            "UnitPrice": 24.9,
            "Quantity": 50,
            "Discount": 0.15000000596046448,
            "Value": 1058.2499925792217,
            "product": {
              "ProductID": 26,
              "ProductName": "Gumbär Gummibärchen",
              "QuantityPerUnit": "100 - 250 g bags",
              "CategoryID": 3,
              "CategoryName": "Confections"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1799"},
            "OrderID": 10330,
            "ProductID": 72,
            "UnitPrice": 27.8,
            "Quantity": 25,
            "Discount": 0.15000000596046448,
            "Value": 590.7499958574772,
            "product": {
              "ProductID": 72,
              "ProductName": "Mozzarella di Giovanni",
              "QuantityPerUnit": "24 - 200 g pkgs.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          }
        ],
        "Freight": 12.75,
        "OrderTotal": 1648.999988436699,
        "Shipment": {
          "Shipper": {
            "ShipperID": 1,
            "CompanyName": "Speedy Express"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10381,
        "Employee": {
          "EmployeeID": 3,
          "FirstName": "Janet",
          "LastName": "Leverling",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1996-12-12T00:00:00.000Z"},
          "RequiredDate": {"$date": "1997-01-09T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e181b"},
            "OrderID": 10381,
            "ProductID": 74,
            "UnitPrice": 8,
            "Quantity": 14,
            "Discount": 0,
            "Value": 112,
            "product": {
              "ProductID": 74,
              "ProductName": "Longlife Tofu",
              "QuantityPerUnit": "5 kg pkg.",
              "CategoryID": 7,
              "CategoryName": "Produce"
            }
          }
        ],
        "Freight": 7.99,
        "OrderTotal": 112,
        "Shipment": {
          "Shipper": {
            "ShipperID": 3,
            "CompanyName": "Federal Shipping"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10296,
        "Employee": {
          "EmployeeID": 6,
          "FirstName": "Michael",
          "LastName": "Suyama",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1996-09-03T00:00:00.000Z"},
          "RequiredDate": {"$date": "1996-10-01T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e173d"},
            "OrderID": 10296,
            "ProductID": 11,
            "UnitPrice": 16.8,
            "Quantity": 12,
            "Discount": 0,
            "Value": 201.60000000000002,
            "product": {
              "ProductID": 11,
              "ProductName": "Queso Cabrales",
              "QuantityPerUnit": "1 kg pkg.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e173e"},
            "OrderID": 10296,
            "ProductID": 16,
            "UnitPrice": 13.9,
            "Quantity": 30,
            "Discount": 0,
            "Value": 417,
            "product": {
              "ProductID": 16,
              "ProductName": "Pavlova",
              "QuantityPerUnit": "32 - 500 g boxes",
              "CategoryID": 3,
              "CategoryName": "Confections"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e173f"},
            "OrderID": 10296,
            "ProductID": 69,
            "UnitPrice": 28.8,
            "Quantity": 15,
            "Discount": 0,
            "Value": 432,
            "product": {
              "ProductID": 69,
              "ProductName": "Gudbrandsdalsost",
              "QuantityPerUnit": "10 kg pkg.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          }
        ],
        "Freight": 0.12,
        "OrderTotal": 1050.6,
        "Shipment": {
          "Shipper": {
            "ShipperID": 1,
            "CompanyName": "Speedy Express"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10780,
        "Employee": {
          "EmployeeID": 2,
          "FirstName": "Andrew",
          "LastName": "Fuller",
          "Title": "Vice President, Sales"
        },
        "Dates": {
          "OrderDate": {"$date": "1997-12-16T00:00:00.000Z"},
          "RequiredDate": {"$date": "1997-12-30T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1c30"},
            "OrderID": 10780,
            "ProductID": 70,
            "UnitPrice": 15,
            "Quantity": 35,
            "Discount": 0,
            "Value": 525,
            "product": {
              "ProductID": 70,
              "ProductName": "Outback Lager",
              "QuantityPerUnit": "24 - 355 ml bottles",
              "CategoryID": 1,
              "CategoryName": "Beverages"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1c31"},
            "OrderID": 10780,
            "ProductID": 77,
            "UnitPrice": 13,
            "Quantity": 15,
            "Discount": 0,
            "Value": 195,
            "product": {
              "ProductID": 77,
              "ProductName": "Original Frankfurter grüne Soße",
              "QuantityPerUnit": "12 boxes",
              "CategoryID": 2,
              "CategoryName": "Condiments"
            }
          }
        ],
        "Freight": 42.13,
        "OrderTotal": 720,
        "Shipment": {
          "Shipper": {
            "ShipperID": 1,
            "CompanyName": "Speedy Express"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10357,
        "Employee": {
          "EmployeeID": 1,
          "FirstName": "Nancy",
          "LastName": "Davolio",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1996-11-19T00:00:00.000Z"},
          "RequiredDate": {"$date": "1996-12-17T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e17dd"},
            "OrderID": 10357,
            "ProductID": 10,
            "UnitPrice": 24.8,
            "Quantity": 30,
            "Discount": 0.20000000298023224,
            "Value": 595.1999977827072,
            "product": {
              "ProductID": 10,
              "ProductName": "Ikura",
              "QuantityPerUnit": "12 - 200 ml jars",
              "CategoryID": 8,
              "CategoryName": "Seafood"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e17de"},
            "OrderID": 10357,
            "ProductID": 26,
            "UnitPrice": 24.9,
            "Quantity": 16,
            "Discount": 0,
            "Value": 398.4,
            "product": {
              "ProductID": 26,
              "ProductName": "Gumbär Gummibärchen",
              "QuantityPerUnit": "100 - 250 g bags",
              "CategoryID": 3,
              "CategoryName": "Confections"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e17df"},
            "OrderID": 10357,
            "ProductID": 60,
            "UnitPrice": 27.2,
            "Quantity": 8,
            "Discount": 0.20000000298023224,
            "Value": 174.07999935150147,
            "product": {
              "ProductID": 60,
              "ProductName": "Camembert Pierrot",
              "QuantityPerUnit": "15 - 300 g rounds",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          }
        ],
        "Freight": 34.88,
        "OrderTotal": 1167.6799971342086,
        "Shipment": {
          "Shipper": {
            "ShipperID": 3,
            "CompanyName": "Federal Shipping"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 11071,
        "Employee": {
          "EmployeeID": 1,
          "FirstName": "Nancy",
          "LastName": "Davolio",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1998-05-05T00:00:00.000Z"},
          "RequiredDate": {"$date": "1998-06-02T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1eff"},
            "OrderID": 11071,
            "ProductID": 7,
            "UnitPrice": 30,
            "Quantity": 15,
            "Discount": 0.05000000074505806,
            "Value": 427.4999996647239,
            "product": {
              "ProductID": 7,
              "ProductName": "Uncle Bob's Organic Dried Pears",
              "QuantityPerUnit": "12 - 1 lb pkgs.",
              "CategoryID": 7,
              "CategoryName": "Produce"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1f00"},
            "OrderID": 11071,
            "ProductID": 13,
            "UnitPrice": 6,
            "Quantity": 10,
            "Discount": 0.05000000074505806,
            "Value": 56.999999955296516,
            "product": {
              "ProductID": 13,
              "ProductName": "Konbu",
              "QuantityPerUnit": "2 kg box",
              "CategoryID": 8,
              "CategoryName": "Seafood"
            }
          }
        ],
        "Freight": 0.93,
        "OrderTotal": 484.4999996200204,
        "Shipment": {
          "Shipper": {
            "ShipperID": 1,
            "CompanyName": "Speedy Express"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 10823,
        "Employee": {
          "EmployeeID": 5,
          "FirstName": "Steven",
          "LastName": "Buchanan",
          "Title": "Sales Manager"
        },
        "Dates": {
          "OrderDate": {"$date": "1998-01-09T00:00:00.000Z"},
          "RequiredDate": {"$date": "1998-02-06T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1c96"},
            "OrderID": 10823,
            "ProductID": 11,
            "UnitPrice": 21,
            "Quantity": 20,
            "Discount": 0.10000000149011612,
            "Value": 377.99999937415123,
            "product": {
              "ProductID": 11,
              "ProductName": "Queso Cabrales",
              "QuantityPerUnit": "1 kg pkg.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1c97"},
            "OrderID": 10823,
            "ProductID": 57,
            "UnitPrice": 19.5,
            "Quantity": 15,
            "Discount": 0,
            "Value": 292.5,
            "product": {
              "ProductID": 57,
              "ProductName": "Ravioli Angelo",
              "QuantityPerUnit": "24 - 250 g pkgs.",
              "CategoryID": 5,
              "CategoryName": "Grains/Cereals"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1c98"},
            "OrderID": 10823,
            "ProductID": 59,
            "UnitPrice": 55,
            "Quantity": 40,
            "Discount": 0.10000000149011612,
            "Value": 1979.9999967217445,
            "product": {
              "ProductID": 59,
              "ProductName": "Raclette Courdavault",
              "QuantityPerUnit": "5 kg pkg.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1c99"},
            "OrderID": 10823,
            "ProductID": 77,
            "UnitPrice": 13,
            "Quantity": 15,
            "Discount": 0.10000000149011612,
            "Value": 175.49999970942736,
            "product": {
              "ProductID": 77,
              "ProductName": "Original Frankfurter grüne Soße",
              "QuantityPerUnit": "12 boxes",
              "CategoryID": 2,
              "CategoryName": "Condiments"
            }
          }
        ],
        "Freight": 163.97,
        "OrderTotal": 2825.999995805323,
        "Shipment": {
          "Shipper": {
            "ShipperID": 2,
            "CompanyName": "United Package"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      },
      {
        "OrderID": 11065,
        "Employee": {
          "EmployeeID": 8,
          "FirstName": "Laura",
          "LastName": "Callahan",
          "Title": "Inside Sales Coordinator"
        },
        "Dates": {
          "OrderDate": {"$date": "1998-05-01T00:00:00.000Z"},
          "RequiredDate": {"$date": "1998-05-29T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1ef1"},
            "OrderID": 11065,
            "ProductID": 30,
            "UnitPrice": 25.89,
            "Quantity": 4,
            "Discount": 0.25,
            "Value": 77.67,
            "product": {
              "ProductID": 30,
              "ProductName": "Nord-Ost Matjeshering",
              "QuantityPerUnit": "10 - 200 g glasses",
              "CategoryID": 8,
              "CategoryName": "Seafood"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1ef2"},
            "OrderID": 11065,
            "ProductID": 54,
            "UnitPrice": 7.45,
            "Quantity": 20,
            "Discount": 0.25,
            "Value": 111.75,
            "product": {
              "ProductID": 54,
              "ProductName": "Tourtière",
              "QuantityPerUnit": "16 pies",
              "CategoryID": 6,
              "CategoryName": "Meat/Poultry"
            }
          }
        ],
        "Freight": 12.91,
        "OrderTotal": 189.42000000000002,
        "Shipment": {
          "Shipper": {
            "ShipperID": 1,
            "CompanyName": "Speedy Express"
          },
          "ShipName": "LILA-Supermercado",
          "ShipAddress": "Carrera 52 con Ave. Bolívar #65-98 Llano Largo",
          "ShipCity": "Barquisimeto",
          "ShipCountry": "Venezuela"
        }
      }
    ]
  },
  {
    "_id": "VINET",
    "City": "Reims",
    "CompanyName": "Vins et alcools Chevalier",
    "Country": "France",
    "CustomerID": "VINET",
    "Orders": [
      {
        "OrderID": 10737,
        "Employee": {
          "EmployeeID": 2,
          "FirstName": "Andrew",
          "LastName": "Fuller",
          "Title": "Vice President, Sales"
        },
        "Dates": {
          "OrderDate": {"$date": "1997-11-11T00:00:00.000Z"},
          "RequiredDate": {"$date": "1997-12-09T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1bc5"},
            "OrderID": 10737,
            "ProductID": 13,
            "UnitPrice": 6,
            "Quantity": 4,
            "Discount": 0,
            "Value": 24,
            "product": {
              "ProductID": 13,
              "ProductName": "Konbu",
              "QuantityPerUnit": "2 kg box",
              "CategoryID": 8,
              "CategoryName": "Seafood"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1bc6"},
            "OrderID": 10737,
            "ProductID": 41,
            "UnitPrice": 9.65,
            "Quantity": 12,
            "Discount": 0,
            "Value": 115.80000000000001,
            "product": {
              "ProductID": 41,
              "ProductName": "Jack's New England Clam Chowder",
              "QuantityPerUnit": "12 - 12 oz cans",
              "CategoryID": 8,
              "CategoryName": "Seafood"
            }
          }
        ],
        "Freight": 7.79,
        "OrderTotal": 139.8,
        "Shipment": {
          "Shipper": {
            "ShipperID": 2,
            "CompanyName": "United Package"
          },
          "ShipName": "Vins et alcools Chevalier",
          "ShipAddress": "59 rue de l'Abbaye",
          "ShipCity": "Reims",
          "ShipCountry": "France"
        }
      },
      {
        "OrderID": 10295,
        "Employee": {
          "EmployeeID": 2,
          "FirstName": "Andrew",
          "LastName": "Fuller",
          "Title": "Vice President, Sales"
        },
        "Dates": {
          "OrderDate": {"$date": "1996-09-02T00:00:00.000Z"},
          "RequiredDate": {"$date": "1996-09-30T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e173c"},
            "OrderID": 10295,
            "ProductID": 56,
            "UnitPrice": 30.4,
            "Quantity": 4,
            "Discount": 0,
            "Value": 121.6,
            "product": {
              "ProductID": 56,
              "ProductName": "Gnocchi di nonna Alice",
              "QuantityPerUnit": "24 - 250 g pkgs.",
              "CategoryID": 5,
              "CategoryName": "Grains/Cereals"
            }
          }
        ],
        "Freight": 1.15,
        "OrderTotal": 121.6,
        "Shipment": {
          "Shipper": {
            "ShipperID": 2,
            "CompanyName": "United Package"
          },
          "ShipName": "Vins et alcools Chevalier",
          "ShipAddress": "59 rue de l'Abbaye",
          "ShipCity": "Reims",
          "ShipCountry": "France"
        }
      },
      {
        "OrderID": 10739,
        "Employee": {
          "EmployeeID": 3,
          "FirstName": "Janet",
          "LastName": "Leverling",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1997-11-12T00:00:00.000Z"},
          "RequiredDate": {"$date": "1997-12-10T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1bc8"},
            "OrderID": 10739,
            "ProductID": 36,
            "UnitPrice": 19,
            "Quantity": 6,
            "Discount": 0,
            "Value": 114,
            "product": {
              "ProductID": 36,
              "ProductName": "Inlagd Sill",
              "QuantityPerUnit": "24 - 250 g  jars",
              "CategoryID": 8,
              "CategoryName": "Seafood"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1bc9"},
            "OrderID": 10739,
            "ProductID": 52,
            "UnitPrice": 7,
            "Quantity": 18,
            "Discount": 0,
            "Value": 126,
            "product": {
              "ProductID": 52,
              "ProductName": "Filo Mix",
              "QuantityPerUnit": "16 - 2 kg boxes",
              "CategoryID": 5,
              "CategoryName": "Grains/Cereals"
            }
          }
        ],
        "Freight": 11.08,
        "OrderTotal": 240,
        "Shipment": {
          "Shipper": {
            "ShipperID": 3,
            "CompanyName": "Federal Shipping"
          },
          "ShipName": "Vins et alcools Chevalier",
          "ShipAddress": "59 rue de l'Abbaye",
          "ShipCity": "Reims",
          "ShipCountry": "France"
        }
      },
      {
        "OrderID": 10274,
        "Employee": {
          "EmployeeID": 6,
          "FirstName": "Michael",
          "LastName": "Suyama",
          "Title": "Sales Representative"
        },
        "Dates": {
          "OrderDate": {"$date": "1996-08-06T00:00:00.000Z"},
          "RequiredDate": {"$date": "1996-09-03T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1702"},
            "OrderID": 10274,
            "ProductID": 71,
            "UnitPrice": 17.2,
            "Quantity": 20,
            "Discount": 0,
            "Value": 344,
            "product": {
              "ProductID": 71,
              "ProductName": "Flotemysost",
              "QuantityPerUnit": "10 - 500 g pkgs.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e1703"},
            "OrderID": 10274,
            "ProductID": 72,
            "UnitPrice": 27.8,
            "Quantity": 7,
            "Discount": 0,
            "Value": 194.6,
            "product": {
              "ProductID": 72,
              "ProductName": "Mozzarella di Giovanni",
              "QuantityPerUnit": "24 - 200 g pkgs.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          }
        ],
        "Freight": 6.01,
        "OrderTotal": 538.6,
        "Shipment": {
          "Shipper": {
            "ShipperID": 1,
            "CompanyName": "Speedy Express"
          },
          "ShipName": "Vins et alcools Chevalier",
          "ShipAddress": "59 rue de l'Abbaye",
          "ShipCity": "Reims",
          "ShipCountry": "France"
        }
      },
      {
        "OrderID": 10248,
        "Employee": {
          "EmployeeID": 5,
          "FirstName": "Steven",
          "LastName": "Buchanan",
          "Title": "Sales Manager"
        },
        "Dates": {
          "OrderDate": {"$date": "1996-07-04T00:00:00.000Z"},
          "RequiredDate": {"$date": "1996-08-01T00:00:00.000Z"}
        },
        "Orderdetails": [
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e16bc"},
            "OrderID": 10248,
            "ProductID": 11,
            "UnitPrice": 14,
            "Quantity": 12,
            "Discount": 0,
            "Value": 168,
            "product": {
              "ProductID": 11,
              "ProductName": "Queso Cabrales",
              "QuantityPerUnit": "1 kg pkg.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e16bd"},
            "OrderID": 10248,
            "ProductID": 42,
            "UnitPrice": 9.8,
            "Quantity": 10,
            "Discount": 0,
            "Value": 98,
            "product": {
              "ProductID": 42,
              "ProductName": "Singaporean Hokkien Fried Mee",
              "QuantityPerUnit": "32 - 1 kg pkgs.",
              "CategoryID": 5,
              "CategoryName": "Grains/Cereals"
            }
          },
          {
            "_id": {"$oid": "63a06016bb3b972d6f4e16be"},
            "OrderID": 10248,
            "ProductID": 72,
            "UnitPrice": 34.8,
            "Quantity": 5,
            "Discount": 0,
            "Value": 174,
            "product": {
              "ProductID": 72,
              "ProductName": "Mozzarella di Giovanni",
              "QuantityPerUnit": "24 - 200 g pkgs.",
              "CategoryID": 4,
              "CategoryName": "Dairy Products"
            }
          }
        ],
        "Freight": 32.38,
        "OrderTotal": 440,
        "Shipment": {
          "Shipper": {
            "ShipperID": 3,
            "CompanyName": "Federal Shipping"
          },
          "ShipName": "Vins et alcools Chevalier",
          "ShipAddress": "59 rue de l'Abbaye",
          "ShipCity": "Reims",
          "ShipCountry": "France"
        }
      }
    ]
  }
]
```

c)
Zapytanie wykorzystujące oryginalne kolekcje (customers, orders, orderdertails, products, categories):
```js
db.orders.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "CustomerID",
            foreignField: "CustomerID",
            as: "Customer"
        }
    },
    { $unwind: "$Customer" },

    {
        $lookup: {
            from: "orderdetails",
            localField: "OrderID",
            foreignField: "OrderID",
            as: "Details"
        }
    },
    { $unwind: "$Details" },

    {
        $lookup: {
            from: "products",
            localField: "Details.ProductID",
            foreignField: "ProductID",
            as: "Product"
        }
    },
    { $unwind: "$Product" },

    {
        $lookup: {
            from: "categories",
            localField: "Product.CategoryID",
            foreignField: "CategoryID",
            as: "Category"
        }
    },
    { $unwind: "$Category" },

    {
        $match: {
            "Category.CategoryName": "Confections",
            OrderDate: {
                $gte: ISODate("1997-01-01"),
                $lt: ISODate("1998-01-01")
            }
        }
    },

    {
        $group: {
            _id: "$Customer.CustomerID",
            CustomerID: { $first: "$Customer.CustomerID" },
            CompanyName: { $first: "$Customer.CompanyName" },
            ConfectionsSale97: {
                $sum: {
                    $multiply: [
                        "$Details.UnitPrice",
                        "$Details.Quantity",
                        { $subtract: [1, "$Details.Discount"] }
                    ]
                }
            }
        }
    }
])
```

```js
[
  {
    "_id": "MEREP",
    "CompanyName": "Mère Paillarde",
    "ConfectionsSale97": 1715.1249987158924,
    "CustomerID": "MEREP"
  },
  {
    "_id": "EASTC",
    "CompanyName": "Eastern Connection",
    "ConfectionsSale97": 480,
    "CustomerID": "EASTC"
  },
  {
    "_id": "WILMK",
    "CompanyName": "Wilman Kala",
    "ConfectionsSale97": 52.349999999999994,
    "CustomerID": "WILMK"
  },
  {
    "_id": "FRANK",
    "CompanyName": "Frankenversand",
    "ConfectionsSale97": 1678.9749984033406,
    "CustomerID": "FRANK"
  },
  {
    "_id": "VAFFE",
    "CompanyName": "Vaffeljernet",
    "ConfectionsSale97": 1064.5,
    "CustomerID": "VAFFE"
  },
  {
    "_id": "REGGC",
    "CompanyName": "Reggiani Caseifici",
    "ConfectionsSale97": 443.69999926537275,
    "CustomerID": "REGGC"
  },
  {
    "_id": "AROUT",
    "CompanyName": "Around the Horn",
    "ConfectionsSale97": 375.19999977201223,
    "CustomerID": "AROUT"
  },
  {
    "_id": "RANCH",
    "CompanyName": "Rancho grande",
    "ConfectionsSale97": 199.39999999999998,
    "CustomerID": "RANCH"
  },
  {
    "_id": "RICSU",
    "CompanyName": "Richter Supermarkt",
    "ConfectionsSale97": 1254.3839989572764,
    "CustomerID": "RICSU"
  },
  {
    "_id": "TOMSP",
    "CompanyName": "Toms Spezialitäten",
    "ConfectionsSale97": 166.4399995431304,
    "CustomerID": "TOMSP"
  },
  {
    "_id": "GREAL",
    "CompanyName": "Great Lakes Food Market",
    "ConfectionsSale97": 407.6999993249774,
    "CustomerID": "GREAL"
  },
  {
    "_id": "KOENE",
    "CompanyName": "Königlich Essen",
    "ConfectionsSale97": 2119.399995714426,
    "CustomerID": "KOENE"
  },
  {
    "_id": "CACTU",
    "CompanyName": "Cactus Comidas para llevar",
    "ConfectionsSale97": 75,
    "CustomerID": "CACTU"
  },
  {
    "_id": "SPLIR",
    "CompanyName": "Split Rail Beer & Ale",
    "ConfectionsSale97": 308.9999997764826,
    "CustomerID": "SPLIR"
  },
  {
    "_id": "BSBEV",
    "CompanyName": "B's Beverages",
    "ConfectionsSale97": 875,
    "CustomerID": "BSBEV"
  },
  {
    "_id": "HUNGO",
    "CompanyName": "Hungry Owl All-Night Grocers",
    "ConfectionsSale97": 520,
    "CustomerID": "HUNGO"
  },
  {
    "_id": "SIMOB",
    "CompanyName": "Simons bistro",
    "ConfectionsSale97": 694.8749991059303,
    "CustomerID": "SIMOB"
  },
  {
    "_id": "LILAS",
    "CompanyName": "LILA-Supermercado",
    "ConfectionsSale97": 740,
    "CustomerID": "LILAS"
  },
  {
    "_id": "RICAR",
    "CompanyName": "Ricardo Adocicados",
    "ConfectionsSale97": 855.9999993294477,
    "CustomerID": "RICAR"
  },
  {
    "_id": "CHOPS",
    "CompanyName": "Chop-suey Chinese",
    "ConfectionsSale97": 823.6999997019768,
    "CustomerID": "CHOPS"
  }
]
```

Zapytanie wykorzystujące kolekcję OrderInfo:

```js
db.OrdersInfo.aggregate([
    {
        $match: {
            "Dates.OrderDate": {
                $gte: ISODate("1997-01-01"),
                $lt: ISODate("1998-01-01")
            }
        }
    },

    { $unwind: "$Orderdetails" },

    {
        $match: {
            "Orderdetails.product.CategoryName": "Confections"
        }
    },

    {
        $group: {
            _id: "$Customer.CustomerID",
            CustomerID: { $first: "$Customer.CustomerID" },
            CompanyName: { $first: "$Customer.CompanyName" },
            ConfectionsSale97: {
                $sum: "$Orderdetails.Value"
            }
        }
    }
])
```

```js
[
  {
    "_id": "MEREP",
    "CompanyName": "Mère Paillarde",
    "ConfectionsSale97": 1715.1249987158924,
    "CustomerID": "MEREP"
  },
  {
    "_id": "EASTC",
    "CompanyName": "Eastern Connection",
    "ConfectionsSale97": 480,
    "CustomerID": "EASTC"
  },
  {
    "_id": "WILMK",
    "CompanyName": "Wilman Kala",
    "ConfectionsSale97": 52.349999999999994,
    "CustomerID": "WILMK"
  },
  {
    "_id": "FRANK",
    "CompanyName": "Frankenversand",
    "ConfectionsSale97": 1678.9749984033406,
    "CustomerID": "FRANK"
  },
  {
    "_id": "VAFFE",
    "CompanyName": "Vaffeljernet",
    "ConfectionsSale97": 1064.5,
    "CustomerID": "VAFFE"
  },
  {
    "_id": "REGGC",
    "CompanyName": "Reggiani Caseifici",
    "ConfectionsSale97": 443.69999926537275,
    "CustomerID": "REGGC"
  },
  {
    "_id": "AROUT",
    "CompanyName": "Around the Horn",
    "ConfectionsSale97": 375.19999977201223,
    "CustomerID": "AROUT"
  },
  {
    "_id": "RANCH",
    "CompanyName": "Rancho grande",
    "ConfectionsSale97": 199.39999999999998,
    "CustomerID": "RANCH"
  },
  {
    "_id": "RICSU",
    "CompanyName": "Richter Supermarkt",
    "ConfectionsSale97": 1254.3839989572764,
    "CustomerID": "RICSU"
  },
  {
    "_id": "TOMSP",
    "CompanyName": "Toms Spezialitäten",
    "ConfectionsSale97": 166.4399995431304,
    "CustomerID": "TOMSP"
  },
  {
    "_id": "GREAL",
    "CompanyName": "Great Lakes Food Market",
    "ConfectionsSale97": 407.6999993249774,
    "CustomerID": "GREAL"
  },
  {
    "_id": "KOENE",
    "CompanyName": "Königlich Essen",
    "ConfectionsSale97": 2119.399995714426,
    "CustomerID": "KOENE"
  },
  {
    "_id": "CACTU",
    "CompanyName": "Cactus Comidas para llevar",
    "ConfectionsSale97": 75,
    "CustomerID": "CACTU"
  },
  {
    "_id": "SPLIR",
    "CompanyName": "Split Rail Beer & Ale",
    "ConfectionsSale97": 308.9999997764826,
    "CustomerID": "SPLIR"
  },
  {
    "_id": "BSBEV",
    "CompanyName": "B's Beverages",
    "ConfectionsSale97": 875,
    "CustomerID": "BSBEV"
  },
  {
    "_id": "HUNGO",
    "CompanyName": "Hungry Owl All-Night Grocers",
    "ConfectionsSale97": 520,
    "CustomerID": "HUNGO"
  },
  {
    "_id": "SIMOB",
    "CompanyName": "Simons bistro",
    "ConfectionsSale97": 694.8749991059303,
    "CustomerID": "SIMOB"
  },
  {
    "_id": "CHOPS",
    "CompanyName": "Chop-suey Chinese",
    "ConfectionsSale97": 823.6999997019768,
    "CustomerID": "CHOPS"
  },
  {
    "_id": "RICAR",
    "CompanyName": "Ricardo Adocicados",
    "ConfectionsSale97": 855.9999993294477,
    "CustomerID": "RICAR"
  },
  {
    "_id": "LILAS",
    "CompanyName": "LILA-Supermercado",
    "ConfectionsSale97": 740,
    "CustomerID": "LILAS"
  }
]
```

Zapytanie wykorzystujące kolekcję CustomerInfo:

```js
db.CustomerInfo.aggregate([
    { $unwind: "$Orders" },

    {
        $match: {
            "Orders.Dates.OrderDate": {
                $gte: ISODate("1997-01-01"),
                $lt: ISODate("1998-01-01")
            }
        }
    },

    { $unwind: "$Orders.Orderdetails" },

    {
        $match: {
            "Orders.Orderdetails.product.CategoryName": "Confections"
        }
    },

    {
        $group: {
            _id: "$CustomerID",
            CustomerID: { $first: "$CustomerID" },
            CompanyName: { $first: "$CompanyName" },
            ConfectionsSale97: {
                $sum: "$Orders.Orderdetails.Value"
            }
        }
    }
])
```

```js
[
  {
    "_id": "WILMK",
    "CompanyName": "Wilman Kala",
    "ConfectionsSale97": 52.349999999999994,
    "CustomerID": "WILMK"
  },
  {
    "_id": "EASTC",
    "CompanyName": "Eastern Connection",
    "ConfectionsSale97": 480,
    "CustomerID": "EASTC"
  },
  {
    "_id": "MEREP",
    "CompanyName": "Mère Paillarde",
    "ConfectionsSale97": 1715.1249987158924,
    "CustomerID": "MEREP"
  },
  {
    "_id": "REGGC",
    "CompanyName": "Reggiani Caseifici",
    "ConfectionsSale97": 443.69999926537275,
    "CustomerID": "REGGC"
  },
  {
    "_id": "FRANK",
    "CompanyName": "Frankenversand",
    "ConfectionsSale97": 1678.9749984033406,
    "CustomerID": "FRANK"
  },
  {
    "_id": "VAFFE",
    "CompanyName": "Vaffeljernet",
    "ConfectionsSale97": 1064.5,
    "CustomerID": "VAFFE"
  },
  {
    "_id": "AROUT",
    "CompanyName": "Around the Horn",
    "ConfectionsSale97": 375.19999977201223,
    "CustomerID": "AROUT"
  },
  {
    "_id": "RANCH",
    "CompanyName": "Rancho grande",
    "ConfectionsSale97": 199.39999999999998,
    "CustomerID": "RANCH"
  },
  {
    "_id": "RICSU",
    "CompanyName": "Richter Supermarkt",
    "ConfectionsSale97": 1254.3839989572764,
    "CustomerID": "RICSU"
  },
  {
    "_id": "TOMSP",
    "CompanyName": "Toms Spezialitäten",
    "ConfectionsSale97": 166.4399995431304,
    "CustomerID": "TOMSP"
  },
  {
    "_id": "GREAL",
    "CompanyName": "Great Lakes Food Market",
    "ConfectionsSale97": 407.6999993249774,
    "CustomerID": "GREAL"
  },
  {
    "_id": "KOENE",
    "CompanyName": "Königlich Essen",
    "ConfectionsSale97": 2119.399995714426,
    "CustomerID": "KOENE"
  },
  {
    "_id": "CACTU",
    "CompanyName": "Cactus Comidas para llevar",
    "ConfectionsSale97": 75,
    "CustomerID": "CACTU"
  },
  {
    "_id": "SPLIR",
    "CompanyName": "Split Rail Beer & Ale",
    "ConfectionsSale97": 308.9999997764826,
    "CustomerID": "SPLIR"
  },
  {
    "_id": "BSBEV",
    "CompanyName": "B's Beverages",
    "ConfectionsSale97": 875,
    "CustomerID": "BSBEV"
  },
  {
    "_id": "LILAS",
    "CompanyName": "LILA-Supermercado",
    "ConfectionsSale97": 740,
    "CustomerID": "LILAS"
  },
  {
    "_id": "SIMOB",
    "CompanyName": "Simons bistro",
    "ConfectionsSale97": 694.8749991059303,
    "CustomerID": "SIMOB"
  },
  {
    "_id": "HUNGO",
    "CompanyName": "Hungry Owl All-Night Grocers",
    "ConfectionsSale97": 520,
    "CustomerID": "HUNGO"
  },
  {
    "_id": "CHOPS",
    "CompanyName": "Chop-suey Chinese",
    "ConfectionsSale97": 823.6999997019768,
    "CustomerID": "CHOPS"
  },
  {
    "_id": "RICAR",
    "CompanyName": "Ricardo Adocicados",
    "ConfectionsSale97": 855.9999993294477,
    "CustomerID": "RICAR"
  }
]
```

d)

Zapytanie wykorzystujące oryginalne kolekcje
(customers, orders, orderdertails, products, categories) 

```js
db.orders.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "CustomerID",
            foreignField: "CustomerID",
            as: "Customer"
        }
    },
    { $unwind: { path: "$Customer", preserveNullAndEmptyArrays: true } },

    {
        $lookup: {
            from: "orderdetails",
            localField: "OrderID",
            foreignField: "OrderID",
            as: "Details"
        }
    },
    { $unwind: { path: "$Details", preserveNullAndEmptyArrays: true } },

    {
        $addFields: {
            OrderValue: {
                $multiply: [
                    "$Details.UnitPrice",
                    "$Details.Quantity",
                    { $subtract: [1, "$Details.Discount"] }
                ]
            }
        }
    },

    {
        $group: {
            _id: {
                CustomerID: "$Customer.CustomerID",
                CompanyName: "$Customer.CompanyName",
                Year: { $year: "$OrderDate" },
                Month: { $month: "$OrderDate" }
            },
            Total: { $sum: "$OrderValue" }
        }
    },

    {
        $group: {
            _id: "$_id.CustomerID",
            CompanyName: { $first: "$_id.CompanyName" },
            Sale: {
                $push: {
                    Year: "$_id.Year",
                    Month: "$_id.Month",
                    Total: "$Total"
                }
            }
        }
    }
]);
```

Zapytanie wykorzystujące kolekcję OrdersInfo

```js
db.OrdersInfo.aggregate([
    { $unwind: "$Orderdetails" },

    {
        $addFields: {
            OrderValue: "$Orderdetails.Value"
        }
    },

    {
        $group: {
            _id: {
                CustomerID: "$Customer.CustomerID",
                CompanyName: "$Customer.CompanyName",
                Year: { $year: "$Dates.OrderDate" },
                Month: { $month: "$Dates.OrderDate" }
            },
            Total: { $sum: "$OrderValue" }
        }
    },

    {
        $group: {
            _id: "$_id.CustomerID",
            CompanyName: { $first: "$_id.CompanyName" },
            Sale: {
                $push: {
                    Year: "$_id.Year",
                    Month: "$_id.Month",
                    Total: "$Total"
                }
            }
        }
    }
]);
```

Zapytanie wykorzystujące kolekcję CustomerInfo:

```js
db.CustomerInfo.aggregate([
    { $unwind: "$Orders" },

    { $unwind: "$Orders.Orderdetails" },

    {
        $addFields: {
            OrderValue: "$Orders.Orderdetails.Value"
        }
    },

    {
        $group: {
            _id: {
                CustomerID: "$CustomerID",
                CompanyName: "$CompanyName",
                Year: { $year: "$Orders.Dates.OrderDate" },
                Month: { $month: "$Orders.Dates.OrderDate" }
            },
            Total: { $sum: "$OrderValue" }
        }
    },

    {
        $group: {
            _id: "$_id.CustomerID",
            CompanyName: { $first: "$_id.CompanyName" },
            Sale: {
                $push: {
                    Year: "$_id.Year",
                    Month: "$_id.Month",
                    Total: "$Total"
                }
            }
        }
    }
]);
```

Wynik zwracany przez te zapytania (Zwracane rekordy są identyczne, jednak zwracane wyniki mogą się różnić kolejnością):

```js
[
  {
    "_id": "HUNGC",
    "CompanyName": "Hungry Coyote Import Store",
    "Sale": [
      {
        "Year": 1997,
        "Month": 7,
        "Total": 479.8
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 102.4
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 780
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1701
      }
    ]
  },
  {
    "_id": "LACOR",
    "CompanyName": "La corne d'abondance",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1343.05
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 649
      }
    ]
  },
  {
    "_id": "TOMSP",
    "CompanyName": "Toms Spezialitäten",
    "Sale": [
      {
        "Year": 1996,
        "Month": 7,
        "Total": 1863.4
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 240.1
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 700.2399979010224
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 1064
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 910.4
      }
    ]
  },
  {
    "_id": "NORTS",
    "CompanyName": "North/South",
    "Sale": [
      {
        "Year": 1998,
        "Month": 4,
        "Total": 45
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 352
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 252
      }
    ]
  },
  {
    "_id": "KOENE",
    "CompanyName": "Königlich Essen",
    "Sale": [
      {
        "Year": 1998,
        "Month": 1,
        "Total": 11920.663975276948
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1553.4999987483025
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 5502.11
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 415.79999931156635
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 2160
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 717.6
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 3463
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 2141.5999960899353
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 469.1099996320903
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 1661.4
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 903.5999997854233
      }
    ]
  },
  {
    "_id": "GREAL",
    "CompanyName": "Great Lakes Food Market",
    "Sale": [
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1891.6149984095246
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 455.9999983012676
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1039.685
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 6281.499986812472
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 8446.449993375689
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 392.19999994039534
      }
    ]
  },
  {
    "_id": "SPLIR",
    "CompanyName": "Split Rail Beer & Ale",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 439
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 4578.429996409267
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 141.60000000000002
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 3081.5999974250794
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 485
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 678
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 48
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1989.9999925866723
      }
    ]
  },
  {
    "_id": "CACTU",
    "CompanyName": "Cactus Comidas para llevar",
    "Sale": [
      {
        "Year": 1998,
        "Month": 4,
        "Total": 305
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 644.8
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 225.5
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 477
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 150
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 12.5
      }
    ]
  },
  {
    "_id": "SIMOB",
    "CompanyName": "Simons bistro",
    "Sale": [
      {
        "Year": 1997,
        "Month": 1,
        "Total": 11188.4
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 695.999997407198
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 2942.8125
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 570
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 232.0849998179823
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 352.59999763965607
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 835.1999999999999
      }
    ]
  },
  {
    "_id": "LILAS",
    "CompanyName": "LILA-Supermercado",
    "Sale": [
      {
        "Year": 1997,
        "Month": 5,
        "Total": 1504.4999894499779
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 1538.7
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 122.39999914169312
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 2825.999995805323
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 1648.999988436699
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1885
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 1412
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 1167.6799971342086
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 112
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 1050.6
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 720
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 1414.8
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 673.9199996200203
      }
    ]
  },
  {
    "_id": "BSBEV",
    "CompanyName": "B's Beverages",
    "Sale": [
      {
        "Year": 1997,
        "Month": 7,
        "Total": 493
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 477
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1500
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 479.4
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 931
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1714.2
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 495.3
      }
    ]
  },
  {
    "_id": "HUNGO",
    "CompanyName": "Hungry Owl All-Night Grocers",
    "Sale": [
      {
        "Year": 1997,
        "Month": 9,
        "Total": 5523.499997904151
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 4429.549996521324
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1342.949998471886
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 4407
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 2036.1599924147129
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 2680.2199933305383
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 4097.979979839921
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 17035.79
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2023.379996649921
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 997
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1441.375
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2518.999991208315
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1446
      }
    ]
  },
  {
    "_id": "EASTC",
    "CompanyName": "Eastern Connection",
    "Sale": [
      {
        "Year": 1996,
        "Month": 11,
        "Total": 950
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2772
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 3063
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 655
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 6524.6849999999995
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 796.35
      }
    ]
  },
  {
    "_id": "MEREP",
    "CompanyName": "Mère Paillarde",
    "Sale": [
      {
        "Year": 1997,
        "Month": 7,
        "Total": 5210.699996195734
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 3105.149997007102
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 9194.559965747596
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 638.5
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 147.89999999999998
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 3957.5
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 5140.879991716147
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 398.9999996870756
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 1078
      }
    ]
  },
  {
    "_id": "WILMK",
    "CompanyName": "Wilman Kala",
    "Sale": [
      {
        "Year": 1997,
        "Month": 10,
        "Total": 642
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 120
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 412.35
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 1401
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 586
      }
    ]
  },
  {
    "_id": "VAFFE",
    "CompanyName": "Vaffeljernet",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 3343.5
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 2517.9999970048666
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 861.25
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 3160.5999950915575
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 1765.6
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 940.4999992623925
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 735.9999972581862
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 834.2
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1684.2749997060746
      }
    ]
  },
  {
    "_id": "FRANK",
    "CompanyName": "Frankenversand",
    "Sale": [
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1829.7569985649736
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1511.9999992847443
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 1903.8000000000002
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 1078.6875
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 4807.899998206645
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 2825.2999977841973
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 4307.6399931430815
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 1072.425
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1174.75
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1336.9499986171722
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 1270.7499990910292
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 3536.599980354309
      }
    ]
  },
  {
    "_id": "REGGC",
    "CompanyName": "Reggiani Caseifici",
    "Sale": [
      {
        "Year": 1996,
        "Month": 8,
        "Total": 80.09999986737967
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1624.4999987259507
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1051.399998486042
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 517.4399996995926
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 560
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 23.799999833106995
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 488.69999919086695
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 192
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 1692.7999976277351
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 154.39999942481518
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 663.0999994799495
      }
    ]
  },
  {
    "_id": "AROUT",
    "CompanyName": "Around the Horn",
    "Sale": [
      {
        "Year": 1997,
        "Month": 2,
        "Total": 407.6999993249774
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 1640.999997496605
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 547.1999989002943
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1668.1
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 480
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 899
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 491.5
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 4831.249996516854
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 282
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2142.9
      }
    ]
  },
  {
    "_id": "RICSU",
    "CompanyName": "Richter Supermarkt",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1257.9549981381745
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 2097.599998354912
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 2490.5
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 498.0999965071678
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 3276.0839989572764
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 1823.8
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 3232.799994647503
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 4666.9400000000005
      }
    ]
  },
  {
    "_id": "RANCH",
    "CompanyName": "Rancho grande",
    "Sale": [
      {
        "Year": 1997,
        "Month": 2,
        "Total": 443.4
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 932
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 76
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 686.7
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 706
      }
    ]
  },
  {
    "_id": "LEHMS",
    "CompanyName": "Lehmanns Marktstand",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 500
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 368.9324997106567
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 3603.2200000000003
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 581
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 1152.5
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 2510.86749216523
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 1583.9999999701977
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 2110.69999922961
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 1629.974990323186
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 1521.375
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 3698.8399949401614
      }
    ]
  },
  {
    "_id": "BONAP",
    "CompanyName": "Bon app'",
    "Sale": [
      {
        "Year": 1996,
        "Month": 11,
        "Total": 1549.6
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 1296
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1930.399998486042
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 2524.679998089373
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 843
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 2792.7624996202067
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 2896.229998447746
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2148.629997960478
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 818.399999588728
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 2549.9999821186066
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1820.8
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 792.75
      }
    ]
  },
  {
    "_id": "DRACD",
    "CompanyName": "Drachenblut Delikatessen",
    "Sale": [
      {
        "Year": 1996,
        "Month": 12,
        "Total": 86.39999999999999
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1692
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 420
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 1030.76
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 447.20000000000005
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 86.85000000000001
      }
    ]
  },
  {
    "_id": "CENTC",
    "CompanyName": "Centro comercial Moctezuma",
    "Sale": [
      {
        "Year": 1996,
        "Month": 7,
        "Total": 100.8
      }
    ]
  },
  {
    "_id": "MAGAA",
    "CompanyName": "Magazzini Alimentari Riuniti",
    "Sale": [
      {
        "Year": 1996,
        "Month": 9,
        "Total": 608
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 291.8399997711182
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1487.9999935626984
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 833
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1591.2499987520278
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1326.2249991949648
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 235.2
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 747.4999955296516
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 55.199999999999996
      }
    ]
  },
  {
    "_id": "QUEDE",
    "CompanyName": "Que Delícia",
    "Sale": [
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1194.2699968636036
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 550
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 807.38
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 863.2799985706806
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 448
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 497.5199991762638
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1353.6
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 636
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 314.75999882742764
      }
    ]
  },
  {
    "_id": "GROSR",
    "CompanyName": "GROSELLA-Restaurante",
    "Sale": [
      {
        "Year": 1997,
        "Month": 12,
        "Total": 387.5
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 1101.2
      }
    ]
  },
  {
    "_id": "OLDWO",
    "CompanyName": "Old World Delicatessen",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 848
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 565.5
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 539.3999997764826
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 3638.8874882236123
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 934.5
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1261.875
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 1755
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 3741.2999938055873
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 1893
      }
    ]
  },
  {
    "_id": "LAZYK",
    "CompanyName": "Lazy K Kountry Store",
    "Sale": [
      {
        "Year": 1997,
        "Month": 3,
        "Total": 147
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 210
      }
    ]
  },
  {
    "_id": "SANTG",
    "CompanyName": "Santé Gourmet",
    "Sale": [
      {
        "Year": 1997,
        "Month": 8,
        "Total": 500
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 670
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 2684.4
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 1058.4
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 622.35
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 200
      }
    ]
  },
  {
    "_id": "HILAA",
    "CompanyName": "HILARION-Abastos",
    "Sale": [
      {
        "Year": 1996,
        "Month": 12,
        "Total": 2122.919996866584
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 4615.679999971389
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 2638.1999999284744
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 1119.9
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 1375.649996906519
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 880.5
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1727.5
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 2054
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2940.05
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 575
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 2341.3639920023084
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 378
      }
    ]
  },
  {
    "_id": "QUEEN",
    "CompanyName": "Queen Cozinha",
    "Sale": [
      {
        "Year": 1998,
        "Month": 2,
        "Total": 3226.8499987483024
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 2761.937497998588
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 9210.9
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1119.8999999687076
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 889.7
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1296.75
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1531.0799942962826
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1227.019999037683
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 2027.0799857854843
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1830.7799972072244
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 595.5
      }
    ]
  },
  {
    "_id": "GODOS",
    "CompanyName": "Godos Cocina Típica",
    "Sale": [
      {
        "Year": 1998,
        "Month": 4,
        "Total": 676.5
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2362.25
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 1117.7999981492758
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 3831.4599983856083
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 683.2999990209937
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 2775.05
      }
    ]
  },
  {
    "_id": "PRINI",
    "CompanyName": "Princesa Isabel Vinhos",
    "Sale": [
      {
        "Year": 1998,
        "Month": 4,
        "Total": 2633.9
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 285.1199995279312
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 558
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 716.7199949741363
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 851.1999999999999
      }
    ]
  },
  {
    "_id": "VINET",
    "CompanyName": "Vins et alcools Chevalier",
    "Sale": [
      {
        "Year": 1997,
        "Month": 11,
        "Total": 379.8
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 538.6
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 121.6
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 440
      }
    ]
  },
  {
    "_id": "TRAIH",
    "CompanyName": "Trail's Head Gourmet Provisioners",
    "Sale": [
      {
        "Year": 1998,
        "Month": 1,
        "Total": 237.89999999999998
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 1333.3
      }
    ]
  },
  {
    "_id": "RICAR",
    "CompanyName": "Ricardo Adocicados",
    "Sale": [
      {
        "Year": 1998,
        "Month": 2,
        "Total": 1955.125
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 818.9999958276749
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 965
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1472
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 3205.399997279048
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 932.3749989271164
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 914.4
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 349.5
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1838
      }
    ]
  },
  {
    "_id": "CHOPS",
    "CompanyName": "Chop-suey Chinese",
    "Sale": [
      {
        "Year": 1996,
        "Month": 12,
        "Total": 1117.5999977588654
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 556.6199972748757
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 3059.799998301268
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 4202.199998517334
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1098.4599937558173
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 2314.1999993771315
      }
    ]
  },
  {
    "_id": "BOTTM",
    "CompanyName": "Bottom-Dollar Markets",
    "Sale": [
      {
        "Year": 1998,
        "Month": 4,
        "Total": 2712.225
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 851.199999332428
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 3661.0499963983893
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 3118
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 8626.325
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 1832.8
      }
    ]
  },
  {
    "_id": "ANATR",
    "CompanyName": "Ana Trujillo Emparedados y helados",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 514.4
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 479.75
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 320
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 88.8
      }
    ]
  },
  {
    "_id": "PICCO",
    "CompanyName": "Piccolo und mehr",
    "Sale": [
      {
        "Year": 1998,
        "Month": 1,
        "Total": 735
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1912.85
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 651
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 4180
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 439.20000000000005
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1404.4499965131283
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 8593.279967987537
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 3054.999991003424
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 718.0799987778067
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 1440
      }
    ]
  },
  {
    "_id": "WARTH",
    "CompanyName": "Wartian Herkku",
    "Sale": [
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1054.7999994456768
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 269.99999955296516
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 2697.699992346764
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 975.8799976684153
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 1393.1999988555908
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 629.5
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 1376
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 3077
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1590.5624888464808
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2237.499992990494
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 346.5599997282028
      }
    ]
  },
  {
    "_id": "ANTON",
    "CompanyName": "Antonio Moreno Taquería",
    "Sale": [
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2082
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 1940.8499967865646
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 749.0624947473407
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 660
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 403.20000000000005
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1188.8649942964316
      }
    ]
  },
  {
    "_id": "WELLI",
    "CompanyName": "Wellington Importadora",
    "Sale": [
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1707.8399971723557
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 375.7499997317791
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 142.5
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1371.7999992519617
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 619.5
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 140
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1193.0099990643562
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 517.8
      }
    ]
  },
  {
    "_id": "COMMI",
    "CompanyName": "Comércio Mineiro",
    "Sale": [
      {
        "Year": 1998,
        "Month": 4,
        "Total": 405.75
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 108
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 216
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 912
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 2169
      }
    ]
  },
  {
    "_id": "RATTC",
    "CompanyName": "Rattlesnake Canyon Grocery",
    "Sale": [
      {
        "Year": 1996,
        "Month": 9,
        "Total": 4929.2999965325
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 4124
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 3574.799997061491
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 11380
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 507
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 583.9999993920326
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 3343.6
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 1255.7204986971803
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 10495.6
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 1618.8799983263016
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2124.049997728318
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 2388.5
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 3868.6
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 903.75
      }
    ]
  },
  {
    "_id": "FURIB",
    "CompanyName": "Furia Bacalhau e Frutos do Mar",
    "Sale": [
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1288.387490965426
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 1677.2999936938286
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 1168
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 57.799999594688416
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1868.784994623065
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 230.84999961778522
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 136.2999992966652
      }
    ]
  },
  {
    "_id": "BLONP",
    "CompanyName": "Blondesddsl père et fils",
    "Sale": [
      {
        "Year": 1997,
        "Month": 9,
        "Total": 660
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2875.159988039732
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 450
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 7390.2
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 3832.7199967771767
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 1176
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 730
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 1420
      }
    ]
  },
  {
    "_id": "LAUGB",
    "CompanyName": "Laughing Bacchus Wine Cellars",
    "Sale": [
      {
        "Year": 1998,
        "Month": 1,
        "Total": 187
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 57.5
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 278
      }
    ]
  },
  {
    "_id": "LONEP",
    "CompanyName": "Lonesome Pine Restaurant",
    "Sale": [
      {
        "Year": 1997,
        "Month": 5,
        "Total": 417.2
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 134.39999999999998
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1420
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1575
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 712
      }
    ]
  },
  {
    "_id": "VICTE",
    "CompanyName": "Victuailles en stock",
    "Sale": [
      {
        "Year": 1997,
        "Month": 2,
        "Total": 2084.319997987151
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 144.8
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 439.6
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 2576.4499844014645
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 654.0599997505545
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 471.1999996304512
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 2812
      }
    ]
  },
  {
    "_id": "WOLZA",
    "CompanyName": "Wolski  Zajazd",
    "Sale": [
      {
        "Year": 1996,
        "Month": 12,
        "Total": 459
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 399.85
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1277.6
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 587.5
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 808
      }
    ]
  },
  {
    "_id": "WANDK",
    "CompanyName": "Die Wandernde Kuh",
    "Sale": [
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1023.0749989647418
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 2369.7999999999997
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 1469.9999987125398
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1485.7999988347292
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1297.749999538064
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 1941.9999927654862
      }
    ]
  },
  {
    "_id": "FAMIA",
    "CompanyName": "Familia Arquibaldo",
    "Sale": [
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1779.1999993890522
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 166
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 525.299996316433
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 287.8
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 309.99999884516
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 224.82999990209936
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 814.4199954867363
      }
    ]
  },
  {
    "_id": "MORGK",
    "CompanyName": "Morgenstern Gesundkost",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 245
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 1200.8
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1335
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 114
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2147.4
      }
    ]
  },
  {
    "_id": "ERNSH",
    "CompanyName": "Ernst Handel",
    "Sale": [
      {
        "Year": 1997,
        "Month": 8,
        "Total": 5510.592461358011
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 4725
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 13453.674988241866
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 8467.714980641007
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 1792
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 3488.679993984103
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 3436.4434975519407
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 15719.749971166253
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 6379.4
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 550.5874961391091
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 4990.879997253418
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1536.7999942749739
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 7671.999979197979
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 8623.45
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 6221.5
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 7088.504993692413
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 5218
      }
    ]
  },
  {
    "_id": "DUMON",
    "CompanyName": "Du monde entier",
    "Sale": [
      {
        "Year": 1998,
        "Month": 2,
        "Total": 860.1
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 268.79999999999995
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 63
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 424
      }
    ]
  },
  {
    "_id": "BLAUS",
    "CompanyName": "Blauer See Delikatessen",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 677
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 858
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 330
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 625
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 285.8
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 464
      }
    ]
  },
  {
    "_id": "SEVES",
    "CompanyName": "Seven Seas Imports",
    "Sale": [
      {
        "Year": 1996,
        "Month": 12,
        "Total": 2092.3999932706356
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 3471.6799972772596
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 1630
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 3747.33499709107
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 4237.109991375357
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1036.799999785423
      }
    ]
  },
  {
    "_id": "THECR",
    "CompanyName": "The Cracker Box",
    "Sale": [
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1393.24
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 228
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 326
      }
    ]
  },
  {
    "_id": "TRADH",
    "CompanyName": "Tradição Hipermercados",
    "Sale": [
      {
        "Year": 1998,
        "Month": 1,
        "Total": 4234.263997506201
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 1296
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 189.9999998509884
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 1130.3999957889318
      }
    ]
  },
  {
    "_id": "FOLIG",
    "CompanyName": "Folies gourmandes",
    "Sale": [
      {
        "Year": 1997,
        "Month": 12,
        "Total": 4303
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 756
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1622.4
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 4985.5
      }
    ]
  },
  {
    "_id": "OCEAN",
    "CompanyName": "Océano Atlántico Ltda.",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 3001
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 110
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 319.20000000000005
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 30
      }
    ]
  },
  {
    "_id": "FRANS",
    "CompanyName": "Franchi S.p.A.",
    "Sale": [
      {
        "Year": 1997,
        "Month": 12,
        "Total": 18.4
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 49.8
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1296
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 88
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 93.5
      }
    ]
  },
  {
    "_id": "WHITC",
    "CompanyName": "White Clover Markets",
    "Sale": [
      {
        "Year": 1997,
        "Month": 10,
        "Total": 3535.649989557266
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1625.4749927669764
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 3523.4
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 2296
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 1924.25
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 1180.8799956008793
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 8902.5
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1415.999994724989
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 1388.5
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 928.75
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 642.1999994963408
      }
    ]
  },
  {
    "_id": "QUICK",
    "CompanyName": "QUICK-Stop",
    "Sale": [
      {
        "Year": 1997,
        "Month": 12,
        "Total": 2247.0999969169497
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 3119.9999883770943
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 17926.499985940754
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1814.8
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 6315.875
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 15913.67499927543
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 9162.239991446733
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 3812.699996329844
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 9921.299973487854
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 4529.8
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 4971.039996612072
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 4464.599996969104
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 6796.639991939068
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 182.39999999999998
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 15248.974972587825
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 3849.6599936261773
      }
    ]
  },
  {
    "_id": "GOURL",
    "CompanyName": "Gourmet Lanchonetes",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 131.749999076128
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 273.5999989807606
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 3424
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 946.4999940991402
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1498.35
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1119.935
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1020
      }
    ]
  },
  {
    "_id": "GALED",
    "CompanyName": "Galería del gastrónomo",
    "Sale": [
      {
        "Year": 1997,
        "Month": 1,
        "Total": 338.20000000000005
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 137.5
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 136
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 155
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 70
      }
    ]
  },
  {
    "_id": "LINOD",
    "CompanyName": "LINO-Delicateses",
    "Sale": [
      {
        "Year": 1998,
        "Month": 4,
        "Total": 3333.1799995973706
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2782.3349903613325
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 2720.05
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1583.9999973773956
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 400
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 805.425
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 3001.5749992132187
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1850
      }
    ]
  },
  {
    "_id": "PERIC",
    "CompanyName": "Pericles Comidas clásicas",
    "Sale": [
      {
        "Year": 1997,
        "Month": 4,
        "Total": 816.3
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 1249.1
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 112
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1196
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 300
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 568.8
      }
    ]
  },
  {
    "_id": "OTTIK",
    "CompanyName": "Ottilies Käseladen",
    "Sale": [
      {
        "Year": 1997,
        "Month": 4,
        "Total": 240
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 1194
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 1504.65
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 1728.5249986443669
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 1830.3499946258962
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 2310
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 1013.7449992049485
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 1768
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 906.92999849841
      }
    ]
  },
  {
    "_id": "SAVEA",
    "CompanyName": "Save-a-lot Markets",
    "Sale": [
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1185.7499968707561
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 3645.7399940356613
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2944.3999890312552
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 4330.399994160235
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 16819.649996387958
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 5275.71496502459
      },
      {
        "Year": 1997,
        "Month": 7,
        "Total": 14333.39999962747
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 6942.634964315594
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 4971.919981627167
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 9628.1
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 5062.549996566773
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 4707.539999584258
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 6542.399996995926
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 5278
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 12693.749993896485
      }
    ]
  },
  {
    "_id": "ISLAT",
    "CompanyName": "Island Trading",
    "Sale": [
      {
        "Year": 1998,
        "Month": 1,
        "Total": 1764
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 384.4
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 516.8
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 45
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1080
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 230.39999999999998
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 446.6
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 758.5
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 920.6
      }
    ]
  },
  {
    "_id": "MAISD",
    "CompanyName": "Maison Dewey",
    "Sale": [
      {
        "Year": 1998,
        "Month": 2,
        "Total": 2840.4999983608723
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1434
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 2917
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 946
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1303.1949921518565
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 295.38
      }
    ]
  },
  {
    "_id": "TORTU",
    "CompanyName": "Tortuga Restaurante",
    "Sale": [
      {
        "Year": 1996,
        "Month": 8,
        "Total": 1268.7
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 954.4
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 1191.1999999999998
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 838.45
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 539.5
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 975
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 534.85
      },
      {
        "Year": 1998,
        "Month": 5,
        "Total": 360
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 4150.05
      }
    ]
  },
  {
    "_id": "SUPRD",
    "CompanyName": "Suprêmes délices",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2255.4999970272183
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 2487.0999997258186
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 2218.4799894452094
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 2708.7999999999997
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 3597.8999980315566
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 28
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 5693
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 1209
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 3891
      }
    ]
  },
  {
    "_id": "SPECD",
    "CompanyName": "Spécialités du monde",
    "Sale": [
      {
        "Year": 1997,
        "Month": 11,
        "Total": 52.349999999999994
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 108.5
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2052.5
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 210
      }
    ]
  },
  {
    "_id": "HANAR",
    "CompanyName": "Hanari Carnes",
    "Sale": [
      {
        "Year": 1998,
        "Month": 2,
        "Total": 4059.55
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 1946.5199967771769
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 1678.75
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 862.5
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 2997.399989652634
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 17027.6499966681
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 2733.9999950379133
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1535
      }
    ]
  },
  {
    "_id": "ALFKI",
    "CompanyName": "Alfreds Futterkiste",
    "Sale": [
      {
        "Year": 1997,
        "Month": 8,
        "Total": 814.5
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 933.4999996051192
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 845.799999922514
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 471.19999970197676
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 1208
      }
    ]
  },
  {
    "_id": "BOLID",
    "CompanyName": "Bólido Comidas preparadas",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 223.99999916553497
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 982
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 3026.8500000000004
      }
    ]
  },
  {
    "_id": "ROMEY",
    "CompanyName": "Romero y tomillo",
    "Sale": [
      {
        "Year": 1996,
        "Month": 9,
        "Total": 498.5
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 241.89999999999998
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 365.89
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 361
      }
    ]
  },
  {
    "_id": "THEBI",
    "CompanyName": "The Big Cheese",
    "Sale": [
      {
        "Year": 1997,
        "Month": 12,
        "Total": 2775
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 180.4
      },
      {
        "Year": 1996,
        "Month": 9,
        "Total": 336
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 69.6
      }
    ]
  },
  {
    "_id": "LETSS",
    "CompanyName": "Let's Stop N Shop",
    "Sale": [
      {
        "Year": 1998,
        "Month": 2,
        "Total": 1378.0699989192187
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 844.2525
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 536.3999991118908
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 317.75
      }
    ]
  },
  {
    "_id": "LAMAI",
    "CompanyName": "La maison d'Asie",
    "Sale": [
      {
        "Year": 1997,
        "Month": 7,
        "Total": 299.25
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 2622.759997943044
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 72.95999972820282
      },
      {
        "Year": 1997,
        "Month": 8,
        "Total": 55.7999999076128
      },
      {
        "Year": 1997,
        "Month": 1,
        "Total": 2483.2
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 331.19999876618385
      },
      {
        "Year": 1996,
        "Month": 11,
        "Total": 1071.459998600185
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 35.99999986588955
      },
      {
        "Year": 1997,
        "Month": 4,
        "Total": 1131.6599985823036
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 475.109998601675
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 748.7999972105026
      }
    ]
  },
  {
    "_id": "CONSH",
    "CompanyName": "Consolidated Holdings",
    "Sale": [
      {
        "Year": 1998,
        "Month": 1,
        "Total": 931.5
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 631.6
      },
      {
        "Year": 1997,
        "Month": 3,
        "Total": 156.00000000000003
      }
    ]
  },
  {
    "_id": "BERGS",
    "CompanyName": "Berglunds snabbköp",
    "Sale": [
      {
        "Year": 1997,
        "Month": 8,
        "Total": 1503.6
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 2222.3999999999996
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 1206.6
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 3112.7124999999996
      },
      {
        "Year": 1997,
        "Month": 11,
        "Total": 1459
      },
      {
        "Year": 1996,
        "Month": 8,
        "Total": 2102
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 96.5
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 472.5
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 1805.7499997027217
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1835.6999970376492
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 3192.65
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 4417.079993113875
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 1501.0849990379063
      }
    ]
  },
  {
    "_id": "FRANR",
    "CompanyName": "France restauration",
    "Sale": [
      {
        "Year": 1998,
        "Month": 3,
        "Total": 1733.0600000000002
      },
      {
        "Year": 1997,
        "Month": 9,
        "Total": 920.1
      },
      {
        "Year": 1998,
        "Month": 1,
        "Total": 519
      }
    ]
  },
  {
    "_id": "FOLKO",
    "CompanyName": "Folk och fä HB",
    "Sale": [
      {
        "Year": 1998,
        "Month": 1,
        "Total": 250.8
      },
      {
        "Year": 1998,
        "Month": 3,
        "Total": 2555.3999987989664
      },
      {
        "Year": 1998,
        "Month": 4,
        "Total": 8474.437498658895
      },
      {
        "Year": 1996,
        "Month": 12,
        "Total": 103.19999999999999
      },
      {
        "Year": 1997,
        "Month": 2,
        "Total": 497.21999845504763
      },
      {
        "Year": 1997,
        "Month": 6,
        "Total": 2844.5
      },
      {
        "Year": 1997,
        "Month": 5,
        "Total": 2222.199998912215
      },
      {
        "Year": 1997,
        "Month": 10,
        "Total": 2545
      },
      {
        "Year": 1996,
        "Month": 7,
        "Total": 695.6249988526106
      },
      {
        "Year": 1996,
        "Month": 10,
        "Total": 1809.9999932572246
      },
      {
        "Year": 1997,
        "Month": 12,
        "Total": 5205.75
      },
      {
        "Year": 1998,
        "Month": 2,
        "Total": 2363.429988357425
      }
    ]
  }
]
```

e)

```js
const customerId = "ALFKI";

const chai = db.products.findOne({ ProductName: "Chai" });
const ikura = db.products.findOne({ ProductName: "Ikura" });

const maxOrder = db.orders.find().sort({ OrderID: -1 }).limit(1).toArray()[0];
const newOrderID = maxOrder.OrderID + 1;
const today = new Date();
const requiredDate = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);

db.orders.insertOne({
    OrderID: newOrderID,
    CustomerID: customerId,
    EmployeeID: 1,
    OrderDate: today,
    RequiredDate: requiredDate,
    ShipVia: 1,
    Freight: 30.0,
    ShipName: "ALFKI Corp.",
    ShipAddress: "Testowa 12",
    ShipCity: "Warsaw",
    ShipCountry: "Poland"
});

db.orderdetails.insertMany([
    {
        OrderID: newOrderID,
        ProductID: chai.ProductID,
        UnitPrice: chai.UnitPrice,
        Quantity: 10,
        Discount: 0
    },
    {
        OrderID: newOrderID,
        ProductID: ikura.ProductID,
        UnitPrice: ikura.UnitPrice,
        Quantity: 10,
        Discount: 0
    }
]);
```

Aby zaktualizować kolekcje OrdersInfo i CustomerInfo, ponownie wywołujemy polecenie, które wywoływaliśmy tworząc te kolekcje.

f)

```js
db.orderdetails.updateMany(
    { OrderID: newOrderID },
    [
        {
            $set: {
                Discount: { $add: ["$Discount", 0.05] }
            }
        }
    ]
);
```

Aby zaktualizować kolekcje OrdersInfo i CustomerInfo, ponownie wywołujemy polecenie, które wywoływaliśmy tworząc te kolekcje.


....

# Zadanie 2 - modelowanie danych


Zaproponuj strukturę bazy danych dla wybranego/przykładowego zagadnienia/problemu

Należy wybrać jedno zagadnienie/problem (A lub B lub C)

Przykład A
- Wykładowcy, przedmioty, studenci, oceny
	- Wykładowcy prowadzą zajęcia z poszczególnych przedmiotów
	- Studenci uczęszczają na zajęcia
	- Wykładowcy wystawiają oceny studentom
	- Studenci oceniają zajęcia

Przykład B
- Firmy, wycieczki, osoby
	- Firmy organizują wycieczki
	- Osoby rezerwują miejsca/wykupują bilety
	- Osoby oceniają wycieczki

Przykład C
- Własny przykład o podobnym stopniu złożoności

a) Zaproponuj  różne warianty struktury bazy danych i dokumentów w poszczególnych kolekcjach oraz przeprowadzić dyskusję każdego wariantu (wskazać wady i zalety każdego z wariantów)
- zdefiniuj schemat/reguły walidacji danych
- wykorzystaj referencje
- dokumenty zagnieżdżone
- tablice

b) Kolekcje należy wypełnić przykładowymi danymi

c) W kontekście zaprezentowania wad/zalet należy zaprezentować kilka przykładów/zapytań/operacji oraz dla których dedykowany jest dany wariant

W sprawozdaniu należy zamieścić przykładowe dokumenty w formacie JSON ( pkt a) i b)), oraz kod zapytań/operacji (pkt c)), wraz z odpowiednim komentarzem opisującym strukturę dokumentów oraz polecenia ilustrujące wykonanie przykładowych operacji na danych

Do sprawozdania należy kompletny zrzut wykonanych/przygotowanych baz danych (taki zrzut można wykonać np. za pomocą poleceń `mongoexport`, `mongdump` …) oraz plik z kodem operacji/zapytań w wersji źródłowej (np. plik .js, np. plik .md ), załącznik powinien mieć format zip

## Zadanie 2  - rozwiązanie

> Wyniki: 
> 
> przykłady, kod, zrzuty ekranów, komentarz ...

Wybraliśmy problem A.

Struktura opierająca się na czystych referencjach:
Składa się z 4 kolekcji: students (zawierającej studentów), lecturers (zawierającej wykładowców), courses (zawierającej przedmioty) i grades (zawierającej oceny).

```js
use studies;

db.createCollection("students", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["StudentID", "FirstName", "LastName", "EnrollmentYear"],
            properties: {
                StudentID: { bsonType: "int" },
                FirstName: { bsonType: "string" },
                LastName: { bsonType: "string" },
                EnrollmentYear: { bsonType: "int" }
            }
        }
    }
});

db.createCollection("lecturers", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["LecturerID", "FirstName", "LastName", "Department"],
            properties: {
                LecturerID: { bsonType: "int" },
                FirstName: { bsonType: "string" },
                LastName: { bsonType: "string" },
                Department: { bsonType: "string" }
            }
        }
    }
});

db.createCollection("courses", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["CourseID", "CourseName", "LecturerID"],
            properties: {
                CourseID: { bsonType: "int" },
                CourseName: { bsonType: "string" },
                LecturerID: { bsonType: "int" }
            }
        }
    }
});

db.createCollection("grades", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["GradeID", "StudentID", "CourseID", "Grade", "GradeDate"],
            properties: {
                GradeID: { bsonType: "int" },
                StudentID: { bsonType: "int" },
                CourseID: { bsonType: "int" },
                Grade: { bsonType: "double" },
                GradeDate: { bsonType: "date" }
            }
        }
    }
});
```

Dodawanie danych:
```js
db.students.insertMany([
  {
    StudentID: 1,
    FirstName: "Anna",
    LastName: "Kowalska",
    EnrollmentYear: 2022
  },
  {
    StudentID: 2,
    FirstName: "Piotr",
    LastName: "Nowicki",
    EnrollmentYear: 2021
  },
  {
    StudentID: 3,
    FirstName: "Marta",
    LastName: "Wiśniewska",
    EnrollmentYear: 2023
  }
]);

db.lecturers.insertMany([
  {
    LecturerID: 1,
    FirstName: "Jan",
    LastName: "Nowak",
    Department: "Matematyka"
  },
  {
    LecturerID: 2,
    FirstName: "Ewa",
    LastName: "Zielińska",
    Department: "Informatyka"
  }
]);

db.courses.insertMany([
  {
    CourseID: 1,
    CourseName: "Analiza Matematyczna",
    LecturerID: 1
  },
  {
    CourseID: 2,
    CourseName: "Algorytmy i Struktury Danych",
    LecturerID: 2
  },
  {
    CourseID: 3,
    CourseName: "Statystyka",
    LecturerID: 1
  }
]);

db.grades.insertMany([
  {
    GradeID: 1,
    StudentID: 1,
    CourseID: 1,
    Grade: 4.5,
    GradeDate: new Date("2025-01-20")
  },
  {
    GradeID: 2,
    StudentID: 1,
    CourseID: 2,
    Grade: 5.0,
    GradeDate: new Date("2025-02-15")
  },
  {
    GradeID: 3,
    StudentID: 2,
    CourseID: 1,
    Grade: 3.5,
    GradeDate: new Date("2025-01-22")
  },
  {
    GradeID: 4,
    StudentID: 2,
    CourseID: 3,
    Grade: 4.0,
    GradeDate: new Date("2025-03-10")
  },
  {
    GradeID: 5,
    StudentID: 3,
    CourseID: 2,
    Grade: 5.0,
    GradeDate: new Date("2025-02-18")
  }
]);

```

Wygląd dokumentów:

```js
//students
[
  {
    "_id": {"$oid": "680cb8353e757d1e5f6b05a5"},
    "EnrollmentYear": 2022,
    "FirstName": "Anna",
    "LastName": "Kowalska",
    "StudentID": 1
  },
  {
    "_id": {"$oid": "680cb8353e757d1e5f6b05a6"},
    "EnrollmentYear": 2021,
    "FirstName": "Piotr",
    "LastName": "Nowicki",
    "StudentID": 2
  },
  {
    "_id": {"$oid": "680cb8353e757d1e5f6b05a7"},
    "EnrollmentYear": 2023,
    "FirstName": "Marta",
    "LastName": "Wiśniewska",
    "StudentID": 3
  }
]

//lecturers
[
  {
    "_id": {"$oid": "680cb83e3e757d1e5f6b05a9"},
    "Department": "Matematyka",
    "FirstName": "Jan",
    "LastName": "Nowak",
    "LecturerID": 1
  },
  {
    "_id": {"$oid": "680cb83e3e757d1e5f6b05aa"},
    "Department": "Informatyka",
    "FirstName": "Ewa",
    "LastName": "Zielińska",
    "LecturerID": 2
  }
]

//courses
[
  {
    "_id": {"$oid": "680cb8453e757d1e5f6b05ac"},
    "CourseID": 1,
    "CourseName": "Analiza Matematyczna",
    "LecturerID": 1
  },
  {
    "_id": {"$oid": "680cb8453e757d1e5f6b05ad"},
    "CourseID": 2,
    "CourseName": "Algorytmy i Struktury Danych",
    "LecturerID": 2
  },
  {
    "_id": {"$oid": "680cb8453e757d1e5f6b05ae"},
    "CourseID": 3,
    "CourseName": "Statystyka",
    "LecturerID": 1
  }
]

//grades
[
  {
    "_id": {"$oid": "680cba383e757d1e5f6b05cf"},
    "CourseID": 1,
    "Grade": 4.5,
    "GradeDate": {"$date": "2025-01-20T00:00:00.000Z"},
    "GradeID": 1,
    "StudentID": 1
  },
  {
    "_id": {"$oid": "680cba383e757d1e5f6b05d0"},
    "CourseID": 2,
    "Grade": 5,
    "GradeDate": {"$date": "2025-02-15T00:00:00.000Z"},
    "GradeID": 2,
    "StudentID": 1
  },
  {
    "_id": {"$oid": "680cba383e757d1e5f6b05d1"},
    "CourseID": 1,
    "Grade": 3.5,
    "GradeDate": {"$date": "2025-01-22T00:00:00.000Z"},
    "GradeID": 3,
    "StudentID": 2
  },
  {
    "_id": {"$oid": "680cba383e757d1e5f6b05d2"},
    "CourseID": 3,
    "Grade": 4,
    "GradeDate": {"$date": "2025-03-10T00:00:00.000Z"},
    "GradeID": 4,
    "StudentID": 2
  },
  {
    "_id": {"$oid": "680cba383e757d1e5f6b05d3"},
    "CourseID": 2,
    "Grade": 5,
    "GradeDate": {"$date": "2025-02-18T00:00:00.000Z"},
    "GradeID": 5,
    "StudentID": 3
  }
]
```

Przykładowe zapytania:

```js
//studenci i ich oceny
db.students.aggregate([
    {
        $lookup: {
            from: "grades",
            localField: "StudentID",
            foreignField: "StudentID",
            as: "Grades"
        }
    }
]);

//wykładowcy i przedmioty, które prowadzą
db.lecturers.aggregate([
    {
        $lookup: {
            from: "courses",
            localField: "LecturerID",
            foreignField: "LecturerID",
            as: "Courses"
        }
    }
]);

//średnia ocen dla każdego studenta
db.grades.aggregate([
    {
        $group: {
            _id: "$StudentID",
            AvgGrade: { $avg: "$Grade" }
        }
    },
    {
        $lookup: {
            from: "students",
            localField: "_id",
            foreignField: "StudentID",
            as: "Student"
        }
    },
    { $unwind: "$Student" },
    {
        $project: {
            _id: 0,
            StudentName: "$Student.FirstName",
            StudentSurname: "$Student.LastName",
            AvgGrade: 1
        }
    }
]);

//lista studentów zapisanych na przedmiot Analiza Matematyczna
db.courses.aggregate([
    { $match: { CourseName: "Analiza Matematyczna" } },
    {
        $lookup: {
            from: "grades",
            localField: "CourseID",
            foreignField: "CourseID",
            as: "Grades"
        }
    },
    { $unwind: "$Grades" },
    {
        $lookup: {
            from: "students",
            localField: "Grades.StudentID",
            foreignField: "StudentID",
            as: "Student"
        }
    },
    { $unwind: "$Student" },
    {
        $project: {
            _id: 0,
            CourseName: "$Name",
            FirstName: "$Student.FirstName",
            LastName: "$Student.LastName",
            Grade: "$Grades.Grade"
        }
    }
]);
```

Wariant z zagnieżdżonymi dokumentami:

Wariant składa się z dwóch kolekcji: students (zawierającej studentów wraz z ich ocenami) oraz courses zawierającej przedmioty wraz z wykładowcami je prowadzącymi.

```js
use studies2;

db.createCollection("students", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["StudentID", "FirstName", "LastName", "Courses"],
            properties: {
                StudentID: { bsonType: "int" },
                FirstName: { bsonType: "string" },
                LastName: { bsonType: "string" },
                Courses: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        required: ["CourseID", "CourseName", "Lecturer", "Grade", "GradeDate", "CourseRating"],
                        properties: {
                            CourseID: { bsonType: "int" },
                            CourseName: { bsonType: "string" },
                            Lecturer: {
                                bsonType: "object",
                                required: ["LecturerID", "FirstName", "LastName"],
                                properties: {
                                    LecturerID: { bsonType: "int" },
                                    FirstName: { bsonType: "string" },
                                    LastName: { bsonType: "string" }
                                }
                            },
                            Grade: { bsonType: ["double", "int"] },
                            GradeDate: { bsonType: "date" },
                            CourseRating: { bsonType: "int" }
                        }
                    }
                }
            }
        }
    }
});

db.createCollection("courses", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["CourseID", "CourseName", "Lecturer"],
            properties: {
                CourseID: { bsonType: "int" },
                CourseName: { bsonType: "string" },
                Lecturer: {
                    bsonType: "object",
                    required: ["LecturerID", "FirstName", "LastName"],
                    properties: {
                        LecturerID: { bsonType: "int" },
                        FirstName: { bsonType: "string" },
                        LastName: { bsonType: "string" }
                    }
                }
            }
        }
    }
});
```
Dodawanie danych:
```js
db.students.insertMany([
  {
    StudentID: 1,
    FirstName: "Anna",
    LastName: "Kowalska",
    Email: "anna.kowalska@example.com",
    Courses: [
      {
        CourseID: 1,
        CourseName: "Matematyka",
        Lecturer: { LecturerID: 1, FirstName: "Jan", LastName: "Kowalski", Email: "jan.kowalski@example.com" },
        Grade: 4.5,
        GradeDate: ISODate("2025-01-20"),
        CourseRating: 5
      },
      {
        CourseID: 2,
        CourseName: "Fizyka",
        Lecturer: { LecturerID: 2, FirstName: "Agnieszka", LastName: "Nowak", Email: "agnieszka.nowak@example.com" },
        Grade: 5.0,
        GradeDate: ISODate("2025-02-15"),
        CourseRating: 4
      }
    ]
  },
  {
    StudentID: 2,
    FirstName: "Bartosz",
    LastName: "Nowak",
    Email: "bartosz.nowak@example.com",
    Courses: [
      {
        CourseID: 1,
        CourseName: "Matematyka",
        Lecturer: { LecturerID: 1, FirstName: "Jan", LastName: "Kowalski", Email: "jan.kowalski@example.com" },
        Grade: 3.5,
        GradeDate: ISODate("2025-01-22"),
        CourseRating: 3
      },
      {
        CourseID: 3,
        CourseName: "Chemia",
        Lecturer: { LecturerID: 1, FirstName: "Jan", LastName: "Kowalski", Email: "jan.kowalski@example.com" },
        Grade: 4.0,
        GradeDate: ISODate("2025-03-10"),
        CourseRating: 4
      }
    ]
  },
  {
    StudentID: 3,
    FirstName: "Celina",
    LastName: "Wiśniewska",
    Email: "celina.wisniewska@example.com",
    Courses: [
      {
        CourseID: 2,
        CourseName: "Fizyka",
        Lecturer: { LecturerID: 2, FirstName: "Agnieszka", LastName: "Nowak", Email: "agnieszka.nowak@example.com" },
        Grade: 5.0,
        GradeDate: ISODate("2025-02-18"),
        CourseRating: 5
      }
    ]
  }
]);

db.courses.insertMany([
  {
    CourseID: 1,
    CourseName: "Matematyka",
    Lecturer: {
      LecturerID: 1,
      FirstName: "Jan",
      LastName: "Kowalski",
      Email: "jan.kowalski@example.com"
    }
  },
  {
    CourseID: 2,
    CourseName: "Fizyka",
    Lecturer: {
      LecturerID: 2,
      FirstName: "Agnieszka",
      LastName: "Nowak",
      Email: "agnieszka.nowak@example.com"
    }
  },
  {
    CourseID: 3,
    CourseName: "Chemia",
    Lecturer: {
      LecturerID: 1,
      FirstName: "Jan",
      LastName: "Kowalski",
      Email: "jan.kowalski@example.com"
    }
  }
]);
```
Struktura kolekcji:

```js
//students
[
  {
    "_id": {"$oid": "680cef7e52f4e5172407626f"},
    "Courses": [
      {
        "CourseID": 1,
        "CourseName": "Matematyka",
        "Lecturer": {
          "LecturerID": 1,
          "FirstName": "Jan",
          "LastName": "Kowalski",
          "Email": "jan.kowalski@example.com"
        },
        "Grade": 4.5,
        "GradeDate": {"$date": "2025-01-20T00:00:00.000Z"},
        "CourseRating": 5
      },
      {
        "CourseID": 2,
        "CourseName": "Fizyka",
        "Lecturer": {
          "LecturerID": 2,
          "FirstName": "Agnieszka",
          "LastName": "Nowak",
          "Email": "agnieszka.nowak@example.com"
        },
        "Grade": 4.5,
        "GradeDate": {"$date": "2025-02-15T00:00:00.000Z"},
        "CourseRating": 4
      }
    ],
    "Email": "anna.kowalska@example.com",
    "FirstName": "Anna",
    "LastName": "Kowalska",
    "StudentID": 1
  },
  {
    "_id": {"$oid": "680cef7e52f4e51724076270"},
    "Courses": [
      {
        "CourseID": 1,
        "CourseName": "Matematyka",
        "Lecturer": {
          "LecturerID": 1,
          "FirstName": "Jan",
          "LastName": "Kowalski",
          "Email": "jan.kowalski@example.com"
        },
        "Grade": 3.5,
        "GradeDate": {"$date": "2025-01-22T00:00:00.000Z"},
        "CourseRating": 3
      },
      {
        "CourseID": 3,
        "CourseName": "Chemia",
        "Lecturer": {
          "LecturerID": 1,
          "FirstName": "Jan",
          "LastName": "Kowalski",
          "Email": "jan.kowalski@example.com"
        },
        "Grade": 4,
        "GradeDate": {"$date": "2025-03-10T00:00:00.000Z"},
        "CourseRating": 4
      },
      {
        "CourseID": 4,
        "CourseName": "Informatyka",
        "Lecturer": {
          "LecturerID": 3,
          "FirstName": "Michał",
          "LastName": "Wójcik",
          "Email": "michal.wojcik@example.com"
        },
        "Grade": 5,
        "GradeDate": {"$date": "2025-04-10T00:00:00.000Z"},
        "CourseRating": 5
      }
    ],
    "Email": "bartosz.nowak@example.com",
    "FirstName": "Bartosz",
    "LastName": "Nowak",
    "StudentID": 2
  },
  {
    "_id": {"$oid": "680cef7e52f4e51724076271"},
    "Courses": [
      {
        "CourseID": 2,
        "CourseName": "Fizyka",
        "Lecturer": {
          "LecturerID": 2,
          "FirstName": "Agnieszka",
          "LastName": "Nowak",
          "Email": "agnieszka.nowak@example.com"
        },
        "Grade": 5,
        "GradeDate": {"$date": "2025-02-18T00:00:00.000Z"},
        "CourseRating": 5
      }
    ],
    "Email": "celina.wisniewska@example.com",
    "FirstName": "Celina",
    "LastName": "Wiśniewska",
    "StudentID": 3
  },
  {
    "_id": {"$oid": "680cf3df52f4e5172407627f"},
    "Courses": [
      {
        "CourseID": 2,
        "CourseName": "Fizyka",
        "Lecturer": {
          "LecturerID": 2,
          "FirstName": "Agnieszka",
          "LastName": "Nowak",
          "Email": "agnieszka.nowak@example.com"
        },
        "Grade": 4,
        "GradeDate": {"$date": "2025-03-05T00:00:00.000Z"},
        "CourseRating": 4
      }
    ],
    "Email": "damian.sikora@example.com",
    "FirstName": "Damian",
    "LastName": "Sikora",
    "StudentID": 4
  },
  {
    "_id": {"$oid": "680cf46a52f4e51724076281"},
    "Courses": [
      {
        "CourseID": 2,
        "CourseName": "Fizyka",
        "Lecturer": {
          "LecturerID": 2,
          "FirstName": "Agnieszka",
          "LastName": "Nowak",
          "Email": "agnieszka.nowak@example.com"
        },
        "Grade": 4,
        "GradeDate": {"$date": "2025-03-05T00:00:00.000Z"},
        "CourseRating": 4
      }
    ],
    "Email": "damian.sikora@example.com",
    "FirstName": "Damian",
    "LastName": "Sikora",
    "StudentID": 4
  }
]

//courses
[
  {
    "_id": {"$oid": "680cf0c652f4e5172407627b"},
    "CourseID": 1,
    "CourseName": "Matematyka",
    "Lecturer": {
      "LecturerID": 1,
      "FirstName": "Jan",
      "LastName": "Kowalski",
      "Email": "jan.kowalski@example.com"
    }
  },
  {
    "_id": {"$oid": "680cf0c652f4e5172407627c"},
    "CourseID": 2,
    "CourseName": "Fizyka",
    "Lecturer": {
      "LecturerID": 2,
      "FirstName": "Agnieszka",
      "LastName": "Nowak",
      "Email": "agnieszka.nowak@example.com"
    }
  },
  {
    "_id": {"$oid": "680cf0c652f4e5172407627d"},
    "CourseID": 3,
    "CourseName": "Chemia",
    "Lecturer": {
      "LecturerID": 1,
      "FirstName": "Jan",
      "LastName": "Kowalski",
      "Email": "jan.kowalski@example.com"
    }
  }
]
```

Przykładowe zapytania i operacje:

```js
//dodanie nowego studenta
db.students.insertOne({
    StudentID: 4,
    FirstName: "Damian",
    LastName: "Sikora",
    Email: "damian.sikora@example.com",
    Courses: [
        {
            CourseID: 2,
            CourseName: "Fizyka",
            Lecturer: {
                LecturerID: 2,
                FirstName: "Agnieszka",
                LastName: "Nowak",
                Email: "agnieszka.nowak@example.com"
            },
            Grade: 4.0,
            GradeDate: new Date("2025-03-05"),
            CourseRating: 4
        }
    ]
});

//lista wszystkich studentów z ich kursami
db.students.find(
  {},
  { _id: 0, FirstName: 1, LastName: 1, Courses: 1 }
);

//zaktualizuj ocenę studenta
db.students.updateOne(
  { StudentID: 1, "Courses.CourseName": "Fizyka" },
  { $set: { "Courses.$.Grade": 4.5 } }
);

//zapisanie studenta na kurs
db.students.updateOne(
  { StudentID: 2 },
  { $push: {
    Courses: {
      CourseID: 4,
      CourseName: "Informatyka",
      Lecturer: {
        LecturerID: 3,
        FirstName: "Michał",
        LastName: "Wójcik",
        Email: "michal.wojcik@example.com"
      },
      Grade: 5.0,
      GradeDate: new Date("2025-04-10"),
      CourseRating: 5
    }
  }}
);

//średnia ocen dla każdego studenta
db.students.aggregate([
  { $unwind: "$Courses" },
  { $group: {
    _id: { studentID: "$StudentID", studentName: { $concat: [ "$FirstName", " ", "$LastName" ] } },
    averageGrade: { $avg: "$Courses.Grade" }
  }},
  { $project: {
    _id: 0,
    studentID: "$_id.studentID",
    studentName: "$_id.studentName",
    averageGrade: 1
  }}
]);

//wykładowcy i przedmioty które prowadzą
db.students.aggregate([
  { $unwind: "$Courses" },
  { $group: {
    _id: { lecturerID: "$Courses.Lecturer.LecturerID", lecturerName: { $concat: [ "$Courses.Lecturer.FirstName", " ", "$Courses.Lecturer.LastName" ] } },
    courses: { $addToSet: "$Courses.CourseName" }
  }},
  { $project: {
    _id: 0,
    lecturerID: "$_id.lecturerID",
    lecturerName: "$_id.lecturerName",
    courses: 1
  }}
]);

//studenci i ich oceny
db.students.aggregate([
  { $unwind: "$Courses" },
  { $project: {
    _id: 0,
    studentID: "$StudentID",
    studentName: { $concat: [ "$FirstName", " ", "$LastName" ] },
    courseName: "$Courses.CourseName",
    grade: "$Courses.Grade"
  }}
]);
```

Struktura z referencjami zmniejsza redundancję danych, gdyż informacje o studentach, wykładowcach itp. są przechowywane tylko raz. Łatwiej dzięki temu zaktualizować poszczególne informacje, gdyż są przechowywane w jednym miejscu. W przypadku większych baz może to poprawić wydajność.

W przypadku odczytu należy używać operacji $lookup czy $join, co powoduje mniejszą wydajność odczytu i większe złożenie zapytań.

W przypadku zagnieżdżenia dokumentów potrzebne dane są przechowywane w jednym dokumencie, co umożliwia szybkie odczytywanie danych bez potrzeby wykonywania dodatkowych zapytań czy operacji join. W przeciwieństwie do wariantu z referencjami, jest większa redundancja danych, gdyż dane mogą się powtarzać w kilku dokumentach. Zwiększa to też rozmiar dokumentu i powoduje trudności w aktualizacji.

---

Punktacja:

|         |     |
| ------- | --- |
| zadanie | pkt |
| 1       | 1   |
| 2       | 1   |
| razem   | 2   |
