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

namespace BookShopManagement.UserControls
{
    public partial class UC_ManageExpense : UserControl
    {
        private BL_Order OrderDB = new BL_Order();
        private BL_Book_Order BookOrderDB = new BL_Book_Order();

        private Customer customer;

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
            int OrderID = int.Parse(row.Cells["OrderId"].Value.ToString());

            //
            UC_ManageExpense_Load(null, null);
            BookOrderDB.GetAllProduct_ByID(OrderID, ref this.ViewAllProducts);




        }
    }
}
