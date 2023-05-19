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
    public partial class UC_Top3Author : UserControl
    {
        BookStoreEntities db = new BookStoreEntities();
        public UC_Top3Author()
        {
            InitializeComponent(); 
            var authors = db.v_Top3Authors.ToList();
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
