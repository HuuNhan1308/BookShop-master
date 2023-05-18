using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BookShopManagement.DataModel;

namespace BookShopManagement
{
    internal class BL_Order
    {
        BookStoreEntities db = new BookStoreEntities();

        public int AddOrder(int cusID, DateTime date, int shipID, string paymentMethod, decimal discountShip = 0)
        {
            db.Pr_AddOrder(cusID, date, shipID, paymentMethod, discountShip);

            //return order ID
            db.SaveChanges();
            var lastOrder = db.Orders.OrderByDescending(p => p.ID).FirstOrDefault().ID;

            return lastOrder;

        }

        public List<Fn_GetOrder_ByCustomer_Result> GetUserBill(int cusID)
        {
            Books_Orders myB = new Books_Orders();
            return db.Fn_GetOrder_ByCustomer(cusID).ToList();
        }
    }

    
}
