using Altairis.RazorPages.Paging.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Text;

namespace Altairis.RazorPages.Paging.Components {
    public class PagerViewComponent : ViewComponent {

        public IViewComponentResult Invoke(PagingInfo model) => this.View(model);

    }

}
