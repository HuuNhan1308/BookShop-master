using BookShopManagement.UserControls;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using BookShopManagement.DataModel;
using System.Reflection;

namespace BookShopManagement.Forms
{
    public partial class Form_Dashboard : Form
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool AllocConsole();

       //-------------------

        int PanelWidth;
        bool isCollapsed;
        private Customer customer;

        public Form_Dashboard()
        {
            InitializeComponent();
            timerTime.Start();
            PanelWidth = panelLeft.Width;
            isCollapsed = false;
            UC_Home uch = new UC_Home();
            AddControlsToPanel(uch);
        }

        public Form_Dashboard(Customer customer)
        {
            InitializeComponent();
            timerTime.Start();
            PanelWidth = panelLeft.Width;
            isCollapsed = false;
            UC_Home uch = new UC_Home();
            AddControlsToPanel(uch);
            this.customer = customer;
        }

        private void button9_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        private void Form_Dashboard_Load(object sender, EventArgs e)
        {
            //AllocConsole();
            //lam chuc nang dap nhap
            this.userName.Text = customer.UserName.ToString();
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (isCollapsed)
            {
                panelLeft.Width = panelLeft.Width + 10;
                if (panelLeft.Width >= PanelWidth)
                {
                    timer1.Stop();
                    isCollapsed = false;
                    this.Refresh();
                }
            }
            else
            {
                panelLeft.Width = panelLeft.Width - 10;
                if (panelLeft.Width <= 59)
                {
                    timer1.Stop();
                    isCollapsed = true;
                    this.Refresh();
                }
            }
        }

        private void button8_Click(object sender, EventArgs e)
        {
            timer1.Start();
        }
        private void moveSidePanel(Control btn)
        {
            panelSide.Top = btn.Top;
            panelSide.Height = btn.Height;
        }

        private void AddControlsToPanel(Control c)
        {
            c.Dock = DockStyle.Fill;
            panelControls.Controls.Clear();
            panelControls.Controls.Add(c);
        }
        private void btnHome_Click(object sender, EventArgs e)
        {
            moveSidePanel(btnHome);
            UC_Home uch = new UC_Home();
            AddControlsToPanel(uch);
        }

        private void btnSaleBooks_Click(object sender, EventArgs e)
        {
            moveSidePanel(btnSaleBooks);
            UC_Sales us = new UC_Sales();
            AddControlsToPanel(us);
        }

        private void btnPurchase_Click(object sender, EventArgs e)
        {
            moveSidePanel(btnPurchase);
            UC_Products up = new UC_Products(customer);
            AddControlsToPanel(up);
        }

        private void button4_Click(object sender, EventArgs e)
        {
            moveSidePanel(btnExpense);
            UC_ManageExpense ea = new UC_ManageExpense(customer);
            AddControlsToPanel(ea);
        }

        private void btnUsers_Click(object sender, EventArgs e)
        {
            moveSidePanel(btnUsers);
            UC_ManageUser um = new UC_ManageUser();
            AddControlsToPanel(um);
        }

        private void btnViewSales_Click(object sender, EventArgs e)
        {
            moveSidePanel(btnViewSales);
            UC_ViewSales vs = new UC_ViewSales();
            AddControlsToPanel(vs);
        }

        private void button7_Click(object sender, EventArgs e)
        {
            moveSidePanel(btnSettings);
            UC_PersonalSetting ps = new UC_PersonalSetting(customer);
            AddControlsToPanel (ps);
        }

        private void timerTime_Tick(object sender, EventArgs e)
        {
            DateTime dt = DateTime.Now;
            labelTime.Text = dt.ToString("HH:MM:ss");
        }
    }
}
