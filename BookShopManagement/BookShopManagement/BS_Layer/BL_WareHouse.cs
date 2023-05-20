using BookShopManagement.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookShopManagement.BS_Layer
{
    internal class BL_WareHouse
    {
        BookStoreEntities db = new BookStoreEntities();

        public List<v_ListWareHouse> GetWareHouses_View()
        {
            return db.v_ListWareHouse.ToList();
        }
    }
}
