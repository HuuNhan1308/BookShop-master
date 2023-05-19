using BookShopManagement.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace BookShopManagement
{
    internal class BL_Publisher
    {
        BookStoreEntities db = new BookStoreEntities();

        public List<Publisher> GetPublisher()
        {
            return db.Publishers.ToList();
        }

        public int GetPublisherID_ByName(string PublisherName)
        {
            int result = (from p in db.Publishers
                          where p.Name == PublisherName
                          select p).SingleOrDefault().ID;
            return result;
        }

        public Publisher GetPublisher_ByID(int ID)
        {
            return (from p in db.Publishers
                   where p.ID == ID
                   select p).SingleOrDefault();
        }
    }
}
