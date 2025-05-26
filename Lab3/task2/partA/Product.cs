public class Product
{
    public int ProductID { get; set; }
    public String? ProductName { get; set; }
    public int UnitsOnStock { get; set; }

    public int? SupplierId { get; set; }
    public Supplier? Supplier { get; set; }
}