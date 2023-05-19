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
    public partial class UC_ManageUser : UserControl
    {
        List<string> countries;
        BookStoreEntities bookStoreEntities = new BookStoreEntities();
        public UC_ManageUser()
        {
            InitializeComponent();
            countries = new List<string>
            {
                "Afghanistan",
                "Albania",
                "Algeria",
                "Andorra",
                "Angola",
                "Antigua and Barbuda",
                "Argentina",
                "Armenia",
                "Australia",
                "Austria",
                "Azerbaijan",
                "Bahamas",
                "Bahrain",
                "Bangladesh",
                "Barbados",
                "Belarus",
                "Belgium",
                "Belize",
                "Benin",
                "Bhutan",
                "Bolivia",
                "Bosnia and Herzegovina",
                "Botswana",
                "Brazil",
                "Brunei",
                "Bulgaria",
                "Burkina Faso",
                "Burundi",
                "Cabo Verde",
                "Cambodia",
                "Cameroon",
                "Canada",
                "Central African Republic",
                "Chad",
                "Chile",
                "China",
                "Colombia",
                "Comoros",
                "Congo, Democratic Republic of the",
                "Congo, Republic of the",
                "Costa Rica",
                "Croatia",
                "Cuba",
                "Cyprus",
                "Czech Republic",
                "Denmark",
                "Djibouti",
                "Dominica",
                "Dominican Republic",
                "East Timor",
                "Ecuador",
                "Egypt",
                "El Salvador",
                "Equatorial Guinea",
                "Eritrea",
                "Estonia",
                "Eswatini",
                "Ethiopia",
                "Fiji",
                "Finland",
                "France",
                "Gabon",
                "Gambia",
                "Georgia",
                "Germany",
                "Ghana",
                "Greece",
                "Grenada",
                "Guatemala",
                "Guinea",
                "Guinea-Bissau",
                "Guyana",
                "Haiti",
                "Honduras",
                "Hungary",
                "Iceland",
                "India",
                "Indonesia",
                "Iran",
                "Iraq",
                "Ireland",
                "Israel",
                "Italy",
                "Jamaica",
                "Japan",
                "Jordan",
                "Kazakhstan",
                "Kenya",
                "Kiribati",
                "Korea, North",
                "Korea, South",
                "Kosovo",
                "Kuwait",
                "Kyrgyzstan",
                "Laos",
                "Latvia",
                "Lebanon",
                "Lesotho",
                "Liberia",
                "Libya",
                "Liechtenstein",
                "Lithuania",
                "Luxembourg",
                "Madagascar",
                "Malawi",
                "Malaysia",
                "Maldives",
                "Mali",
                "Malta",
                "Marshall Islands",
                "Mauritania",
                "Mauritius",
                "Mexico",
                "Micronesia",
                "Moldova",
                "Monaco",
                "Mongolia",
                "Montenegro",
                "Morocco",
                "Mozambique",
                "Myanmar",
                "Namibia",
                "Nauru",
                "Nepal",
                "Netherlands",
                "New Zealand",
                "Nicaragua",
                "Niger",
                "Nigeria",
                "North Macedonia",
                "Norway",
                "Oman",
                "Pakistan",
                "Palau",
                "Panama",
                "Papua New Guinea",
                "Paraguay",
                "Peru",
                "Philippines",
                "Poland",
                "Portugal",
                "Qatar",
                "Romania",
                "Russia",
                "Rwanda",
                "Saint Kitts and Nevis",
                "Saint Lucia",
                "Saint Vincent and the Grenadines",
                "Samoa",
                "San Marino",
                "Sao Tome and Principe",
                "Saudi Arabia",
                "Senegal",
                "Serbia",
                "Seychelles",
                "Sierra Leone",
                "Singapore",
                "Slovakia",
                "Slovenia",
                "Solomon Islands",
                "Somalia",
                "South Africa",
                "South Sudan",
                "Spain",
                "Sri Lanka",
                "Sudan",
                "Sudan, South",
                "Suriname",
                "Sweden",
                "Switzerland",
                "Syria",
                "Taiwan",
                "Tajikistan",
                "Tanzania",
                "Thailand",
                "Togo",
                "Tonga",
                "Trinidad and Tobago",
                "Tunisia",
                "Turkey",
                "Turkmenistan",
                "Tuvalu",
                "Uganda",
                "Ukraine",
                "United Arab Emirates",
                "United Kingdom",
                "United States",
                "Uruguay",
                "Uzbekistan",
                "Vanuatu",
                "Vatican City",
                "Venezuela",
                "Vietnam",
                "Yemen",
                "Zambia",
                "Zimbabwe"
            };

            countryComboBox.DataSource = countries;

            updateData();
             
        }

        private void updateData()
        {
            dataList.Columns.Add("Name", "Name");
            dataList.Columns.Add("Address", "Address");
            dataList.Columns.Add("Country", "Country");
            dataList.Columns.Add("Phone", "Phone");
            dataList.Columns.Add("Email", "Email");
            dataList.Columns.Add("UserName", "UserName");
            dataList.Columns.Add("Password", "Password");
            dataList.Columns.Add("Level", "Level");

            dataList.AutoGenerateColumns = false;

            dataList.Columns["Name"].DataPropertyName = "Name";
            dataList.Columns["Address"].DataPropertyName = "Address";
            dataList.Columns["Country"].DataPropertyName = "Country";
            dataList.Columns["Phone"].DataPropertyName = "Phone";
            dataList.Columns["Email"].DataPropertyName = "Email";
            dataList.Columns["UserName"].DataPropertyName = "UserName";
            dataList.Columns["Password"].DataPropertyName = "Password";
            dataList.Columns["Level"].DataPropertyName = "Level";

            foreach (DataGridViewColumn column in dataList.Columns)
            {
                column.ReadOnly = true;
            }

            dataList.DataSource = bookStoreEntities.Customers.ToList();
        }
         
        private int FindStringIndex(string searchString)
        {
            return countries.FindIndex(s => s.Equals(searchString, StringComparison.OrdinalIgnoreCase));
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
                    addressTextbox.Text = selectedRow.Cells["Address"].Value.ToString();
                    countryComboBox.SelectedIndex =
                        FindStringIndex(selectedRow.Cells["Country"].Value.ToString());
                    phoneTextbox.Text = selectedRow.Cells["Phone"].Value.ToString();
                    emailTextbox.Text = selectedRow.Cells["Email"].Value.ToString();
                    usernameBox.Text = selectedRow.Cells["UserName"].Value.ToString();
                    passwordTextbox.Text = selectedRow.Cells["Password"].Value.ToString();
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
                    string u = selectedRow.Cells["UserName"].Value.ToString();
                    var id = bookStoreEntities.Customers
                        .Where(b => b.UserName == u)
                        .Select(b => b.ID)
                        .FirstOrDefault();

                    bookStoreEntities.Pr_DeleteCustomer(id);
                    updateData();

                }
            }
        }

        private void clearBtn_Click(object sender, EventArgs e)
        {
            firstnameTextbox.Text = "";
            addressTextbox.Text = "";
            countryComboBox.SelectedIndex = 0;
            phoneTextbox.Text = "";
            emailTextbox.Text = "";
            usernameBox.Text = "";
            passwordTextbox.Text = "";
            selectedRow = null;
        }

        private void saveBtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(firstnameTextbox.Text)
                || string.IsNullOrEmpty(addressTextbox.Text)
                || string.IsNullOrEmpty(countryComboBox.Text)
                || string.IsNullOrEmpty(phoneTextbox.Text)
                || string.IsNullOrEmpty(emailTextbox.Text)
                || string.IsNullOrEmpty(usernameBox.Text)
                || string.IsNullOrEmpty(passwordTextbox.Text)
                ) 
            {
                MessageBox.Show("Missing data");
                return; 
            }
            bookStoreEntities.Pr_AddCustomer(
                firstnameTextbox.Text,
                addressTextbox.Text, 
                countryComboBox.Text,
                phoneTextbox.Text,
                emailTextbox.Text,
                usernameBox.Text,
                passwordTextbox.Text
                );
            updateData();
        }
    }
}
