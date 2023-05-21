using BookShopManagement.BS_Layer;
using BookShopManagement.DataModel;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BookShopManagement.View
{
    public partial class UC_Top5Books : UserControl
    {

        private int currentIndex = 0;
        BL_Book BookDB = new BL_Book();

        public UC_Top5Books()
        {
            InitializeComponent();
        }

        private void UC_Top5Books_Load(object sender, EventArgs e)
        {
            this.ViewTopBooks.DataSource = null;
            this.ViewTopBooks.DataSource = BookDB.Get_Top5Books();
        }

        private void ChangeViewYear(object sender, EventArgs e)
        {
            RadioButton button = sender as RadioButton;

            if (!button.Checked) return;

            ViewTopBooks.DataSource = null;
            ViewTopBooks.DataSource = BookDB.Get_Top5Books_ByYear(button.Text);

        }
    }
}
