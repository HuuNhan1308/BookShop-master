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
    public partial class UC_ManageAuthor : UserControl
    { 
        BookStoreEntities bookStoreEntities = new BookStoreEntities();
        public UC_ManageAuthor()
        {
            InitializeComponent(); 

            updateData();
             
        }

        private void updateData()
        {
            dataList.Columns.Add("Name", "Name");
            dataList.Columns.Add("Date", "Date");

            dataList.AutoGenerateColumns = false;

            dataList.Columns["Name"].DataPropertyName = "Name"; // Set DataPropertyName for the "Name" column
            dataList.Columns["Date"].DataPropertyName = "Date";

            foreach (DataGridViewColumn column in dataList.Columns)
            {
                column.ReadOnly = true;
            }

            dataList.DataSource = bookStoreEntities.Authors.ToList();
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
                    if (DateTime.TryParse(selectedRow.Cells["Date"].Value.ToString(), out DateTime selectedDate))
                    { 
                        dateTimePicker1.Value = selectedDate;
                    }
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

                    bookStoreEntities.PR_DeleteAuthor(id);
                    updateData();

                }
            }
        }

        private void clearBtn_Click(object sender, EventArgs e)
        {
            firstnameTextbox.Text = "";
            dateTimePicker1.Value = dateTimePicker1.MinDate; 
            selectedRow = null;
        }

        private void saveBtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(firstnameTextbox.Text)
                || dateTimePicker1.Value == DateTime.MinValue
                ) 
            {
                MessageBox.Show("Missing data");
                return; 
            }
            try
            {
                bookStoreEntities.Pr_AddAuthor(
                    firstnameTextbox.Text,
                    dateTimePicker1.Value
                    );
            } catch (Exception ex )
            {
                MessageBox.Show("Author must be older than 18 years old");
            }
            updateData();
        }
    }
}
