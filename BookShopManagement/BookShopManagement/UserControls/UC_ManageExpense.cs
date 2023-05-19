using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BookShopManagement.Forms;
using BookShopManagement.DataModel;
using BookShopManagement.BS_Layer;
using System.Drawing.Design;

namespace BookShopManagement.UserControls
{
    public partial class UC_ManageExpense : UserControl
    {
        private BL_Order OrderDB = new BL_Order();
        private BL_Book_Order BookOrderDB = new BL_Book_Order();
        private BL_Book BookDB = new BL_Book();

        private Customer customer;

        private int bookID;
        private int OrderID;

        public UC_ManageExpense()
        {
            InitializeComponent();
        }

        public UC_ManageExpense(Customer customer)
        {
            InitializeComponent();
            this.customer = customer;
        }

        private void btnAddNewBooks_Click(object sender, EventArgs e)
        {
            using (Form_AddExpense ae = new Form_AddExpense())
            {
                ae.ShowDialog();
            }
        }

        private void UC_ManageExpense_Load(object sender, EventArgs e)
        {
            ViewAllOrders.DataSource = null;
            ViewAllProducts.DataSource = null;

            ViewAllOrders.DataSource = OrderDB.GetUserBill(customer.ID);

        }

        private void ViewAllOrders_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //get order id 
            DataGridViewRow row = ViewAllOrders.CurrentCell.OwningRow;
            OrderID = int.Parse(row.Cells["OrderId"].Value.ToString());

            //upload dagridview
            UC_ManageExpense_Load(null, null);
            BookOrderDB.GetAllProduct_ByID(OrderID, ref this.ViewAllProducts);

            //assign value
            this.txtOrderID.Text = OrderID.ToString();

            this.txtBookName.Text = string.Empty;
            this.numQuantity.Value = 0;

        }

        private void ViewAllProducts_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            this.txtBookName.DataBindings.Clear();
            this.numQuantity.DataBindings.Clear();

            this.txtBookName.DataBindings.Add(new Binding("Text", ViewAllProducts.DataSource, "Name"));
            this.numQuantity.DataBindings.Add(new Binding("Value", ViewAllProducts.DataSource, "Quantities"));
        }

        private void saveBtn_Click(object sender, EventArgs e)
        {
            //get bookID
            int BookID = BookDB.GetBookID_ByName(this.txtBookName.Text);

            //MessageBox.Show($"Order ID: {this.OrderID}\nBook ID: {BookID}\nQuantity: {int.Parse(this.numQuantity.Value.ToString())}");
            //handle edit data
            BookOrderDB.EditBookOrder(this.OrderID, BookID, int.Parse(this.numQuantity.Value.ToString()));

            //upload dagridview and init value
            UC_ManageExpense_Load(null, null);
            BookOrderDB.GetAllProduct_ByID(OrderID, ref this.ViewAllProducts);
        }

        private void deleteBtn_Click(object sender, EventArgs e)
        {
            int BookID = BookDB.GetBookID_ByName(this.txtBookName.Text);

            BookOrderDB.DeleteBookOrder(OrderID, BookID);

            //upload dagridview and init value
            UC_ManageExpense_Load(null, null);
            BookOrderDB.GetAllProduct_ByID(OrderID, ref this.ViewAllProducts);
        }
    }
}
