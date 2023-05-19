using BookShopManagement.DataModel;
using BookShopManagement.Function;
using BookShopManagement.UserControls.Register;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace BookShopManagement.UserControls
{
    public partial class UC_Register : UserControl
    {
        private RegisterSession registerSession;
        BookStoreEntities bookStoreEntities;
        public UC_Register(RegisterSession reg)
        {
            bookStoreEntities = new BookStoreEntities();
            this.registerSession = reg;
            InitializeComponent();
        }

        private void registerBtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(Usertxt.Text))
            {
                MessageBox.Show("Email cannot be null");
                return;
            }
            if (string.IsNullOrEmpty(Passwordtxt.Text))
            {
                MessageBox.Show("Password cannot be null");
                return;
            }
            if (!ContainsNumbersAndLetters(Passwordtxt.Text))
            {
                MessageBox.Show("Password must contains both letter and number");
                return;
            }
            if (string.IsNullOrEmpty(textBox1.Text))
            {
                MessageBox.Show("Your must retype password");
                return;
            }
            if (!textBox1.Text.Equals(Passwordtxt.Text))
            {
                MessageBox.Show("Password does not match");
                return;
            }

            registerSession.phase1(Usertxt.Text, Passwordtxt.Text);
            ButtonClicked?.Invoke(this, EventArgs.Empty);

        }
        private bool ContainsNumbersAndLetters(string input)
        { 
            string pattern = @"^(?=.*\d)(?=.*[a-zA-Z]).+$";
             
            return Regex.IsMatch(input, pattern);
        }

        public event EventHandler ButtonClicked; 
    }
}
