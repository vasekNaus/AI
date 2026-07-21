using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PagingDemoApp.Data {
    public class DemoDbContext : DbContext {

        public DemoDbContext(DbContextOptions<DemoDbContext> options) : base(options) { }

        public DbSet<Product> Products { get; set; }

        public void Seed(int number) {
            if (this.Products.Any()) return;
            for (var i = 0; i < number; i++) {
                this.Products.Add(new Product { Name = $"Product #{i}" });
            }
            this.SaveChanges();
        }
    }
}
