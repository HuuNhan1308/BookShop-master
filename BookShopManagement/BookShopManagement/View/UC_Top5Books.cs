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

        private int currentIndex = 0;
        private List<BookInfo> bookInfo;
        private Timer timer = new Timer();
        private BookStoreEntities _bookStoreEntities = new BookStoreEntities();

        public UC_Top5Books()
        {
            InitializeComponent();

            bookInfo = new List<BookInfo>(); 
            foreach (v_Top5Books book in _bookStoreEntities.v_Top5Books)
            {
                // Get Release Date
                DateTime? releaseDate = _bookStoreEntities.Books
                    .Where(b => b.Name == book.Name)
                    .Select(b => b.Release_Date)
                    .FirstOrDefault();

                string releaseDateString = releaseDate.HasValue ? releaseDate.Value.ToString("yyyy-MM-dd") : string.Empty;


                // Get Author Name from Books table using Author ID
                var authorId = _bookStoreEntities.Books
                    .Where(b => b.Name == book.Name)
                    .Select(b => b.Author_ID)
                    .FirstOrDefault();

                string authorName = _bookStoreEntities.Authors
                    .Where(a => a.ID == authorId)
                    .Select(a => a.Name)
                    .FirstOrDefault();

                // Get Publisher Name from Books table using Publisher ID
                var publisherId = _bookStoreEntities.Books
                    .Where(b => b.Name == book.Name)
                    .Select(b => b.Publisher_ID)
                    .FirstOrDefault();

                string publisherName = _bookStoreEntities.Publishers
                    .Where(p => p.ID == publisherId)
                    .Select(p => p.Name)
                    .FirstOrDefault();


                BookInfo bookInfoItem = new BookInfo(
                    book.Name,
                    "(unknown)",
                    authorName,
                    publisherName,
                    releaseDateString);

                bookInfo.Add(bookInfoItem);
            }

            dataGridView1.AutoGenerateColumns = false; 

            dataGridView1.ReadOnly = true;


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

    }
}
