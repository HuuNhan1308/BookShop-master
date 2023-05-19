using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Runtime.Remoting.Messaging;
using System.Security.Permissions;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;
using BookShopManagement.BS_Layer;
using BookShopManagement.DataModel;

namespace BookShopManagement
{
    internal class BL_Book
    {
        private BookStoreEntities db = new BookStoreEntities();
        BL_Author AuthorDB = new BL_Author();
        BL_Publisher PublisherDB = new BL_Publisher();

        public List<v_AllProducts> GetAllProducts()
        {
            return db.v_AllProducts.ToList();
        }

        public int GetBookID_ByName(string bookName)
        {
            int result = (from p in db.Books
                         where p.Name == bookName
                         select p).SingleOrDefault().ID;
            return result;
        }

        public List<Book> GetBooks()
        {
            Book myb = new Book(); 
            return db.Books.ToList();
        }

        public Book GetBook_ByID(int BookID)
        {
            return (from p in db.Books
                where p.ID == BookID
                select p).SingleOrDefault();
        }

        public void AddBook(string BookName, decimal price, string AuthorName,
            string PublisherName, DateTime ReleaseDate)
        {
            db.Pr_AddBook(BookName, price, AuthorName, PublisherName, ReleaseDate);
            db.SaveChanges();
        }

        public void EditBook(int BookID, string BookName, decimal price, string AuthorName,
            string PublisherName, DateTime ReleaseDate)
        {
            db.Pr_UpdateBook(BookID, BookName, price, AuthorName, PublisherName, ReleaseDate);
            db.SaveChanges();

        }

        public void DeleteBook(int BookID)
        {
            db.Pr_DeleteBook(BookID);
            db.SaveChanges();
        }
    }
}
