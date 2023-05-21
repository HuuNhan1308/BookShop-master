using BookShopManagement.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace BookShopManagement.View
{
    public partial class UC_Top3Author : UserControl
    {
        private BookStoreEntities db = new BookStoreEntities();

        public UC_Top3Author()
        {
            InitializeComponent();
        }

        private void UC_Top3Author_Load(object sender, EventArgs e)
        {
            LoadTop3Authors();
        }

        private void LoadTop3Authors()
        {
            var authors = GetTop3Authors();
            BindAuthorsToDataGridView(authors);
        }

        private List<v_Top3Authors> GetTop3Authors()
        {
            return db.v_Top3Authors.ToList();
        }

        private void BindAuthorsToDataGridView(List<v_Top3Authors> authors)
        {
            dataGridView1.DataSource = null;
            dataGridView1.AutoGenerateColumns = false;

            dataGridView1.Columns.Add("Name", "Author Name");
            dataGridView1.Columns.Add("Amount", "Amount");

            dataGridView1.DataSource = authors;

            dataGridView1.Columns["Name"].DataPropertyName = "Name";
            dataGridView1.Columns["Amount"].DataPropertyName = "Amount";

            dataGridView1.Columns["Name"].ReadOnly = true;
            dataGridView1.Columns["Amount"].ReadOnly = true;
        }
    }
}
