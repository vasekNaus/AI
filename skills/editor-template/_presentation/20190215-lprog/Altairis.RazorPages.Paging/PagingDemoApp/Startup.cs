using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PagingDemoApp.Data;

namespace PagingDemoApp {
    public class Startup {
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services) {
            services.AddMvc();
            services.AddDbContext<DemoDbContext>(options => {
                options.UseSqlite("Data Source=App_Data/demo.db");
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, DemoDbContext dc) {
            if (env.IsDevelopment()) {
                app.UseDeveloperExceptionPage();
            }

            dc.Database.Migrate();
            dc.Seed(50);

            app.UseStaticFiles();
            app.UseMvc();
        }
    }
}
