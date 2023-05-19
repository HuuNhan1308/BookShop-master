using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BookShopManagement.DataModel;
using BookShopManagement.UserControls;

namespace BookShopManagement.BS_Layer
{
    internal class BL_Book_Order
    {
        BookStoreEntities db = new BookStoreEntities();

        public void AddSingleBookOrder(List<Demo_Order> userOrderList, int OrderID)
        {
            //method add user's books_orders

            foreach (Demo_Order singleOrder in userOrderList)
            {
                Book book = db.Books.Single(x => x.Name == singleOrder.BookName);
                db.Pr_Add_books_orders(OrderID, book.ID, singleOrder.Quantity);
            }

            Console.WriteLine("add success");
        }

        public void GetAllProduct_ByID(int OrderID, ref DataGridView view)
        {
            view.DataSource = null;
            view.DataSource = db.Books_Orders.Where(x => x.Order_ID == OrderID)
                .Select(x => new
                {
                    Name = x.Book.Name,
                    Price = x.Book.Price,
                    Quantities = x.Amount
                })
                .ToList();
        }

        public void EditBookOrder(int OrderID, int BookID, int quantity) 
        {
            db.Pr_Update_books_order(OrderID, BookID, quantity);
        }

        public void DeleteBookOrder(int OrderID, int BookID)
        {
            db.Pr_Delete_books_order(OrderID, BookID);
        }
    }
}
