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
        private BL_Shipping ShipDB = new BL_Shipping();

        private Customer customer;

        

        private int bookID;
        private int OrderID;
        private bool acceptChange = false; //if order complete = false then it is able to change or delete


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

            ViewAllOrders.DataSource = OrderDB.GetUserBill(customer.ID);

            foreach (Shipping ship in ShipDB.GetShippings())
                ShipCB.Items.Add(ship.Method);
        }

        /// set UI base on completed field
        /// 
        private void setUI_ByCompleteField(Order myOrder)
        {
            if (myOrder.Complete)
            {
                numQuantity.Enabled = false;
                ShipCB.Enabled = false;
                PaymentCB.Enabled = false;
            }
            else
            {
                numQuantity.Enabled = true;
                ShipCB.Enabled = true;
                PaymentCB.Enabled = true;
            }
            ShipCB.Text = myOrder.Shipping.Method.ToString();
            PaymentCB.Text = myOrder.Payment_Method.ToString();
        }

        private void ViewAllOrders_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            //get order id  --> get order --> set "Accept change bool"
            DataGridViewRow row = ViewAllOrders.CurrentCell.OwningRow;
            OrderID = int.Parse(row.Cells["OrderId"].Value.ToString());
            Order myOrder = OrderDB.GetOrder_ByID(OrderID);
            this.acceptChange = myOrder.Complete;

            //set UI
            this.setUI_ByCompleteField(myOrder);

            //upload dagridview
            //UC_ManageExpense_Load(null, null);
            ViewAllProducts.DataSource = null;
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

        private void DeleteOrderBtn_Click(object sender, EventArgs e)
        {
            //int OrderID = int.Parse(ViewAllOrders.SelectedCells[0].OwningRow.Cells["OrderID"].Value.ToString());

            //MessageBox.Show(OrderID.ToString());

            OrderDB.DeleteOrder(OrderID);

            UC_ManageExpense_Load(null, null);
        }

        private void btnPayOrderBtn_Click(object sender, EventArgs e)
        {
            try
            {
                OrderDB.PayOrder(OrderID);
                UC_ManageExpense_Load(null, null);

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void ViewAllOrders_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
