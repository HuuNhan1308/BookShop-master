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
using BookShopManagement.UserControls;
using System.Reflection.Emit;

namespace BookShopManagement
{
    public partial class Form1 : Form
    {


        public Form1()
        {
            InitializeComponent();
            panel2.Dock = DockStyle.Fill;
            panel2.Anchor = AnchorStyles.None;
            //panel2.Anchor = AnchorStyles.None;
            UC_Login ul = new UC_Login();
            AddControlsToPanel(ul);
            
            
        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        
        private void AddControlsToPanel(Control c)
        {
            c.Dock = DockStyle.Fill;
            c.Left = panel2.Size.Width / 2 - c.Width / 2;
            c.Top = panel2.Size.Height / 2 - c.Height / 2;
            panel2.Controls.Clear();
            panel2.Controls.Add(c);
        }

        private void label7_Click(object sender, EventArgs e)
        {
            using (UC_Register ur = new UC_Register())
            {
                AddControlsToPanel(ur);
            }
        }

        private bool log = true;
        private void label7_Click_1(object sender, EventArgs e)
        {
            if (log)
            {
                log = false;
                label7.Text = "Have account? Go login!";
                UC_Register ul = new UC_Register();
                AddControlsToPanel(ul);
            }
            else
            {
                log = true;
                label7.Text = "Dont have account? Go register!";
                UC_Login ul = new UC_Login();
                AddControlsToPanel(ul);
            }
        }
    }
}
