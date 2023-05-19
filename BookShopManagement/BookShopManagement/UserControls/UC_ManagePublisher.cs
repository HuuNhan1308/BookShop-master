using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BookShopManagement.DataModel;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using System.Data.SqlClient;

namespace BookShopManagement.UserControls
{
    public partial class UC_ManagePublisher : UserControl
    { 
        BookStoreEntities bookStoreEntities = new BookStoreEntities();
        public UC_ManagePublisher()
        {
            InitializeComponent(); 

            updateData();
             
        }

        private void updateData()
        {
            dataList.Columns.Add("Name", "Name"); 

            dataList.AutoGenerateColumns = false;

            dataList.Columns["Name"].DataPropertyName = "Name";  

            foreach (DataGridViewColumn column in dataList.Columns)
            {
                column.ReadOnly = true;
            }

            dataList.DataSource = bookStoreEntities.Publishers.ToList();
        }


        DataGridViewRow selectedRow;
        private void editBtn_Click(object sender, EventArgs e)
        {
            if (dataList.SelectedRows.Count > 0)
            {
                selectedRow = dataList.SelectedRows[0];
                if (selectedRow != null)
                {

                    firstnameTextbox.Text = selectedRow.Cells["Name"].Value.ToString(); 
                     
                    //string level = selectedRow.Cells["Level"].Value.ToString();
                }
            }
        }


        private void deleteBtn_Click(object sender, EventArgs e)
        {
            if (dataList.SelectedRows.Count > 0)
            {
                selectedRow = dataList.SelectedRows[0];
                if (selectedRow != null)
                {
                    string u = selectedRow.Cells["Name"].Value.ToString();
                    var id = bookStoreEntities.Customers
                        .Where(b => b.UserName == u)
                        .Select(b => b.ID)
                        .FirstOrDefault();

                    bookStoreEntities.Pr_Delete_publisher(id);
                    updateData();

                }
            }
        }

        private void clearBtn_Click(object sender, EventArgs e)
        {
            firstnameTextbox.Text = ""; 
            selectedRow = null;
        }

        private void saveBtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(firstnameTextbox.Text) 
                ) 
            {
                MessageBox.Show("Missing data");
                return; 
            }
            bookStoreEntities.Pr_AddPublisher(
                firstnameTextbox.Text);
            updateData();
        }
    }
}
