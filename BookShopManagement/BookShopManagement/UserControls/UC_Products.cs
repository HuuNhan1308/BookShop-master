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
using System.Runtime.Remoting;
using BookShopManagement.BS_Layer;

namespace BookShopManagement.UserControls
{
    public partial class UC_Products : UserControl
    {
        private BL_Book BookDB = new BL_Book();
        private BL_Order OrderDB = new BL_Order();
        private BL_Book_Order Book_OrderDB = new BL_Book_Order();


        private List<Demo_Order> demo_Orders = new List<Demo_Order>();
        Customer customer;

        string PaymentMethod;
        int ShippingMethod;

        public UC_Products()
        {
            InitializeComponent();
        }

        public UC_Products(Customer customer)
        {
            InitializeComponent();
            this.customer = customer;
        }

        private void btnAddNewBooks_Click(object sender, EventArgs e)
        {
            using (Form_AddNewBook abn = new Form_AddNewBook())
            {
                abn.ShowDialog();
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            using (Form_AddStock ads = new Form_AddStock())
            {
                ads.ShowDialog();
            }
        }

        private void UC_PurchaseDetails_Load(object sender, EventArgs e)
        {
            viewProducts.DataSource = this.BookDB.GetAllProducts();
            //update datagrid view
            this.viewOrder.DataSource = null;
            this.viewOrder.DataSource = this.demo_Orders;

        }

        private void viewProducts_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            Demo_Order temp = new Demo_Order();
            //Console.WriteLine(viewProducts.Rows[e.RowIndex].Cells[0].Value.ToString());

            //------------------------------------------
            temp.BookName = viewProducts.Rows[e.RowIndex].Cells[0].Value.ToString();
            temp.Price = float.Parse(viewProducts.Rows[e.RowIndex].Cells[1].Value.ToString());
            temp.Quantity++;
            temp.Total = temp.Quantity * temp.Price;

            //------------------------------------------

            bool isContain = false;
            foreach (Demo_Order order in demo_Orders)
                if (temp.BookName == order.BookName)
                {
                    isContain = true;
                    order.Quantity++;
                    order.Total = order.Price * order.Quantity;
                    break;
                }
            //neu nhu title khong ton tai trong list thi add vao list
            if (!isContain)
                this.demo_Orders.Add(temp);

            UC_PurchaseDetails_Load(null, null);

        }

        private void saveBtn_Click(object sender, EventArgs e)
        {

            int Order_ID = OrderDB.AddOrder(customer.ID, DateTime.Now, ShippingMethod, PaymentMethod);

            Book_OrderDB.AddSingleBookOrder(demo_Orders, Order_ID);

            demo_Orders.Clear();
            UC_PurchaseDetails_Load(null, null);

        }

        private void PayChecked(object sender, EventArgs e)
        {
            RadioButton checker = (RadioButton)sender;

            if (!checker.Checked) return;

            this.PaymentMethod = checker.Text.ToString();

        }

        private void ShipChecked(object sender, EventArgs e)
        {
            RadioButton checker = (RadioButton)sender;

            if (!checker.Checked) return;

            this.ShippingMethod = int.Parse(checker.Tag.ToString());
        }
    }

    public class Demo_Order
    {
        public string BookName { get; set; }
        public float Price { get; set; }
        public int Quantity { get; set; }
        public float Total { get; set; }

        public Demo_Order()
        {
            this.Quantity = 0;
            this.Total = 0;
            this.BookName = "asd_new";
            this.Price = (float)13.08;
        }


        public override string ToString()
        {
            return $"Name: {BookName} -- Price: {Price}";
        }
    }
}
