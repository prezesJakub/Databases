public class Invoice
{
    public int InvoiceId { get; set; }
    public String? InvoiceNumber { get; set; }

    public int? CustomerId { get; set; }
    public Customer? Customer { get; set; }

    public List<InvoiceProduct> InvoiceProducts { get; set; } = new();
}