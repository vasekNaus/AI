using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using PagingDemoApp.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PagingDemoApp.Pages {
    public class IndexModel : Altairis.RazorPages.Paging.Models.PagedPageModel<Product> {
        private readonly DemoDbContext dc;

        public IndexModel(DemoDbContext dc) {
            this.dc = dc;
        }

        public async Task OnGetAsync(int pageNumber) {
            var q = this.dc.Products.OrderBy(p => p.Id);
            await base.GetData(q, pageNumber, pageSize: 10);
        }
    }
}