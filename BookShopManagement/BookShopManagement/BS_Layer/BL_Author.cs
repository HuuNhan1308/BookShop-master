using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using BookShopManagement.DataModel;

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

        public Author GetAuthor_ByID(int ID)
        {
            return (from p in db.Authors
                   where p.ID == ID
                   select p).SingleOrDefault();
        }

        public List<Fn_GetTop3_BestAuthorOfTheYear_Result> Get_BestAuthor_ByYear(string year)
        {
            return db.Fn_GetTop3_BestAuthorOfTheYear(year.ToString()).ToList();
        }

        public void AddAuthor(string name, DateTime birthday)
        {
            db.Pr_AddAuthor(name, birthday);
        }

        public void DeleteAuthor(int AuthorID)
        {
            db.PR_DeleteAuthor(AuthorID);
        }

        public void EditAuthor(int AuthorId, string name, DateTime date)
        {
            db.Pr_UpdateAuthor(AuthorId, name, date);
        }
    }
}
