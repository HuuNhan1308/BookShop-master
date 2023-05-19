using BookShopManagement.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookShopManagement
{
    internal class BL_Authors_Publishers
    {

        BookStoreEntities db = new BookStoreEntities();

        public List<Fn_GetPublishers_ByAuthor_Result> GetPublisher_ByAuthor(int AuthorID)
        {
            return db.Fn_GetPublishers_ByAuthor(AuthorID).ToList();
        }
    }
}
