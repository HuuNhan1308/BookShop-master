using BookShopManagement.Forms;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BookShopManagement.DataModel;

namespace BookShopManagement
{
    public partial class Form1 : Form
    {

        private BL_Customer customer = new BL_Customer();

        public Form1()
        {
            InitializeComponent();
        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string Username = this.Usertxt.Text.ToString();
            string Password = this.Passwordtxt.Text.ToString();

            Fn_GetUser_Result user = customer.GetUser("lynkdoll0122", "nhan1111");

            if (user == null)
            {
                MessageBox.Show("Incorrect username or password, try again!");
                return;
            }

            Customer cus = new Customer();
            cus.ID = (int)user.ID;
            cus.Name = user.Name;
            cus.Address = user.Address;
            cus.Phone = user.Phone;
            cus.Email = user.Email;
            cus.Country = user.Country;
            cus.Level = user.Level;
            cus.UserName = user.UserName;
            cus.Password = user.Password;

            using (Form_Dashboard fd = new Form_Dashboard(cus))
            {
                fd.ShowDialog();
            }
        }
    }
}
