using BookShopManagement.DataModel;
using BookShopManagement.Function;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace BookShopManagement.UserControls.Register
{
    public partial class UC_RegisterPhase3 : UserControl
    {
        BookStoreEntities bookStoreEntities = new BookStoreEntities();
        RegisterSession session;
        public UC_RegisterPhase3(RegisterSession registerSession)
        {
            session = registerSession;
            InitializeComponent();
        }
        
        private void loginBtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(Usertxt.Text))
            {
                MessageBox.Show("Username cannot be null");
                return;
            }

            try
            {
                session.phase3(Usertxt.Text);
                bookStoreEntities.Pr_AddCustomer(session.Name, session.Address, session.Country, session.Phone, session.Email, session.UserName, session.Password);
                MessageBox.Show("Register success");
            } catch (Exception ex)
            {
                if (ex.InnerException.Message.Contains("UNIQUE KEY"))
                    MessageBox.Show("This Username has been used, try another");
                
            }
        }
    }
}
