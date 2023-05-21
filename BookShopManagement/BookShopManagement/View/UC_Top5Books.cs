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
        private BookStoreEntities _db;
        BL_Book BookDB = new BL_Book();
        BL_Author AuthorDB = new BL_Author();
        BL_Publisher PublisherDB = new BL_Publisher();

        public UC_Top5Books()
        {
            InitializeComponent();
            _db = new BookStoreEntities();
        }

        private void UC_Top5Books_Load(object sender, EventArgs e)
        {
            LoadTop5Books();
        }

        private void LoadTop5Books()
        {
            var bookInfo = GetBookInfo();

            BindBookInfoToDataGridView(bookInfo);
        }

        private List<BookInfo> GetBookInfo()
        {
            var bookInfo = new List<BookInfo>();

            foreach (v_Top5Books book in _db.v_Top5Books)
            {
                DateTime? releaseDate = GetReleaseDate(book.Name);
                string releaseDateString = releaseDate.HasValue ? releaseDate.Value.ToString("yyyy-MM-dd") : string.Empty;

                var authorName = GetAuthorName(book.Name);
                var publisherName = GetPublisherName(book.Name);

                BookInfo bookInfoItem = new BookInfo(
                    book.Name,
                    "(unknown)",
                    authorName,
                    publisherName,
                    releaseDateString);

                bookInfo.Add(bookInfoItem);
            }

            return bookInfo;
        }

        private DateTime? GetReleaseDate(string bookName)
        {
            return BookDB.GetBook_ByID(BookDB.GetBookID_ByName(bookName)).Release_Date;
        }

        private string GetAuthorName(string bookName)
        {
            var authorId = _db.Books
                .Where(b => b.Name == bookName)
                .Select(b => b.Author_ID)
                .FirstOrDefault();

            return AuthorDB.GetAuthor_ByID(authorId).Name;
        }

        private string GetPublisherName(string bookName)
        {
            var publisherId = _db.Books
                .Where(b => b.Name == bookName)
                .Select(b => b.Publisher_ID)
                .FirstOrDefault();

            return PublisherDB.GetPublisher_ByID(publisherId).Name;
        }

        private void BindBookInfoToDataGridView(List<BookInfo> bookInfo)
        {
            dataGridView1.DataSource = null;
            dataGridView1.AutoGenerateColumns = false;

            dataGridView1.Columns.Add("Name", "Name");
            dataGridView1.Columns.Add("Genre", "Genre");
            dataGridView1.Columns.Add("Author", "Author");
            dataGridView1.Columns.Add("Publisher", "Publisher");
            dataGridView1.Columns.Add("ReleaseDate", "Release Date");

            dataGridView1.DataSource = bookInfo;

            dataGridView1.Columns["Name"].DataPropertyName = "Name";
            dataGridView1.Columns["Genre"].DataPropertyName = "Genre";
            dataGridView1.Columns["Author"].DataPropertyName = "Author";
            dataGridView1.Columns["Publisher"].DataPropertyName = "Publisher";
            dataGridView1.Columns["ReleaseDate"].DataPropertyName = "ReleaseDate";

            dataGridView1.Columns["Name"].ReadOnly = true;
            dataGridView1.Columns["Genre"].ReadOnly = true;
            dataGridView1.Columns["Author"].ReadOnly = true;
            dataGridView1.Columns["Publisher"].ReadOnly = true;
            dataGridView1.Columns["ReleaseDate"].ReadOnly = true;

            dataGridView1.Columns["ReleaseDate"].DefaultCellStyle.Format = "yyyy-MM-dd";
        }

        public class BookInfo
        {
            public string Name { get; set; }
            public string Genre { get; set; }
            public string Author { get; set; }
            public string Publisher { get; set; }
            public DateTime ReleaseDate { get; set; }

            public BookInfo()
            {
            }

            public BookInfo(string name, string genre, string author, string publisher, string releaseDate)
            {
                Name = name;
                Genre = genre;
                Author = author;
                Publisher = publisher;
                ReleaseDate = ReleaseDateFromString(releaseDate);
            }

            public string ReleaseDateToString()
            {
                return ReleaseDate.ToString("yyyy-MM-dd");
            }

            public DateTime ReleaseDateFromString(string dateString)
            {
                return DateTime.Parse(dateString);
            }
        }
    }
}
