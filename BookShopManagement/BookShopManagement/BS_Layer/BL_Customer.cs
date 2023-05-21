using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BookShopManagement.DataModel;

namespace BookShopManagement
{
    internal class BL_Customer
    {
        BookStoreEntities db = new BookStoreEntities();

        public Fn_GetUser_Result GetUser(string Username, string Password)
        {

            List<Fn_GetUser_Result> result = db.Fn_GetUser(Username, Password).ToList();

            if (result.Count == 0) return null;

            return result[0];
        }

        public int getIDfromUsername(string u)
        {
            var id = db.Customers
                        .Where(b => b.UserName == u)
                        .Select(b => b.ID)
                        .FirstOrDefault();
            return id;
        }
    }
}
