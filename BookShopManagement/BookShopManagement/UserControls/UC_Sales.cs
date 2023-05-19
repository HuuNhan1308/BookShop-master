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

        int datarow_click;

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

        private void EditBtn_Click(object sender, EventArgs e)
        {
            DataGridViewRow row = dgv_AllProduct.Rows[this.datarow_click];

            string BookName = dgv_AllProduct.SelectedCells[0].OwningRow.Cells["Tittle"].Value.ToString();
            int BookID = BookDB.GetBookID_ByName(BookName);

            using (Form_AddNewBook fa = new Form_AddNewBook(BookID))
            {
                fa.ShowDialog();
            }
        }

        private void dgv_AllProduct_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            this.datarow_click = e.RowIndex;
        }

        private void DeleteBtn_Click(object sender, EventArgs e)
        {
            string BookName = dgv_AllProduct.SelectedCells[0].OwningRow.Cells["Tittle"].Value.ToString();
            int BookID = BookDB.GetBookID_ByName(BookName);

            BookDB.DeleteBook(BookID);
        }

        private void resetBtn_Click(object sender, EventArgs e)
        {
            dgv_AllProduct.DataSource = null;
            this.UC_Sales_Load(null, null);
        }
    }
}
