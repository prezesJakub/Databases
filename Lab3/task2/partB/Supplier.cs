public class Supplier
{
    public int SupplierId { get; set; }
    public string? CompanyName { get; set; }
    public string? Street { get; set; }
    public string? City { get; set; }

    public int ProductId { get; set; }
    public Product? Product { get; set; }
}