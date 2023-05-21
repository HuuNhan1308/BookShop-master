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
    public partial class RefreshBtn : UserControl
    {
        BookStoreEntities db = new BookStoreEntities();
        BL_Author AuthorDB = new BL_Author();
        public RefreshBtn()
        {
            InitializeComponent(); 
        }

        private void UC_Top3Author_Load(object sender, EventArgs e)
        {
            ViewTopAuthors.DataSource = null;
            ViewTopAuthors.DataSource = db.v_Top3Authors.ToList();
        }

        private void ChangeViewYear(object sender, EventArgs e)
        {
            RadioButton button = sender as RadioButton;

            if (!button.Checked) return;

            ViewTopAuthors.DataSource = null;
            ViewTopAuthors.DataSource = AuthorDB.Get_BestAuthor_ByYear(button.Text.ToString());

        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.UC_Top3Author_Load(null, null);
        }
    }
}
