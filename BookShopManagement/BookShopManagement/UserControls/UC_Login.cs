using BookShopManagement.DataModel;
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

namespace BookShopManagement.UserControls
{
    public partial class UC_Login : UserControl
    {
        public UC_Login()
        {
            InitializeComponent();
        }

        private BL_Customer customer = new BL_Customer();
         

        private void loginBtn_Click(object sender, EventArgs e)
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
                this.Hide();
                fd.ShowDialog();
            }
        }

        private void Passwordtxt_TextChanged(object sender, EventArgs e)
        {

        }

        private void Usertxt_TextChanged(object sender, EventArgs e)
        {

        }

        private void pictureBox2_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }
    }
}
