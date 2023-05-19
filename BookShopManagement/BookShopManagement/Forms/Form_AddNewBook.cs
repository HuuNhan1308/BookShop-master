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

namespace BookShopManagement.Forms
{
    public partial class Form_AddNewBook : Form
    {
        BL_Book BookDB = new BL_Book();
        BL_Author AuthorDB = new BL_Author();
        BL_Publisher PublisherDB = new BL_Publisher();
        BL_Authors_Publishers Authors_Publishers_DB= new BL_Authors_Publishers();

        Book EditedBook;
        Author EditedAuthor;
        Publisher EditedPublisher;

        private bool isEdit = false;
        int BookID;

        public Form_AddNewBook()
        {
            InitializeComponent();
        }

        public Form_AddNewBook(int BookID)
        {
            InitializeComponent();
            this.BookID = BookID;
            this.isEdit = true;
            this.QuantitiesNum.Hide();
            this.label2.Hide();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            this.Dispose();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            using (Form_AddCategory ac = new Form_AddCategory())
            {
                ac.ShowDialog();
            }
        }

        private void Form_AddNewBook_Load(object sender, EventArgs e)
        {
            if(isEdit)
            {
                this.EditedBook = BookDB.GetBook_ByID(BookID);
                this.EditedAuthor = AuthorDB.GetAuthor_ByID(EditedBook.Author_ID);
                this.EditedPublisher = PublisherDB.GetPublisher_ByID(EditedBook.Publisher_ID);

                //init value
                this.Titletxt.Text = EditedBook.Name;
                this.Pricetxt.Text = EditedBook.Price.ToString();
                this.ReleaseDate.Value = EditedBook.Release_Date.Value;
                this.AuthorChoice.Text = EditedAuthor.Name;
                this.PublisherChoice.Text = EditedPublisher.Name;
            }
            else
            {
                //auto set id 
                this.BookID = BookDB.GetBooks().Last().ID + 1;
            }
            this.IDtxt.Text = BookID.ToString();


            //add to combobox authors
            AutoCompleteStringCollection data = new AutoCompleteStringCollection();
            foreach (Author author in AuthorDB.GetAuthors())
            {
                data.Add(author.Name);
                AuthorChoice.Items.Add(author.Name);
            }
            this.AuthorChoice.AutoCompleteCustomSource = data;

            //add to combobxo publisher
            foreach (Publisher publisher in PublisherDB.GetPublisher())
                PublisherChoice.Items.Add(publisher.Name);
        }

        private void AuthorChoice_SelectedIndexChanged(object sender, EventArgs e)
        {
            int AuthorID = AuthorDB.GetAuthorID_ByName(AuthorChoice.Text);
            //add to combobox publisher base on auhor
            PublisherChoice.Items.Clear();
            PublisherChoice.Text = string.Empty;
            foreach (var item in Authors_Publishers_DB.GetPublisher_ByAuthor(AuthorID))
                PublisherChoice.Items.Add(item.Name);
        }

        private void SaveBtn_Click(object sender, EventArgs e)
        {
            
            try
            {

                if (this.isEdit)
                {
                    BookDB.EditBook(this.BookID, Titletxt.Text, Math.Round(decimal.Parse(Pricetxt.Text), 2),
                    AuthorChoice.Text, PublisherChoice.Text, ReleaseDate.Value);
                }
                else
                {
                    BookDB.AddBook(Titletxt.Text, Math.Round(decimal.Parse(Pricetxt.Text), 2),
                    AuthorChoice.Text, PublisherChoice.Text, ReleaseDate.Value);
                }
            }
            catch(Exception ex)
            {
                MessageBox.Show("Input issue!");
            }

            MessageBox.Show("success");
            this.Close();
        }
    }
}
