using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Permissions;
using System.Text;
using System.Threading.Tasks;

namespace BookShopManagement
{
    internal class BL_Book
    {
        private BookStoreEntities db = new BookStoreEntities();

        public List<v_AllProducts> GetAllProducts()
        {
            return db.v_AllProducts.ToList();
        }
    }
}
