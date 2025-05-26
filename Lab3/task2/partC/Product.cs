public class Product
{
    public int ProductId { get; set; }
    public String? ProductName { get; set; }
    public int UnitsOnStock { get; set; }

    public int SupplierId { get; set; }
    public Supplier? Supplier { get; set; }
}