using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookShopManagement.Function
{
    public class RegisterSession
    {
        private int phase;
        private string name;
        private string username;
        private string address;
        private string country;
        private string phone;
        private string email;
        private string password;

        public RegisterSession()
        {
            phase = 1;
        }

        public int Phase
        {
            get { return phase; }
            set { phase = value; }
        }

        public void phase1(string email, string password)
        {
            Email = email;
            Password = password;
        }

        public void phase2(string name, string address, string country, string phone)
        {
            Name = name;
            Address = address; 
            Country = country;
            Phone = phone;
        }
        public void phase3(string username)
        {
            UserName = username;
        }

        public string Name
        {
            get { return name; }
            set { name = value; }
        }

        public string UserName
        {
            get => username;
            set { username = value; }
        }

        public string Address
        {
            get { return address; }
            set { address = value; }
        }

        public string Country
        {
            get { return country; }
            set { country = value; }
        }

        public string Phone
        {
            get { return phone; }
            set { phone = value; }
        }

        public string Email
        {
            get { return email; }
            set { email = value; }
        }

        public string Password
        {
            get { return password; }
            set { password = value; }
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine($"Phase: {Phase}");
            sb.AppendLine($"Name: {Name}");
            sb.AppendLine($"Username: {UserName}");
            sb.AppendLine($"Address: {Address}");
            sb.AppendLine($"Country: {Country}");
            sb.AppendLine($"Phone: {Phone}");
            sb.AppendLine($"Email: {Email}");
            sb.AppendLine($"Password: {Password}");

            return sb.ToString();
        }
    }

}
