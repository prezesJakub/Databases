using Microsoft.EntityFrameworkCore;

public class ProdContext : DbContext
{
    public DbSet<Product> Products { get; set; }
    public DbSet<Supplier> Suppliers { get; set; }
    public DbSet<Invoice> Invoices { get; set; }
    public DbSet<InvoiceProduct> InvoiceProducts { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        base.OnConfiguring(optionsBuilder);
        optionsBuilder.UseSqlite("Datasource=MyProductDatabase");
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>()
            .HasOne(p => p.Supplier)
            .WithMany(s => s.Products)
            .HasForeignKey(p => p.SupplierId);

        modelBuilder.Entity<InvoiceProduct>()
            .HasKey(ip => new { ip.InvoiceId, ip.ProductId });

        modelBuilder.Entity<InvoiceProduct>()
            .HasOne(ip => ip.Invoice)
            .WithMany(i => i.InvoiceProducts)
            .HasForeignKey(ip => ip.InvoiceId);

        modelBuilder.Entity<InvoiceProduct>()
            .HasOne(ip => ip.Product)
            .WithMany(p => p.InvoiceProducts)
            .HasForeignKey(ip => ip.ProductId);
    }
}