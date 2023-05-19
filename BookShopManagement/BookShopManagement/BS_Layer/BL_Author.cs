using BookShopManagement.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace BookShopManagement.BS_Layer
{
    internal class BL_Author
    {

        private BookStoreEntities db = new BookStoreEntities();

        public List<Author> GetAuthors()
        {
            return db.Authors.ToList();
        }

        public int GetAuthorID_ByName(string AuthorName)
        {
            int result = (from p in db.Authors
                          where p.Name == AuthorName
                          select p).SingleOrDefault().ID;
            return result;

        }
    }
}
