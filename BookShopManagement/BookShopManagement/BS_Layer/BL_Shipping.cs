using BookShopManagement.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookShopManagement.BS_Layer
{
    internal class BL_Shipping
    {
        BookStoreEntities db = new BookStoreEntities();

        public List<Shipping> GetShippings()
        {
            return db.Shippings.ToList();
        }
    }
}
