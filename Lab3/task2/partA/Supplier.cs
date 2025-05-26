public class Supplier
{
    public int SupplierId { get; set; }
    public string? CompanyName { get; set; }
    public string? Street { get; set; }
    public string? City { get; set; }

    public List<Product> Products { get; set; } = new();
}