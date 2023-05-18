using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BookShopManagement.DataModel;

namespace BookShopManagement
{
    internal class BL_Order
    {
        BookStoreEntities db = new BookStoreEntities();

        public void AddOrder(int cusID, DateTime date, int shipID, string paymentMethod, decimal discountShip = 0)
        {
            db.Pr_AddOrder(cusID, date, shipID, paymentMethod, discountShip);
        }
    }
}
