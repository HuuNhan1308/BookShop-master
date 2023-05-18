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
using System.Reflection.Emit;

namespace BookShopManagement.UserControls
{
    public partial class UC_PurchaseDetails : UserControl
    {
        private BL_Book BookDB = new BL_Book();

        public UC_PurchaseDetails()
        {
            InitializeComponent();
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

        private async void UC_PurchaseDetails_Load(object sender, EventArgs e)
        {
            try
            {
                ShowLoadingSprite();

                var data = await Task.Run(() => this.BookDB.GetAllProducts());

                dataGridView1.DataSource = data;

                HideLoadingSprite();
            }
            catch (Exception ex)
            {
                loadingTimer.Stop();
                label1.Text = "Cannot load database! Check your connection!";
            }
        }


        private Timer loadingTimer;
        private int currentIndex = 0;

        private string[] pointText = new string[]
        {
            "", ".", "..", "..."
        };

        private void LoadingTimer_Tick(object sender, EventArgs e)
        {
            currentIndex = (currentIndex + 1) % 4;
            label1.Text = "Loading" + pointText[currentIndex];
        }

        private void ShowLoadingSprite()
        {
            label1.Location = new Point((dataGridView1.Width - label1.Width) / 2,
                (dataGridView1.Height - label1.Height) / 2);
            label1.BringToFront();

            label1.Visible = true;

            loadingTimer = new Timer();
            loadingTimer.Interval = 200;
            loadingTimer.Tick += LoadingTimer_Tick;
            loadingTimer.Start();
        }

        private void HideLoadingSprite()
        {
            label1.Text = "";
            label1.Visible = false;
        }

    }
}
