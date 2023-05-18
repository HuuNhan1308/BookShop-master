using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BookShopManagement.DataModel;
using BookShopManagement.UserControls;

namespace BookShopManagement.BS_Layer
{
    internal class BL_Book_Order
    {
        BookStoreEntities db = new BookStoreEntities();

        public void AddSingleBookOrder(List<Demo_Order> userOrderList)
        {
            foreach (Demo_Order singleOrder in userOrderList)
            {
            }
        }
    }
}
