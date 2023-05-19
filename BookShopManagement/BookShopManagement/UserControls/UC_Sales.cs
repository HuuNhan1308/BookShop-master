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

namespace BookShopManagement.UserControls
{
    public partial class UC_Sales : UserControl
    {
        BL_Book BookDB = new BL_Book();

        Customer customer = new Customer();
        public UC_Sales()
        {
            InitializeComponent();
        }

        public UC_Sales(Customer customer)
        {
            InitializeComponent();
            this.customer = customer;
        }

        private void button7_Click(object sender, EventArgs e)
        {
            using (Form_FinishOrder uf = new Form_FinishOrder())
            {
                uf.ShowDialog();
            }
        }

        private void AddBtn_Click(object sender, EventArgs e)
        {
            using (Form_AddNewBook fa = new Form_AddNewBook())
            {
                fa.ShowDialog();
            }
        }

        private void UC_Sales_Load(object sender, EventArgs e)
        {
            this.dgv_AllProduct.DataSource = BookDB.GetAllProducts();
        }
    }
}
