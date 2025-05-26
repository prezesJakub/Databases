public class Invoice
{
    public int InvoiceId { get; set; }
    public String? InvoiceNumber { get; set; }

    public List<InvoiceProduct> InvoiceProducts { get; set; } = new();
}